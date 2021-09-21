import XCTest

final class swiftestTests: XCTestCase {
  func testExample() throws {
    XCTAssertEqual(true, true)
    XCTAssertEqual(true, false)
    // testing handling fatal error...
    let foo: String? = nil
    XCTAssert(foo! == "bar")
  }
}
