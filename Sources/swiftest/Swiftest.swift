import ArgumentParser
import FileWatcher
import Foundation
import Rainbow
import SwiftestLib

private var testTimer: Timer?
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
      try execTest()
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

    try execTest()
    dispatchMain()
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

  func handleLine(_ line: String) {
    print("\("LINE:".dim.cyan) \(line)")
  }
}

// for putting in background, use DispatchQueue.global().async { }, @see https://stackoverflow.com/a/60044783/208770
