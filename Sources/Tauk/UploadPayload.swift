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

// TODO: Finish upload
func upload(testResult: TestResult) {
    let jsonEncoder = JSONEncoder()
    let data = try? jsonEncoder.encode(UploadPayload(from: testResult))
    let string = String(data: data!, encoding: .utf8)!
}
