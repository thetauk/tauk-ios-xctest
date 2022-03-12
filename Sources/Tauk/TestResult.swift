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
    var callerFilePath: String = ""
    var filename: String {
        return URL(fileURLWithPath: callerFilePath).lastPathComponent
    }
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
    var log: [LogEntry]?
    
    init(testName name: String, deviceInfo: DeviceInfo) {
        self.name = name
        self.deviceInfo = deviceInfo
        self.startTime = ProcessInfo.processInfo.systemUptime
    }
}
