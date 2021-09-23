import ArgumentParser
import FileWatcher
import Foundation
import Rainbow
import SwiftestPretty

private var testTask: DispatchWorkItem?

extension String {
  func withColor(_ color: Bool) -> String {
    return color ? self : self.clearColor.clearStyles.clearBackgroundColor
  }
}

final class Swiftest: ParsableCommand {

  static var configurations = CommandConfiguration(
    abstract: "A utility for testing Swift projects",
    version: "1.0.0"
  )

  @Flag(name: .shortAndLong, help: "watch cwd for file changes and re-run tests")
  var watch = false

  func run() throws {
    Rainbow.enabled = false
    print("Howdy".red.onYellow)
    // print("Plain text".red.onYellow.bold.clearColor.clearBackgroundColor.clearStyles)

    // if !watch {
    //   try execTest()
    //   return
    // }

    // let cwd = FileManager.default.currentDirectoryPath
    // let filewatcher = FileWatcher(["\(cwd)/Sources", "\(cwd)/Tests"])
    // filewatcher.queue = DispatchQueue.global()
    // filewatcher.callback = { [weak self] event in
    //   if event.path.hasSuffix(".swift") {
    //     self?.debouncedTest()
    //   }
    // }
    // filewatcher.start()

    // try execTest()
    // dispatchMain()
  }

  private func execTest() throws {
    let group = DispatchGroup()
    group.enter()

    let test: Process = Process()
    test.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    test.arguments = ["test"]
    test.currentDirectoryPath = FileManager.default.currentDirectoryPath

    let errPipe = Pipe()
    test.standardError = errPipe

    DispatchQueue.global(qos: .background).async { [weak self] in
      try? test.run()

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
      group.leave()
    }

    group.wait()
  }

  private func debouncedTest() {
    testTask?.cancel()

    testTask = DispatchWorkItem { [weak self] in
      try? self?.execTest()
    }

    if let task = testTask {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
    }
  }

  func handleLine(_ line: String) {
    // should probably not recreate this for every line, but just testing...
    let parser = Parser()
    let output = OutputHandler(quiet: false, quieter: false, isCI: false, { print($0) })
    guard let formatted = parser.parse(line: line, colored: true, additionalLines: { nil }) else {
      return
    }
    output.write(parser.outputType, formatted)
  }
}

// @TODOS
// ...next...
// 1) fork Xcbeautify (or maybe wait a bit, till it settles?)
// 2) prettify, and commit
// 3) rip out Colorizer, switch to Rainbow

// jest-style controls for isolating on the fly, re-running
// parsing the lines of test output ala xcbeautify
// getting test output from a handful of open source swift libraries
// configuration, yaml decodable, with `st init` to generate one
