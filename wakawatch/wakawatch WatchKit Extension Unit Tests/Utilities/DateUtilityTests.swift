import XCTest
@testable import Waka_Watch

final class DateUtilityTests: XCTestCase {

    func testGetChartDate_withValidDate_ReturnsChartDate() throws {
        // Setup
        let date = "2022-06-05"
        
        // Assert
        XCTAssertEqual(DateUtility.getChartDate(date: date), "Jun. 5")
    }
    
    func testGetChartDate_withInvalidDate_ReturnsEmptyString() throws {
        // Setup
        let date = ""
        
        // Assert
        XCTAssertEqual(DateUtility.getChartDate(date: date), "")
    }
}
