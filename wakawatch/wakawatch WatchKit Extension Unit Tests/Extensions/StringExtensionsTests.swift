import XCTest
@testable import Waka_Watch

final class StringExtensionsTests: XCTestCase {

    func testTrim_withTrailingAndLeadingSpaces_ReturnsTrimmed() throws {
        // Setup
        let testString = "  hello world  "
        
        // Assert
        XCTAssertEqual(testString.trim(), "hello world")
    }
    
    func testTrim_withNewLine_ReturnTrimmed() throws {
        // Setup
        let testString = "hello world\n"
        
        // Assert
        XCTAssertEqual(testString.trim(), "hello world")
    }
    
    func testReplaceArgs_WithArg_ReturnsStringWithArgsReplaced() throws {
        // Setup
        let testString = "hello {0}"
        
        // Act
        let newString = testString.replaceArgs("nitish")
        
        // Assert
        XCTAssertEqual(newString, "hello nitish")
    }
}
