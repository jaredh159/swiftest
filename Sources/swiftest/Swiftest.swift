import ArgumentParser
import Foundation
import SwiftestLib

final class Swiftest: ParsableCommand {

  static var configurations = CommandConfiguration(
    abstract: "A utility for testing Swift projects",
    version: "1.0.0"
  )

  func run() throws {
    let test = Process()
    test.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    test.arguments = ["test"]
    test.currentDirectoryPath = FileManager.default.currentDirectoryPath

    let errPipe = Pipe()
    test.standardError = errPipe
    try test.run()

    var currentLineErr: String = ""
    errPipe.fileHandleForReading.readabilityHandler = { [weak self] pipe in
      if let line = String(data: pipe.availableData, encoding: .utf8) {
        for char in line {
          if char == "\n" {
            self?.handleLine(currentLineErr)
            currentLineErr = ""
          } else {
            currentLineErr += String(char)
          }
        }
      }
    }
    test.waitUntilExit()
  }

  func handleLine(_ line: String) {
    print("LINE: \(line)")
  }
}
