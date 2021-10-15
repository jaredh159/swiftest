import Rainbow
import XCTest

@testable import SwiftestPretty

final class ParserTests: XCTestCase {
  var parser = Parser(cwd: "/test/cwd")

  func testTestSuiteStartCreatesTestSuite() throws {
    parseLine("Test Suite 'OutputHandlerTests' started at 2021-09-27 08:46:18.280")
    let suite = parser.testSuites["OutputHandlerTests"]
    XCTAssertNotNil(suite)
    XCTAssertEqual(suite!.name, "OutputHandlerTests")

    let df = DateFormatter()
    df.dateFormat = "ss.SSS"
    XCTAssertEqual(df.string(from: suite!.startedAt), "18.280")
  }

  func testTestCasesAddedToTestSuite() throws {
    parseLine("Test Suite 'FooTests' started at 2021-09-27 08:46:18.280")
    parseLine("Test Case '-[FooTests.FooTests testFoobar]' passed (0.007 seconds).")
    parseLine("Test Suite 'FooTests' passed at 2021-09-27 08:46:18.287.")
    let suite = parser.testSuites["FooTests"]!
    XCTAssertEqual(suite.cases.count, 1)
    XCTAssertEqual(suite.cases[0], TestCase(name: "testFoobar", result: .passed, runTime: 0.007))
  }

  func testFailedTestCaseAddedToSuite() throws {
    parseLine("Test Suite 'FooTests' started at 2021-09-27 08:46:18.280")
    parseLine(#"/test/cwd/Tests/FooTests/FoobarTests.swift:3: error: FooTests.testFoo : failed"#)
    parseLine("Test Case 'FooTests.testFoo' failed (0.007 seconds)")
    parseLine("Test Suite 'FooTests' failed at 2021-09-27 08:46:18.287.")
    let suite = parser.testSuites["FooTests"]!
    XCTAssertEqual(suite.cases.count, 1)

    let failure = TestCase.Failure(
      absolutePath: "/test/cwd/Tests/FooTests/FoobarTests.swift",
      relativePath: "Tests/FooTests/FoobarTests.swift",
      columnNumber: 3,
      testName: "testFoo",
      message: "failed"
    )

    XCTAssertEqual(
      suite.cases[0],
      TestCase(name: "testFoo", result: .failed([failure]), runTime: 0.007)
    )
  }

  func testFilteredOutput() throws {
    parse(
      """
      Test Suite 'Selected tests' started at 2021-10-15 08:12:43.676
      Test Suite 'SwiftestPackageTests.xctest' started at 2021-10-15 08:12:43.676
      Test Suite 'PatternTests' started at 2021-10-15 08:12:43.676
      Test Case '-[SwiftestPrettyTests.PatternTests testTouch]' started.
      Test Case '-[SwiftestPrettyTests.PatternTests testTouch]' passed (0.004 seconds).
      Test Suite 'PatternTests' passed at 2021-10-15 08:12:43.680.
               Executed 1 test, with 0 failures (0 unexpected) in 0.004 (0.004) seconds
      Test Suite 'SwiftestPackageTests.xctest' passed at 2021-10-15 08:12:43.680.
               Executed 1 test, with 0 failures (0 unexpected) in 0.004 (0.004) seconds
      Test Suite 'Selected tests' passed at 2021-10-15 08:12:43.680.
               Executed 1 test, with 0 failures (0 unexpected) in 0.004 (0.004) seconds 
      """
    )
    XCTAssertNotNil(parser.summary)
    XCTAssertEqual(parser.testSuites.count, 1)
  }

  override class func setUp() {
    Rainbow.enabled = false
  }

  override func setUp() {
    parser = Parser(cwd: "/test/cwd")
  }

  private func assertParsed(
    _ input: String,
    _ expected: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertEqual(parseLine(input), expected, file: file, line: line)
  }

  @discardableResult
  private func parseLine(_ string: String) -> String? {
    return parser.parse(line: string, colored: false, additionalLines: { nil })
  }

  @discardableResult
  private func parse(_ lines: [String]) -> [String?] {
    return lines.map(parseLine)
  }

  @discardableResult
  private func parse(_ block: String) -> [String?] {
    parse(block.split(separator: "\n").map(String.init))
  }
}
