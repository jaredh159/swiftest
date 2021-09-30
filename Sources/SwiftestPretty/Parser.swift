public class Parser {
  public var summary: TestSummary? = nil
  var testSuites: [String: TestSuite] = [:]

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

      case Matcher.testsRunCompletionMatcher:
        let groups = line.capturedGroups(with: .testsRunCompletion)
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
        let (file, suite, name, reason) = (groups[0], groups[1], groups[2], groups[3])
        print(file, suite, name, reason)
        return line

      case Matcher.testCasePassedMatcher:
        let groups = line.capturedGroups(with: .testCasePassed)
        let (suite, name, time) = (groups[0], groups[1], groups[2])
        guard let suite = testSuites[suite] else {
          return nil
        }
        outputType = .test
        suite.cases.append(TestCase(name: name, result: .passed, runTime: Double(time)!))
        return line.beautify(pattern: .testCasePassed)

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

  public init() {}
}
