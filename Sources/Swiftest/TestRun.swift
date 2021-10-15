import Foundation
import SwiftestPretty

struct TestRun {
  var filter: String? = nil
  let parser: Parser
  let output = OutputHandler(quiet: false, quieter: false, isCI: false, { print($0) })

  init(cwd: String? = nil, filter: String? = nil) {
    parser = Parser(cwd: cwd ?? FileManager.default.currentDirectoryPath)
    self.filter = filter
  }

  func exec(onComplete: ((TestSummary?) -> Void)? = nil) {
    let group = DispatchGroup()
    group.enter()

    let test: Process = Process()
    test.environment = ["SWIFT_DETERMINISTIC_HASHING": "1"]  // @TODO configurable
    test.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    test.arguments = ["test"]
    if let filter = filter {
      test.arguments! += ["--filter", filter]
    }
    test.currentDirectoryPath = parser.cwd

    let errPipe = Pipe()
    test.standardError = errPipe

    DispatchQueue.global(qos: .default).async {
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
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        print(summary.format())
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      onComplete?(parser.summary)
    }
  }

  func handleLine(_ line: String) {
    let formatted = parser.parse(line: line, colored: true, additionalLines: { nil })
    if let formatted = formatted {
      output.write(parser.outputType, formatted)
    }
  }
}
