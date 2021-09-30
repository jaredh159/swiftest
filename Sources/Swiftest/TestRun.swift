import Foundation
import SwiftestPretty

struct TestRun {
  let parser = Parser()
  let output = OutputHandler(quiet: false, quieter: false, isCI: false, { print($0) })

  func exec() {
    let group = DispatchGroup()
    group.enter()

    let test: Process = Process()
    test.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    test.arguments = ["test", "--filter", "testTestSuiteStartCreatesTestSuite"]
    test.currentDirectoryPath = FileManager.default.currentDirectoryPath

    let errPipe = Pipe()
    test.standardError = errPipe

    DispatchQueue.global(qos: .background).async {
      try? test.run()

      var currentLine: String = ""
      errPipe.fileHandleForReading.readabilityHandler = { pipe in
        if let line = String(data: pipe.availableData, encoding: .utf8) {
          // @TODO: this is NOT optimal...
          for char in line {
            if char == "\n" {
              handleLine(currentLine)
              currentLine = ""
            } else {
              currentLine += String(char)
            }
          }
        }
      }
      test.waitUntilExit()
      group.leave()
    }

    group.wait()
    if let summary = parser.summary {
      // TODO, this sometimes prints NOT last...
      print(summary.format())
    }
  }

  func handleLine(_ line: String) {
    let formatted = parser.parse(line: line, colored: true, additionalLines: { nil })
    if let formatted = formatted {
      // print(formatted)
      output.write(parser.outputType, formatted)
    }
  }
}
