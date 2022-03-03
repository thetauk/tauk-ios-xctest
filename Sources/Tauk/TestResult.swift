import Foundation

enum TestStatus: String {
    case passed
    case failed
    case excluded
    case resolved
    case undetermined
}

struct TestResult {
    var status: TestStatus = .undetermined
    let name: String
    let filename: String
    var deviceInfo: DeviceInfo
    var screenshot: String?
    var viewSource: String?
    let startTime: TimeInterval
    var endTime: TimeInterval?
    var elapsedTimeMilliseconds: Int? {
        guard let endTime = endTime else {
            return nil
        }
        return Int((endTime - startTime) * 1000)
    }
    var error: TaukError?
    
    init(testName name: String, filename: String, deviceInfo: DeviceInfo) {
        self.name = name
        self.filename = filename
        self.deviceInfo = deviceInfo
        self.startTime = ProcessInfo.processInfo.systemUptime
    }
}
