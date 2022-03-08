import Foundation

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
    // TODO: add log
    
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
    }
    
    enum CodingKeys: String, CodingKey {
        case testStatus = "test_status"
        case testName = "test_name"
        case testFilename = "test_filename"
        case tags = "tags"
        case screenshot = "screenshot"
        case view = "view"
        case error = "error"
        case codeContext = "code_context"
        case automationType = "automation_type"
        case language = "language"
        case platform = "platform"
        case platformVersion = "platform_version"
        case elapsedTimeMs = "elapsed_time_ms"
    }
}

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum RequestError: Error {
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unableToDecode
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noResponse:
            return "No response"
        case .unauthorized:
            return "Unauthorized"
        case .unexpectedStatusCode:
            return "Unexpected Status Code"
        case .unableToDecode:
            return "Unable to Decode"
        case .unknown:
            return "Unknown Error"
        }
    }
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
}

struct HostedUploadEndpoint: Endpoint {
    var method: RequestMethod
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

func upload(apiToken: String, projectId: String, testResult: TestResult) async throws {
    let endpoint = HostedUploadEndpoint(apiToken: apiToken, projectId: projectId)
    guard let url = URL(string: "\(endpoint.baseURL)\(endpoint.path)") else {
        print("WARNING: \(RequestError.invalidURL.message) for upload.")
        return
    }
    
    let payload = try? JSONEncoder().encode(UploadPayload(from: testResult))
    
    do {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        request.httpBody = payload
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // TODO: Create fallback non async/await URLSession if target is less than iOS 15
        let (_, response) = try await URLSession.shared.data(for: request, delegate: nil)
        guard let response = response as? HTTPURLResponse else {
            print("WARNING: \(RequestError.noResponse.message)")
            return
        }
        
        switch response.statusCode {
        case 401:
            print("WARNING: \(RequestError.unauthorized.message).")
        default:
            print("WARNING: \(RequestError.unexpectedStatusCode.message).")
        }
    } catch {
        print("WARNING: \(RequestError.unknown.message).")
    }
}
