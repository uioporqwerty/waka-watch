import XCTest
@testable import Waka_Watch

final class TimeIntervalExtensionsTests: XCTestCase {

    func testMinute_withTotalSeconds_ReturnsProperMinutes() throws {
        // Setup
        let totalSeconds = 120.50
        
        // Assert
        XCTAssertEqual(totalSeconds.minute, 2)
    }
    
    func testHour_withTotalSeconds_ReturnsProperHours() throws {
        // Setup
        let totalSeconds = 3600.50
        
        // Assert
        XCTAssertEqual(totalSeconds.hour, 1)
    }
}
