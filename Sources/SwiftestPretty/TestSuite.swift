import Foundation

final class TestSuite {
  enum Status: String {
    case pending
    case passed
    case failed

    init?(_ rawValue: String) {
      switch rawValue {
        case "passed":
          self = .passed
        case "failed":
          self = .failed
        case "pending":
          self = .pending
        default:
          return nil
      }
    }
  }

  let name: String
  let startedAt: Date
  var status: Status = .pending
  var endedAt: Date?
  var cases: [TestCase] = []

  var testsCount: Int { cases.count }
  var failuresCount: Int { cases.filter { $0.result != .passed }.count }

  init(_ name: String, startedAt: String) {
    self.name = name
    self.startedAt = Formatter.shared.convert(startedAt)
  }

  func complete(withStatus status: Status, at endTime: String) {
    self.status = status
    self.endedAt = Formatter.shared.convert(endTime)
  }
}

private final class Formatter {
  static let shared = Formatter()
  let dateFormatter = DateFormatter()

  init() {
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss'.'SSS"
  }

  func convert(_ string: String) -> Date {
    return dateFormatter.date(from: string)!
  }
}
