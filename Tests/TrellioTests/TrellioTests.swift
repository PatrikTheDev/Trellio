import XCTest
@testable import Trellio

final class TrellioTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Trellio().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
