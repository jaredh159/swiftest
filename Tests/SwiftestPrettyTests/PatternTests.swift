import XCTest

@testable import SwiftestPretty

final class PatternTests: XCTestCase {

  func testExecuted() throws {
    let line = "   Executed 85 tests, with 0 failures (0 unexpected) in 0.026 (0.039) seconds"
    assertCaptured(.executed, line, ["85", "0", "0", "0.039"])
  }

  func testPassingTestMacAndLinux() throws {
    let macOS = #"Test Case '-[FooTests.FooTests testFoobar]' passed (0.007 seconds)."#
    assertCaptured(.testCasePassed, macOS, ["FooTests", "testFoobar", "0.007"])

    let linux = #"Test Case 'FooTests.testFoobar' passed (0.342 seconds)"#
    assertCaptured(.testCasePassed, linux, ["FooTests", "testFoobar", "0.342"])
  }

  func testFailingTest() throws {
    let linux =
      #"/home/jared/deploy/staging/Tests/AppTests/Token+ResolverTests.swift:38: error: TokenResolverTests.testTokenByValue : XCTAssertEqual failed: ("1") is not equal to ("2") -"#

    assertCaptured(
      .failingTest,
      linux,
      [
        "/home/jared/deploy/staging/Tests/AppTests/Token+ResolverTests.swift",
        "38",
        "TokenResolverTests",
        "testTokenByValue",
        #"XCTAssertEqual failed: ("1") is not equal to ("2") -"#,
      ])

    let macOS =
      #"Users/jared/jaredh159/Swiftest/Tests/SwiftestPrettyTests/ParserTests.swift:35: error: -[SwiftestPrettyTests.SwiftestPrettyTests testTestSuiteStartCreatesTestSuite] : XCTAssertEqual failed: ("18.280") is not equal to ("x18.280")"#

    assertCaptured(
      .failingTest,
      macOS,
      [
        "Users/jared/jaredh159/Swiftest/Tests/SwiftestPrettyTests/ParserTests.swift",
        "35",
        "SwiftestPrettyTests",
        "testTestSuiteStartCreatesTestSuite",
        #"XCTAssertEqual failed: ("18.280") is not equal to ("x18.280")"#,
      ])
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

/* Linux failing test ouput:

Test Suite 'Selected tests' started at 2021-09-29 08:17:42.047
Test Suite 'TokenResolverTests' started at 2021-09-29 08:17:42.089
Test Case 'TokenResolverTests.testTokenByValue' started at 2021-09-29 08:17:42.089
2021-09-29T08:17:42-0400 notice codes.vapor.application : App environment is `testing`
2021-09-29T08:17:42-0400 info codes.vapor.request : request-id=EF395938-D3D8-4321-B557-C51968AACE79 POST /graphql
/home/jared/deploy/staging/.build/checkouts/vapor-utils/Sources/XCTVaporUtils/GraphQLTestCase.swift:98: error: TokenResolverTests.testTokenByValue : XCTAssertTrue failed - {"data":{"getTokenByValue":{"description":"test","id":"331BA3F8-194F-4DE0-BD79-A1FC6138D8D7","scopes":[{"scope":"queryOrders"}],"value":"0A9B1FC4-8120-4F3C-9346-900455C8F151"}}} does not contain "description":"Xtest"
/home/jared/deploy/staging/Tests/AppTests/Token+ResolverTests.swift:38: error: TokenResolverTests.testTokenByValue : XCTAssertEqual failed: ("1") is not equal to ("2") -
Test Case 'TokenResolverTests.testTokenByValue' failed (0.235 seconds)
Test Suite 'TokenResolverTests' failed at 2021-09-29 08:17:42.325
	 Executed 1 test, with 2 failures (0 unexpected) in 0.235 (0.235) seconds
Test Suite 'Selected tests' failed at 2021-09-29 08:17:42.325
	 Executed 1 test, with 2 failures (0 unexpected) in 0.235 (0.235) seconds

*/

/* Linux passing test output:

Test Suite 'Selected tests' started at 2021-09-29 08:15:37.814
Test Suite 'TokenResolverTests' started at 2021-09-29 08:15:37.857
Test Case 'TokenResolverTests.testTokenByValue' started at 2021-09-29 08:15:37.857
2021-09-29T08:15:38-0400 notice codes.vapor.application : App environment is `testing`
2021-09-29T08:15:38-0400 info codes.vapor.request : request-id=175B53DF-2798-4292-83E8-8B022B666784 POST /graphql
Test Case 'TokenResolverTests.testTokenByValue' passed (0.342 seconds)
Test Suite 'TokenResolverTests' passed at 2021-09-29 08:15:38.199
	 Executed 1 test, with 0 failures (0 unexpected) in 0.342 (0.342) seconds
Test Suite 'Selected tests' passed at 2021-09-29 08:15:38.200
	 Executed 1 test, with 0 failures (0 unexpected) in 0.342 (0.342) seconds

*/
