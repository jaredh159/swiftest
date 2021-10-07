public class Parser {
  typealias SuiteName = String
  public var cwd: String
  public var summary: TestSummary? = nil

  var testSuites: [SuiteName: TestSuite] = [:]
  var testCaseFailures: [SuiteName: [TestCase.Failure]] = [:]

  // temp remove ... or not ???
  public var outputType: OutputType = OutputType.undefined

  public func parse(
    line: String,
    colored: Bool = true,
    additionalLines: @escaping () -> (String?)
  ) -> String? {
    switch line {
      case Matcher.testSuiteStartedMatcher:
        let groups = line.capturedGroups(with: .testSuiteStarted)
        let (suiteName, startedAt) = (groups[0], groups[1])
        guard !isMetaSuite(suiteName) else {
          return nil
        }
        testSuites[suiteName] = TestSuite(suiteName, startedAt: startedAt)
        outputType = .test
        return line.beautify(pattern: .testSuiteStarted)

      case Matcher.testSuiteFinishedMatcher:
        let groups = line.capturedGroups(with: .testSuiteFinished)
        let (suiteName, status, endedAt) = (groups[0], groups[1], groups[2])
        guard !isMetaSuite(suiteName) else {
          return nil
        }
        guard let suite = testSuites[suiteName] else {
          return nil
        }
        suite.complete(withStatus: .init(status)!, at: endedAt)
        return nil

      case Matcher.failingTestMatcher:
        let groups = line.capturedGroups(with: .failingTest)
        let (path, col, suite, name, msg) = (groups[0], groups[1], groups[2], groups[3], groups[4])
        var relPath = path
        if path.hasPrefix(cwd + "/") {
          relPath = String(relPath.dropFirst(cwd.count + 1))
        }

        let failure = TestCase.Failure(
          absolutePath: path,
          relativePath: relPath,
          columnNumber: Int(col)!,
          testName: name,
          message: msg
        )

        if testCaseFailures[suite] == nil {
          testCaseFailures[suite] = [failure]
        } else {
          testCaseFailures[suite]!.append(failure)
        }

        return failure.output()

      case Matcher.testCaseFinishedMatcher:
        let groups = line.capturedGroups(with: .testCaseFinished)
        let (suiteName, name, status, time) = (groups[0], groups[1], groups[2], groups[3])
        guard let suite = testSuites[suiteName] else {
          return nil
        }
        outputType = .test

        let result: TestCase.Result
        if status == "passed" {
          result = .passed
        } else {
          let failures = testCaseFailures[suiteName] ?? []
          result = .failed(failures)
        }

        suite.cases.append(TestCase(name: name, result: result, runTime: Double(time)!))
        return line.beautify(pattern: .testCaseFinished)

      // case Matcher.testCase

      case Matcher.executedMatcher, Matcher.testCaseStartedMatcher:
        return nil

      default:
        return line
    }
  }

  func isMetaSuite(_ suiteName: String) -> Bool {
    return suiteName == "All tests"
      || suiteName == "Selected tests"
      || suiteName.hasSuffix(".xctest")
  }

  func parseSummary(line: String, colored: Bool) {
    print(testSuites)
    let groups = line.capturedGroups(with: .executed)
    summary = TestSummary(
      testsCount: groups[0],
      failuresCount: groups[1],
      unexpectedCount: groups[2],
      time: groups[3]
    )
  }

  public init(cwd: String) {
    self.cwd = cwd
  }
}
