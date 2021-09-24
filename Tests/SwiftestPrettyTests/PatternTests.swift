import XCTest

@testable import SwiftestPretty

final class PatternTests: XCTestCase {

  func testExecuted() throws {
    let line = "   Executed 85 tests, with 0 failures (0 unexpected) in 0.026 (0.039) seconds"
    assertCaptured(.executed, line, ["85", "0", "0", "0.039"])
  }

  private func assertCaptured(
    _ pattern: SwiftestPretty.Pattern,
    _ input: String,
    _ expected: [String],
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertEqual(
      input.capturedGroups(with: pattern),
      expected,
      file: file,
      line: line
    )
  }
}
