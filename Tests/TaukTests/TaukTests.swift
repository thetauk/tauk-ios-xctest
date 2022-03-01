import XCTest
@testable import Tauk

final class TaukPackageTest: TaukXCTestCase {
    
    override func setUpWithError() throws {
        taukSetUp(apiToken: "", projectId: "", appUnderTest: XCUIApplication.init())
    }
    
}
