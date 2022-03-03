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
    let consoleOutput = OutputListener()
    
    func taukSetUp(apiToken: String, projectId: String, appUnderTest: XCUIApplication, exclude: Bool = false, customTestName: String? = nil, userProvidedBundleId: String? = nil) {
        self.apiToken = apiToken
        self.projectId = projectId
        self.appUnderTest = appUnderTest
        self.customTestName = customTestName
        self.bundleId = userProvidedBundleId ?? Bundle.main.bundleIdentifier
        self.excluded = exclude
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
        self.testResult = TestResult(testName: name, filename: #file, deviceInfo: DeviceInfo(bundleId: self.bundleId))
    }
    
    public override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        guard var testResult = self.testResult else {
            print("WARNING: A Tauk Test Result was not created.")
            return
        }
        
        testResult.endTime = ProcessInfo.processInfo.systemUptime
        
        if testResult.screenshot == nil {
            testResult.screenshot = getScreenshot()
        }
        
        if self.excluded == true {
            testResult.status = .excluded
        } else if testResult.status != .failed {
            testResult.status = .passed
        }
        
        // Stop listening to STDOUT
        consoleOutput.closeConsolePipe()
        
        // TODO: Call upload() function
        
    }
}
