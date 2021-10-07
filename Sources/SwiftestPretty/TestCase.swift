struct TestCase: Equatable {
  struct Failure: Equatable {
    let absolutePath: String
    let relativePath: String
    let columnNumber: Int
    let testName: String
    let message: String

    func output() -> String {
      "    \(TestStatus.fail.rawValue.red) \(testName)  \("\(relativePath):\(columnNumber)".dim)\n\(message)"
    }
  }

  enum Result: Equatable {
    case passed
    case failed([Failure])
  }

  let name: String
  let result: Result
  let runTime: Double
}
