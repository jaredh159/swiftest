import ArgumentParser
import FileWatcher
import Foundation
import SwiftestPretty

private var testTask: DispatchWorkItem?
private var originalTerm: termios?

final class Swiftest: ParsableCommand {

  private var filter: String? = nil

  static var configurations = CommandConfiguration(
    abstract: "A utility for testing Swift projects",
    version: "1.0.0"
  )

  @Flag(name: .shortAndLong, help: "watch cwd for file changes and re-run tests")
  var watch = false

  func run() throws {
    let cwd = FileManager.default.currentDirectoryPath
    if !watch {
      TestRun().exec()
      return
    }

    let filewatcher = FileWatcher(["\(cwd)/Sources", "\(cwd)/Tests"])
    filewatcher.queue = DispatchQueue.global()
    filewatcher.callback = { [weak self] event in
      if event.path.hasSuffix(".swift") {
        self?.debouncedTest()
      }
    }
    filewatcher.start()

    runWatchModeTests(clearingFirst: false)

    enableRawMode()

    var char: UInt8 = 0
    while read(FileHandle.standardInput.fileDescriptor, &char, 1) == 1 {
      switch char {
        case "w":
          print("\r\("Watch Usage".bold)                          ")
          printWatchUsageLine("f", "to filter by a test name or suite name")
          printWatchUsageLine("q", "to quit watch mode")
          if filter != nil {
            printWatchUsageLine("Esc", "to exit filter mode")
          }
          printWatchUsageLine("Enter", "to trigger a test run")
        case "f":
          print("filter")
          clearTerminal()
          restoreRawMode()
          print("\nFilter Mode Usage".bold)
          printWatchUsageLine("Esc", "to exit filter mode")
          printWatchUsageLine("Enter", "to filter by a pattern")
          print("\n pattern > ".dim, terminator: "")
          fflush(stdout)
          filter = readLine()
          enableRawMode()
          runWatchModeTests(with: filter, clearingFirst: true)
        case "q":
          restoreRawMode()
          print("")
          Self.exit()
        case ENTER_KEY:
          runWatchModeTests(with: filter, clearingFirst: true)
        case ESC_KEY:
          filter = nil
          runWatchModeTests(clearingFirst: true)
        default:
          break
      }
    }

    dispatchMain()
  }

  private func printWatchUsageLine(_ key: String, _ desc: String) {
    print(" > Press".dim, key, desc.dim)
  }

  private func debouncedTest() {
    testTask?.cancel()
    testTask = DispatchWorkItem { runWatchModeTests(clearingFirst: true) }
    if let task = testTask {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
    }
  }
}

private func runWatchModeTests(with filter: String? = nil, clearingFirst: Bool = false) {
  if clearingFirst {
    clearTerminal()
  }
  TestRun(filter: filter).exec()
  printWatchUsagePrompt()
}

// https://stackoverflow.com/questions/49748507/listening-to-stdin-in-swift
private func initStruct<T>() -> T {
  let structPointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
  let structMemory = structPointer.pointee
  structPointer.deallocate()
  return structMemory
}

private func enableRawMode() {
  let stdin = FileHandle.standardInput
  var raw: termios = initStruct()
  tcgetattr(stdin.fileDescriptor, &raw)

  originalTerm = raw

  raw.c_lflag &= ~(UInt(ECHO | ICANON))
  tcsetattr(stdin.fileDescriptor, TCSAFLUSH, &raw)
}

private func restoreRawMode() {
  if var term = originalTerm {
    tcsetattr(FileHandle.standardInput.fileDescriptor, TCSAFLUSH, &term)
  }
}

private func printWatchUsagePrompt() {
  print("\("\nWatch Usage:".bold) \("Press".dim) w \("to show more.".dim)", terminator: "")
  fflush(stdout)  // required because of non-newline terminator
}

private func clearTerminal() {
  print("\u{001B}[2J\u{001B}[H")
}

extension UInt8 {
  func equals(_ string: String) -> Bool {
    guard let uint8 = Character(string).asciiValue else {
      return false
    }
    return uint8 == self
  }
}

func ~= (lhs: String, rhs: UInt8) -> Bool {
  guard let uint8 = Character(lhs).asciiValue else {
    return false
  }
  return uint8 == rhs
}

// @TODOS
// ...next...

// --filter/-f cli arg for init-ing with filter

// maybe reformat outputsummary to be more like jest:
/*
  Test Suites: 1 passed, 1 total
  Tests:       15 passed, 15 total
  Snapshots:   0 total
  Time:        1.996 s
  Ran all test suites.
 */

// rebuilder?

// reformat basic test failures for much greater glancability

// config?

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

private let ENTER_KEY: UInt8 = 10
private let ESC_KEY: UInt8 = 27
