import Foundation
import Rainbow

extension String {
  // temp overload for now
  func beautify(pattern: Pattern) -> String? {
    return beautify(pattern: pattern, colored: true, additionalLines: { nil })
  }

  func beautify(pattern: Pattern, colored: Bool, additionalLines: @escaping () -> (String?))
    -> String?
  {
    switch pattern {
      case .tempAllow:
        return self
      case .jared:
        return formatFatalError(pattern: pattern)
      case .analyze:
        return formatAnalyze(pattern: pattern)
      case .compile:
        #if os(Linux)
          return formatCompileLinux(pattern: pattern)
        #else
          fallthrough
        #endif
      case .compileXib,
        .compileStoryboard:
        return formatCompile(pattern: pattern)
      case .compileCommand:
        return formatCompileCommand(pattern: pattern)
      case .buildTarget:
        return formatTargetCommand(command: "Build", pattern: pattern)
      case .analyzeTarget:
        return formatTargetCommand(command: "Analyze", pattern: pattern)
      case .aggregateTarget:
        return formatTargetCommand(command: "Aggregate", pattern: pattern)
      case .cleanTarget:
        return formatTargetCommand(command: "Clean", pattern: pattern)
      case .generateCoverageData,
        .generatedCoverageReport:
        return formatCodeCoverage(pattern: pattern)
      case .generateDsym:
        return formatGenerateDsym(pattern: pattern)
      case .libtool:
        return formatLibtool(pattern: pattern)
      case .linking:
        #if os(Linux)
          return formatLinkingLinux(pattern: pattern)
        #else
          return formatLinking(pattern: pattern)
        #endif
      case .testSuiteStarted,
        .parallelTestingStarted,
        .parallelTestingPassed,
        .parallelTestingFailed,
        .parallelTestSuiteStarted:
        return formatTestHeading(pattern: pattern)
      case .failingTest,
        .uiFailingTest,
        .restartingTests,
        .testCasePassed,
        .testCasePending,
        .testCaseMeasured,
        .testsRunCompletion,
        .parallelTestCasePassed,
        .parallelTestCaseAppKitPassed,
        .parallelTestCaseFailed:
        return formatTest(pattern: pattern)
      case .codesign:
        return format(command: "Signing", pattern: pattern)
      case .codesignFramework:
        return formatCodeSignFramework(pattern: pattern)
      case .copyHeader,
        .copyPlist,
        .copyStrings,
        .cpresource,
        .pbxcp:
        return formatCopy(pattern: pattern)
      case .checkDependencies:
        return format(command: "Check Dependencies", pattern: .checkDependencies, arguments: "")
      case .processInfoPlist:
        return formatProcessInfoPlist(pattern: .processInfoPlist)
      case .processPch:
        return formatProcessPch(pattern: pattern)
      case .touch:
        return formatTouch(pattern: pattern)
      case .phaseSuccess:
        let phase = capturedGroups(with: .phaseSuccess)[0].capitalized
        return "\(phase) Succeeded".bold.green
      case .phaseScriptExecution:
        return formatPhaseScriptExecution()
      case .preprocess:
        return format(command: "Preprocessing", pattern: pattern, arguments: "$1")
      case .processPchCommand:
        return formatProcessPchCommand(pattern: pattern)
      case .writeFile:
        return nil
      case .writeAuxiliaryFiles:
        return nil
      case .shellCommand:
        return nil
      case .cleanRemove:
        return formatCleanRemove(pattern: pattern)
      case .executed:
        return nil
      case .testCaseStarted:
        return nil
      case .tiffutil:
        return nil
      case .compileWarning:
        return formatCompileWarning(pattern: pattern, additionalLines: additionalLines)
      case .ldWarning:
        return formatLdWarning(pattern: pattern)
      case .genericWarning:
        return formatWarning(pattern: pattern)
      case .willNotBeCodeSigned:
        return formatWillNotBeCodesignWarning(pattern: pattern)
      case .clangError,
        .fatalError,
        .ldError,
        .podsError,
        .moduleIncludesError:
        return formatError(pattern: pattern)
      case .compileError:
        return formatCompileError(pattern: pattern, additionalLines: additionalLines)
      case .fileMissingError:
        return formatFileMissingError(pattern: pattern)
      case .checkDependenciesErrors:
        return formatError(pattern: pattern)
      case .provisioningProfileRequired:
        return formatError(pattern: pattern)
      case .noCertificate:
        return formatError(pattern: pattern)
      case .cursor:
        return nil
      case .linkerDuplicateSymbolsLocation:
        return nil
      case .linkerDuplicateSymbols:
        return formatLinkerDuplicateSymbolsError(pattern: pattern)
      case .linkerUndefinedSymbolLocation:
        return nil
      case .linkerUndefinedSymbols:
        return formatLinkerUndefinedSymbolsError(pattern: pattern)
      case .symbolReferencedFrom:
        return formatCompleteError()
      case .undefinedSymbolLocation:
        return formatCompleteWarning()
      case .packageGraphResolvingStart:
        return formatPackageStart()
      case .packageGraphResolvingEnded:
        return formatPackageEnd(pattern: pattern)
      case .packageGraphResolvedItem:
        return formatPackgeItem(pattern: pattern)
    }
  }

  // MARK: - Private

  private func formatTargetCommand(command: String, pattern: Pattern) -> String {
    let groups = capturedGroups(with: pattern)
    let target = groups[0]
    let project = groups[1]
    let configuration = groups[2]
    return "\(command) target \(target) of project \(project) with configuration \(configuration)"
      .bold.cyan
  }

  private func format(command: String, pattern: Pattern) -> String {
    let groups = capturedGroups(with: pattern)
    let sourceFile = groups[0]
    return command.bold + " " + sourceFile.lastPathComponent
  }

  private func format(command: String, pattern: Pattern, arguments: String) -> String? {
    let template = command.bold + " " + arguments

    guard
      let formatted =
        try? NSRegularExpression(pattern: pattern.rawValue)
        .stringByReplacingMatches(
          in: self,
          range: NSRange(location: 0, length: count),
          withTemplate: template)
    else {
      return nil
    }

    return formatted
  }

  private func formatFatalError(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    return "\("Fatal error:".white.onRed) \(groups[1].red) [\(groups[0].dim.white)]"
  }

  private func formatAnalyze(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let filename = groups[1]
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Analyzing".bold) \(filename)"
  }

  private func formatCleanRemove(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let directory = groups[0].lastPathComponent
    return "\("Cleaning".bold) \(directory)"
  }

  private func formatCodeSignFramework(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let frameworkPath = groups[0]
    return "\("Signing".bold) \(frameworkPath)"
  }

  private func formatProcessPch(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let filename = groups[0]
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Processing".bold) \(filename)"
  }

  private func formatProcessPchCommand(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    guard let filePath = groups.last else { return nil }
    return "\("Preprocessing".bold) \(filePath)"
  }

  private func formatCompileCommand(pattern: Pattern) -> String? {
    return nil
  }

  private func formatCompile(pattern: Pattern) -> String? {
    return innerFormatCompile(pattern: pattern, fileIndex: 1, targetIndex: 2)
  }

  private func formatCompileLinux(pattern: Pattern) -> String? {
    return innerFormatCompile(pattern: pattern, fileIndex: 1, targetIndex: 0)
  }

  private func innerFormatCompile(pattern: Pattern, fileIndex: Int, targetIndex: Int) -> String? {
    let groups = capturedGroups(with: pattern)
    let filename = groups[fileIndex]
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Compiling".bold) \(filename)"
  }

  private func formatCopy(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let filename = groups[0].lastPathComponent
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Copying".bold) \(filename)"
  }

  private func formatGenerateDsym(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let dsym = groups[0]
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Generating".bold) \(dsym)"
  }

  private func formatCodeCoverage(pattern: Pattern) -> String? {
    switch pattern {
      case .generateCoverageData:
        return "\("Generating".bold) code coverage data..."
      case .generatedCoverageReport:
        let filePath = capturedGroups(with: pattern)[0]
        return "\("Generated".bold) code coverage report: \(filePath.italic)"
      default:
        return nil
    }
  }

  private func formatLibtool(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let filename = groups[0]
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Building library".bold) \(filename)"
  }

  private func formatTouch(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let filename = groups[1]
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Touching".bold) \(filename)"
  }

  private func formatLinking(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let filename = groups[0].lastPathComponent
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Linking".bold) \(filename)"
  }

  private func formatLinkingLinux(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let target = groups[0]
    return "[\(target.cyan)] \("Linking".bold)"
  }

  private func formatPhaseScriptExecution() -> String? {
    let groups = capturedGroups(with: .phaseScriptExecution)
    let phaseName = groups[0]
    // Strip backslashed added by xcodebuild before spaces in the build phase name
    let strippedPhaseName = phaseName.replacingOccurrences(of: "\\ ", with: " ")
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Running script".bold) \(strippedPhaseName)"
  }

  private func formatTestHeading(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let testSuite = groups[0]

    switch pattern {
      case .testSuiteStarted,
        .parallelTestSuiteStarted:
        let deviceDescription = pattern == .parallelTestSuiteStarted ? " on '\(groups[1])'" : ""
        let heading = "Test Suite \(testSuite) started\(deviceDescription)"
        return heading.bold.cyan
      case .parallelTestingStarted:
        return self.bold.cyan
      case .parallelTestingPassed:
        return self.bold.green
      case .parallelTestingFailed:
        return self.bold.red
      default:
        return nil
    }
  }

  private func formatTest(pattern: Pattern) -> String? {
    let indent = "    "
    let groups = capturedGroups(with: pattern)

    switch pattern {
      case .testCasePassed:
        let testCase = groups[1]
        let time = groups[2]
        return indent + TestStatus.pass.rawValue.green + " " + testCase
          + " (\(time.coloredTime()) seconds)".dim.white
      case .failingTest:
        let testCase = groups[2]
        let failingReason = groups[3]
        return indent + TestStatus.fail.rawValue.red + " " + testCase + ", " + failingReason
      case .uiFailingTest:
        let file = groups[0]
        let failingReason = groups[1]
        return indent + TestStatus.fail.rawValue.red + " " + file + ", " + failingReason
      case .restartingTests:
        return self
      case .testCasePending:
        let testCase = groups[1]
        return indent + TestStatus.pending.rawValue.yellow + " " + testCase + " [PENDING]"
      case .testsRunCompletion:
        return nil
      case .testCaseMeasured:
        let testCase = groups[1]
        let time = groups[2]
        return indent + TestStatus.measure.rawValue.yellow + " " + testCase
          + " measured (\(time.coloredTime()) seconds)"
      case .parallelTestCasePassed:
        let testCase = groups[1]
        let device = groups[2]
        let time = groups[3]
        return indent + TestStatus.pass.rawValue.green + " " + testCase
          + " on '\(device)' (\(time.coloredTime()) seconds)"
      case .parallelTestCaseAppKitPassed:
        let testCase = groups[1]
        let time = groups[2]
        return indent + TestStatus.pass.rawValue.green + " " + testCase
          + " (\(time.coloredTime()) seconds)"
      case .parallelTestCaseFailed:
        let testCase = groups[1]
        let device = groups[2]
        let time = groups[3]
        return
          "    \(TestStatus.fail.rawValue.red) \(testCase) on '\(device)' (\(time.coloredTime()) seconds)"
      default:
        return nil
    }
  }

  private func formatError(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    guard let errorMessage = groups.first else { return nil }
    return Symbol.error.rawValue + " " + errorMessage.red
  }

  private func formatCompleteError() -> String? {
    return Symbol.error.rawValue + " " + self.red
  }

  private func formatCompileError(pattern: Pattern, additionalLines: @escaping () -> (String?))
    -> String?
  {
    let groups = capturedGroups(with: pattern)
    let filePath = groups[0]
    let reason = groups[2]

    // Read 2 additional lines to get the error line and cursor position
    let line: String = additionalLines() ?? ""
    let cursor: String = additionalLines() ?? ""
    return
      """
      \(Symbol.error.rawValue) \(filePath): \(reason.red)
      \(line)
      \(cursor.cyan)
      """
  }

  private func formatFileMissingError(pattern: Pattern) -> String {
    let groups = capturedGroups(with: pattern)
    let reason = groups[0]
    let filePath = groups[1]
    return "\(Symbol.error.rawValue) \(filePath): \(reason.red)"
  }

  private func formatWarning(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    guard let warningMessage = groups.first else { return nil }
    return Symbol.warning.rawValue + " " + warningMessage.yellow
  }

  private func formatCompleteWarning() -> String? {
    return Symbol.warning.rawValue + " " + self.yellow
  }

  private func formatCompileWarning(pattern: Pattern, additionalLines: @escaping () -> (String?))
    -> String?
  {
    let groups = capturedGroups(with: pattern)
    let filePath = groups[0]
    let reason = groups[2]

    // Read 2 additional lines to get the warning line and cursor position
    let line: String = additionalLines() ?? ""
    let cursor: String = additionalLines() ?? ""
    return
      """
      \(Symbol.warning.rawValue)  \(filePath): \(reason.yellow)
      \(line)
      \(cursor.green)
      """
  }

  private func formatLdWarning(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let prefix = groups[0]
    let message = groups[1]
    return "\(Symbol.warning.rawValue) \(prefix.yellow)\(message.yellow)"
  }

  private func formatProcessInfoPlist(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let plist = groups[1]

    // Xcode 9 output
    if groups.count == 2 {
      return "Processing".bold + " " + plist
    }

    // Xcode 10+ output
    guard let target = groups.last else { return nil }
    return "[\(target.cyan)] \("Processing".bold) \(plist)"
  }

  // TODO: Print symbol and reference location
  private func formatLinkerUndefinedSymbolsError(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let reason = groups[0]
    return "\(Symbol.error.rawValue) \(reason.red)"
  }

  // TODO: Print file path
  private func formatLinkerDuplicateSymbolsError(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let reason = groups[0]
    return "\(Symbol.error.rawValue) \(reason.red)"
  }

  private func formatWillNotBeCodesignWarning(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    guard let warningMessage = groups.first else { return nil }
    return Symbol.warning.rawValue + " " + warningMessage.yellow
  }

  private func formatSummary() -> String? {
    return self.green.bold
  }

  private func coloredTime() -> String {
    guard let time = Double(self) else { return self }
    if time < 0.025 { return self }
    if time < 0.100 { return self.bold.yellow }
    return self.bold.red
  }

  private func formatPackageStart() -> String? {
    return self.bold.cyan
  }

  private func formatPackageEnd(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let ended = groups[0]
    return ended.bold.green
  }

  private func formatPackgeItem(pattern: Pattern) -> String? {
    let groups = capturedGroups(with: pattern)
    let name = groups[0]
    let url = groups[1]
    let version = groups[2]
    return name.bold.cyan + " - " + url.bold + " @ " + version.green
  }
}
