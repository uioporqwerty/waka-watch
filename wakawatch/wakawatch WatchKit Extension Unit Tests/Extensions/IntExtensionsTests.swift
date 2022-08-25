import XCTest
@testable import Waka_Watch

class IntExtensionsTests: XCTestCase {

    func testIsSuccessfulHttpResponseCode_withSuccessfulResponseCodes_ReturnsTrue() throws {
        // Setup
        let successfulResponseCodes = [200, 249, 299]
        
        // Assert
        for code in successfulResponseCodes {
            XCTAssertTrue(code.isSuccessfulHttpResponseCode())
        }
    }
    
    func testIsSuccessfulHttpResponseCode_withUnsuccessfulResponseCodes_ReturnsFalse() throws {
        // Setup
        let unsuccessfulResponseCodes = [100, 308, 400, 500]
        
        // Assert
        for code in unsuccessfulResponseCodes {
            XCTAssertFalse(code.isSuccessfulHttpResponseCode())
        }
    }
}
