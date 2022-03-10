import Foundation
import XCTest

public class TaukXCTestCase: XCTestCase {
    private var customTestName: String?
    private var apiToken: String?
    private var projectId: String?
    private var appUnderTest: XCUIApplication?
    private var testResult: TestResult?
    private var bundleId: String?
    private var excluded: Bool = false
    private var callerFilePath: String = ""
    let consoleOutput = OutputListener()
    
    func taukSetUp(apiToken: String, projectId: String, appUnderTest: XCUIApplication, exclude: Bool = false, customTestName: String? = nil, userProvidedBundleId: String? = Bundle.main.bundleIdentifier, callerFilePath: String = #filePath) {
        self.apiToken = apiToken
        self.projectId = projectId
        self.appUnderTest = appUnderTest
        self.customTestName = customTestName
        self.excluded = exclude
        self.callerFilePath = callerFilePath
        self.bundleId = userProvidedBundleId
    }
    
    // TODO: Optimize the speed of this method
    func getViewSource() -> String? {
        guard let app = self.appUnderTest else {
            print("WARNING: appUnderTest was not provided.")
            return nil
        }
        
        return getViewHierarchy(app: app)
    }
    
    func getScreenshot() -> String? {
        guard let app = self.appUnderTest else {
            print("WARNING: appUnderTest was not provided.")
            return nil
        }
        
        return app.screenshot().pngRepresentation.base64EncodedString()
    }
    
    public override func record(_ issue: XCTIssue) {
        self.testResult?.status = .failed
        self.testResult?.error = TaukError(issue: issue, testMethodName: formatTestMethodName(rawNameString: self.name))
        self.testResult?.screenshot = getScreenshot()
        self.testResult?.viewSource = getViewSource()
        super.record(issue)
    }
    
    public override func setUp() {
        // Start listening to STDOUT
        consoleOutput.openConsolePipe()
    }
    
    public override func setUpWithError() throws {
        try super.setUpWithError()
        // Handle if user has provided a custom test name
        let name = self.customTestName ?? formatTestMethodName(rawNameString: self.name)
        
        // Create TestResult instance
        self.testResult = TestResult(testName: name, deviceInfo: DeviceInfo(bundleId: self.bundleId))
    }
    
    public override func tearDownWithError() throws {
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
        
        // Stop listening to STDOUT
        consoleOutput.closeConsolePipe()
        
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
        _ = dispatchGroup.wait(timeout: .now() + 4.0)
        
//        let finalResult = testResult
//
//        // TODO: Add fallback if target is less than iOS 13
//        if #available(iOS 15.0, *) {
//            Task(priority: .background) {
//                try await upload(apiToken: apiToken, projectId: projectId, testResult: finalResult)
//            }
//        } else {
//            // old style upload
//        }
        
    }
}
