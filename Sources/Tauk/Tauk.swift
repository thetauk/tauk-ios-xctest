import Foundation
import XCTest

open class TaukXCTestCase: XCTestCase {
    private var apiToken: String?
    private var projectId: String?
    private var appUnderTest: XCUIApplication?
    private var customTestName: String?
    private var bundleId: String?
    private var testResult: TestResult?
    private var excluded: Bool = false
    private var callerFilePath: String = ""
    private var uploadTimeout: Double = 0.0
    private let inputPipe = Pipe() // Pipe to consume the messages on STDOUT and STDERR
    private let outputPipe = Pipe() // Pipe to output messages back to STDOUT
    private var logQueue: [LogEntry] = []
    
    
    open func taukInitialize(apiToken: String, projectId: String, appUnderTest: XCUIApplication, exclude: Bool? = false, uploadTimeoutSeconds: Double? = nil, customTestName: String? = nil, userProvidedBundleId: String? = Bundle.main.bundleIdentifier, callerFilePath: String = #filePath) {
        self.apiToken = apiToken
        self.projectId = projectId
        self.appUnderTest = appUnderTest
        self.customTestName = customTestName
        self.excluded = exclude ?? false
        self.uploadTimeout = uploadTimeoutSeconds ?? 4.0 // Default to 4.0 seconds
        self.callerFilePath = callerFilePath
        self.bundleId = userProvidedBundleId
        openConsolePipe()
    }
    
    private func getViewSource() -> String? {
        guard let app = self.appUnderTest else {
            print("WARNING: appUnderTest was not provided.")
            return nil
        }
        
        return getViewHierarchy(app: app)
    }
    
    private func getScreenshot() -> String? {
        guard let app = self.appUnderTest else {
            print("WARNING: appUnderTest was not provided.")
            return nil
        }
        
        return app.screenshot().pngRepresentation.base64EncodedString()
    }
    
    private func getLogEntries() -> [LogEntry] {
        // Return last 50 log entries
        if self.logQueue.count > 50 {
            return Array(self.logQueue[self.logQueue.count - 51 ... self.logQueue.count - 1])
        } else {
            return self.logQueue
        }
    }
    
    open override func record(_ issue: XCTIssue) {
        self.testResult?.status = .failed
        self.testResult?.error = TaukError(issue: issue, testMethodName: formatTestMethodName(rawNameString: self.name))
        self.testResult?.log = getLogEntries()
        self.testResult?.screenshot = getScreenshot()
        self.testResult?.viewSource = getViewSource()
        super.record(issue)
    }
    
    open override func setUpWithError() throws {
        try super.setUpWithError()
        // Handle if user has provided a custom test name
        let name = self.customTestName ?? formatTestMethodName(rawNameString: self.name)
        
        // Create TestResult instance
        self.testResult = TestResult(testName: name, deviceInfo: DeviceInfo(bundleId: self.bundleId))
    }
    
    open override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        guard let apiToken = self.apiToken else {
            print("WARNING: No API Token provided.")
            return
        }
        
        guard let projectId = self.projectId else {
            print("WARNING: No Project ID provided.")
            return
        }
        
        guard var testResult = self.testResult else {
            print("WARNING: A Tauk Test Result was not created.")
            return
        }
        
        testResult.endTime = ProcessInfo.processInfo.systemUptime
        testResult.callerFilePath = self.callerFilePath
        testResult.deviceInfo.bundleId = self.bundleId
        
        if testResult.log == nil {
            testResult.log = getLogEntries()
        }
        
        if testResult.screenshot == nil {
            testResult.screenshot = getScreenshot()
        }
        
        if testResult.viewSource == nil {
            testResult.viewSource = getViewSource()
        }
        
        if self.excluded == true {
            testResult.status = .excluded
        } else if testResult.status != .failed {
            testResult.status = .passed
        }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        TaukUpload.upload(apiToken: apiToken, projectId: projectId, testResult: testResult) { result in
            switch result {
            case .success(_):
                print("SUCCESS: Uploaded test result to Tauk")
                dispatchGroup.leave()
            case .failure(let error):
                print("WARNING: Failed to upload test result with error: \(error)")
                dispatchGroup.leave()
            }
        }
        _ = dispatchGroup.wait(timeout: .now() + self.uploadTimeout)
    }
    
    private func openConsolePipe() {
        let pipeReadHandler = inputPipe.fileHandleForReading
        
        // Copy the STDOUT file descriptor into outputPipe's file descriptor to send it back on the Xcode Console
        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
        
        // Copy the inputPipe's file descriptor into the STDOUT and STDERR file descriptors
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        
        // Listen to when the file handler reads data notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePipeNotification), name: FileHandle.readCompletionNotification, object: pipeReadHandler)
        
        // Notify of any data read coming across the pipe
        pipeReadHandler.readInBackgroundAndNotify()
    }
    
    @objc private func handlePipeNotification(notification: Notification) {
        inputPipe.fileHandleForReading.readInBackgroundAndNotify()
        
        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data, let logLine = String(data: data, encoding: String.Encoding.utf8) {
            outputPipe.fileHandleForWriting.write(data)
            
            if self.logQueue.count == 100 {
                self.logQueue.removeFirst(25)
                self.logQueue.append(LogEntry(date: Date(), message: logLine))
            } else {
                self.logQueue.append(LogEntry(date: Date(), message: logLine))
            }
        }
    }
}
