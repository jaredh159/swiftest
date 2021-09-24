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
      TestRun().exec()
    }

    if let task = testTask {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
    }
  }
}

// @TODOS
// ...next...

// jest-style controls for isolating on the fly, re-running
// parsing the lines of test output ala xcbeautify
// getting test output from a handful of open source swift libraries
// configuration, yaml decodable, with `st init` to generate one
