import ArgumentParser
import FileWatcher
import Foundation
import SwiftestPretty

private var testTask: DispatchWorkItem?

final class Swiftest: ParsableCommand {

  static var configurations = CommandConfiguration(
    abstract: "A utility for testing Swift projects",
    version: "1.0.0"
  )

  @Flag(name: .shortAndLong, help: "watch cwd for file changes and re-run tests")
  var watch = false

  func run() throws {
    if !watch {
      TestRun().exec()
      return
    }

    let cwd = FileManager.default.currentDirectoryPath
    let filewatcher = FileWatcher(["\(cwd)/Sources", "\(cwd)/Tests"])
    filewatcher.queue = DispatchQueue.global()
    filewatcher.callback = { [weak self] event in
      if event.path.hasSuffix(".swift") {
        self?.debouncedTest()
      }
    }
    filewatcher.start()

    TestRun().exec()
    dispatchMain()
  }

  private func debouncedTest() {
    testTask?.cancel()

    testTask = DispatchWorkItem {
      clearTerminal()
      TestRun().exec()
    }

    if let task = testTask {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
    }
  }
}

private func clearTerminal() {
  print("\u{001B}[2J\u{001B}[H")
}

// @TODOS
// ...next...

// basic idea:
// capture all of the testing info, letting test results pass through
// allow all other output...
// EXCEPT for "noise", which should be suppressed, but configurable
// ouput summary based on captured test

// option to not show invidiual tests
// don't show individual tests when running more than one test
// let through print() logging...
// jest-style controls for isolating on the fly, re-running
// parsing the lines of test output ala xcbeautify
// getting test output from a handful of open source swift libraries
// configuration, yaml decodable, with `st init` to generate one
