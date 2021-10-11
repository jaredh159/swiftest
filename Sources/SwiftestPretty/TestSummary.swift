import Foundation

public struct TestSummary {
  let testsCount: Int
  let failuresCount: Int
  let unexpectedCount: Int
  let time: Double
}

extension TestSummary {
  var isSuccess: Bool {
    failuresCount == 0
  }

  var description: String {
    return "\(failuresCount) failed, \(testsCount) total (\(time.pretty) seconds)"
  }

  public func format() -> String {
    if isSuccess {
      return "Tests Passed: \(description)".bold.green
    } else {
      return "Tests Failed: \(description)".bold.red
    }
  }
}

extension Double {
  var pretty: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 3
    formatter.maximumFractionDigits = 4
    return formatter.string(from: NSNumber(value: self))!
  }
}
