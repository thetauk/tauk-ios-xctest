import Foundation

enum HTTPRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPRequestMethod { get }
    var header: [String: String]? { get }
}

enum RequestError: Error {
    case invalidURL
    case noResponse
    case badRequest
    case unauthorized
    case notFound
    case unexpectedStatusCode
    case unableToDecode
    case internalServerError
    case serviceUnavailable
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noResponse:
            return "No response from server"
        case .unableToDecode:
            return "Unable to decode"
        case .badRequest:
            return "400 - Bad Request"
        case .unauthorized:
            return "401 - Unauthorized"
        case .notFound:
            return "404 - Not Found"
        case .internalServerError:
            return "500 - Internal Server Error"
        case .serviceUnavailable:
            return "503 - Service Unavailable"
        case .unexpectedStatusCode:
            return "Unexpected Status Code"
        case .unknown:
            return "Unknown Error"
        }
    }
}

struct TaukUpload {
    struct UploadPayload: Codable {
        var testStatus: String
        var testName: String
        var testFilename: String
        var tags: DeviceInfo
        var screenshot: String?
        var view: String?
        var error: TaukError?
        var codeContext: [CodeLine]?
        var automationType: String = "XCTest"
        var language: String = "Swift"
        var platform: String?
        var platformVersion: String?
        var elapsedTimeMs: Int?
        var log: [LogEntry]?

        init(from testResult: TestResult) {
            self.testStatus = testResult.status.rawValue
            self.testName = testResult.name
            self.testFilename = testResult.filename
            self.tags = testResult.deviceInfo
            self.screenshot = testResult.screenshot
            self.view = testResult.viewSource
            self.error = testResult.error
            self.codeContext = testResult.error?.codeContext
            self.platform = testResult.deviceInfo.platformName
            self.platformVersion = testResult.deviceInfo.platformVersion
            self.elapsedTimeMs = testResult.elapsedTimeMilliseconds
            self.log = testResult.log
        }

        enum CodingKeys: String, CodingKey {
            case testStatus = "test_status"
            case testName = "test_name"
            case testFilename = "test_filename"
            case tags = "tags"
            case screenshot = "screenshot"
            case view = "view"
            case log = "log"
            case error = "error"
            case codeContext = "code_context"
            case automationType = "automation_type"
            case language = "language"
            case platform = "platform"
            case platformVersion = "platform_version"
            case elapsedTimeMs = "elapsed_time_ms"
        }
    }
    
    struct UploadEndpoint: Endpoint {
        var method: HTTPRequestMethod
        var path: String
        var baseURL: String
        var header: [String: String]?
        
        init(apiToken: String, projectId: String) {
            self.method = .post
            self.baseURL = "https://www.tauk.com/api/v1/"
            self.path = "session/upload"
            self.header = ["api_token": apiToken, "project_id": projectId]
        }
    }
    
    static var retryCount = 0
    
    static func upload(apiToken: String, projectId: String, testResult: TestResult, completion: @escaping (Result<Data, Error>) -> Void) {
        let endpoint = UploadEndpoint(apiToken: apiToken, projectId: projectId)
        guard let url = URL(string: "\(endpoint.baseURL)\(endpoint.path)") else {
            print("WARNING: \(RequestError.invalidURL.message) for upload.")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        request.httpBody = try? JSONEncoder().encode(UploadPayload(from: testResult))
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            retryCount += 1
            
            guard error == nil else {
                if retryCount < 3 {
                    self.upload(apiToken: apiToken, projectId: projectId, testResult: testResult, completion: completion)
                } else {
                    completion(.failure(RequestError.unknown))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("WARNING: \(RequestError.noResponse.message)")
                return
            }
            
            guard let data = data else {
                print("WARNING: \(RequestError.unableToDecode.message)")
                return
            }
            
            switch response.statusCode {
            case 200...299:
                completion(.success(data))
            case 400:
                print("WARNING: \(RequestError.badRequest.message)")
                completion(.failure(RequestError.badRequest))
            case 401:
                print("WARNING: \(RequestError.unauthorized.message).")
                completion(.failure(RequestError.unauthorized))
            case 404:
                print("WARNING: \(RequestError.notFound.message).")
                completion(.failure(RequestError.notFound))
            case 500:
                print("WARNING: \(RequestError.internalServerError.message)")
                completion(.failure(RequestError.internalServerError))
            case 503:
                print("WARNING: \(RequestError.serviceUnavailable.message)")
                completion(.failure(RequestError.serviceUnavailable))
            default:
                print("WARNING: \(RequestError.unexpectedStatusCode.message).")
                completion(.failure(RequestError.unexpectedStatusCode))
            }
            
        }.resume()
    }
}
