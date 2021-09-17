import ArgumentParser
import SwiftestLib

struct Swiftest: ParsableCommand {

  static var configurations = CommandConfiguration(
    abstract: "A utility for testing swift projects",
    version: "1.0.0"
  )

  mutating func run() throws {
    print(Foo().message)
  }
}
