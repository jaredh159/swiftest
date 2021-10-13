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

  func exec() {
    let group = DispatchGroup()
    group.enter()

    let test: Process = Process()
    test.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    // test.arguments = ["test", "--filter", "Isolate"]
    test.arguments = ["test"]
    if let filter = filter {
      test.arguments! += ["--filter", filter]
    }
    test.currentDirectoryPath = parser.cwd

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
