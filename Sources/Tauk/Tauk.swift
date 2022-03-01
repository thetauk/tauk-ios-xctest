import Foundation
import XCTest

public class TaukXCTestCase: XCTestCase {
    public var customTestName: String?
    public var apiToken: String?
    public var projectId: String?
    public var appUnderTest: XCUIApplication?
    private var testResult: TestResult?
    public var userProvidedBundleId: String?
    let consoleOutput = OutputListener()
    
    func taukSetUp(apiToken: String, projectId: String, appUnderTest: XCUIApplication, customTestName: String? = nil, bundleId: String? = nil) {
        self.apiToken = apiToken
        self.projectId = projectId
        self.appUnderTest = appUnderTest
        self.customTestName = customTestName
        self.userProvidedBundleId = bundleId ?? Bundle.main.bundleIdentifier
    }
    
    // TODO: Optimize the speed of this method
    func getViewSource() -> String? {
        guard let app = self.appUnderTest else {
            print("ERROR: appUnderTest not defined.")
            return nil
        }
        
        return getViewHierarchy(app: app)
    }
    
    func getScreenshot() -> String? {
        guard let app = self.appUnderTest else {
            print("ERROR: appUnderTest not defined.")
            return nil
        }
        
        return app.screenshot().pngRepresentation.base64EncodedString()
    }
    
    // TODO: Implement logic to handle the issue that occurred during the test
    public override func record(_ issue: XCTIssue) {
        print("ERROR OBSERVED!")
        print("API TOKEN: \(self.apiToken!)")
        print("PROJECT ID: \(self.projectId!)")
        print("DEVICE: \(getDeviceInformation())")
        super.record(issue)
        
        // TODO: Get error object and source code lines
    }
    
    public override func setUp() {
        // Start listening to STDOUT
        consoleOutput.openConsolePipe()
    }
    
    public override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create TestResult instance
        self.testResult = TestResult(testName: formatTestMethodName(rawNameString: self.name), filename: #file, initialTags: getDeviceInformation())
        
        // Handle if user has provided a Bundle ID
        if var testResult = self.testResult, let userProvidedBundleId = self.userProvidedBundleId {
            if testResult.tags["bundleId"] == nil {
                testResult.tags["bundleId"] = userProvidedBundleId
            }
        }
    }
    
    public override func tearDownWithError() throws {
        try super.tearDownWithError()
//        if var testResult = self.testResult {
//            testResult.endTime = ProcessInfo.processInfo.systemUptime
//            print("TIME TAKEN: \(testResult.calcElapsedTimeMilliseconds()!)")
//            
//            testResult.screenshot = self.getScreenshot()
//        }
        guard var testResult = self.testResult else {
            print("ERROR: A Test Result was not created.")
            return
        }
        
        testResult.endTime = ProcessInfo.processInfo.systemUptime
        print("TIME TAKEN: \(testResult.calcElapsedTimeMilliseconds()!)")
        testResult.screenshot = self.getScreenshot()
        
        // Stop listening to STDOUT
        consoleOutput.closeConsolePipe()
        
        // TODO: Call upload() function
        
    }
}
