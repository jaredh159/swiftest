struct Matcher {
  static let jaredMatcher = Regex(pattern: .jared)
  static let aggregateTargetMatcher = Regex(pattern: .aggregateTarget)
  static let analyzeMatcher = Regex(pattern: .analyze)
  static let analyzeTargetMatcher = Regex(pattern: .analyzeTarget)
  static let buildTargetMatcher = Regex(pattern: .buildTarget)
  static let checkDependenciesErrorsMatcher = Regex(pattern: .checkDependenciesErrors)
  static let checkDependenciesMatcher = Regex(pattern: .checkDependencies)
  static let clangErrorMatcher = Regex(pattern: .clangError)
  static let cleanRemoveMatcher = Regex(pattern: .cleanRemove)
  static let cleanTargetMatcher = Regex(pattern: .cleanTarget)
  static let codesignFrameworkMatcher = Regex(pattern: .codesignFramework)
  static let codesignMatcher = Regex(pattern: .codesign)
  static let compileCommandMatcher = Regex(pattern: .compileCommand)
  static let compileErrorMatcher = Regex(pattern: .compileError)
  static let compileMatcher = Regex(pattern: .compile)
  static let compileStoryboardMatcher = Regex(pattern: .compileStoryboard)
  static let compileWarningMatcher = Regex(pattern: .compileWarning)
  static let compileXibMatcher = Regex(pattern: .compileXib)
  static let copyHeaderMatcher = Regex(pattern: .copyHeader)
  static let copyPlistMatcher = Regex(pattern: .copyPlist)
  static let copyStringsMatcher = Regex(pattern: .copyStrings)
  static let cpresourceMatcher = Regex(pattern: .cpresource)
  static let cursorMatcher = Regex(pattern: .cursor)
  static let executedMatcher = Regex(pattern: .executed)
  static let failingTestMatcher = Regex(pattern: .failingTest)
  static let fatalErrorMatcher = Regex(pattern: .fatalError)
  static let fileMissingErrorMatcher = Regex(pattern: .fileMissingError)
  static let generateCoverageDataMatcher = Regex(pattern: .generateCoverageData)
  static let generatedCoverageReportMatcher = Regex(pattern: .generatedCoverageReport)
  static let generateDsymMatcher = Regex(pattern: .generateDsym)
  static let genericWarningMatcher = Regex(pattern: .genericWarning)
  static let ldErrorMatcher = Regex(pattern: .ldError)
  static let ldWarningMatcher = Regex(pattern: .ldWarning)
  static let libtoolMatcher = Regex(pattern: .libtool)
  static let linkerDuplicateSymbolsLocationMatcher = Regex(pattern: .linkerDuplicateSymbolsLocation)
  static let linkerDuplicateSymbolsMatcher = Regex(pattern: .linkerDuplicateSymbols)
  static let linkerUndefinedSymbolLocationMatcher = Regex(pattern: .linkerUndefinedSymbolLocation)
  static let linkerUndefinedSymbolsMatcher = Regex(pattern: .linkerUndefinedSymbols)
  static let linkingMatcher = Regex(pattern: .linking)
  static let moduleIncludesErrorMatcher = Regex(pattern: .moduleIncludesError)
  static let noCertificateMatcher = Regex(pattern: .noCertificate)
  static let packageGraphResolvingStart = Regex(pattern: .packageGraphResolvingStart)
  static let packageGraphResolvingEnded = Regex(pattern: .packageGraphResolvingEnded)
  static let packageGraphResolvedItem = Regex(pattern: .packageGraphResolvedItem)
  static let parallelTestCaseFailedMatcher = Regex(pattern: .parallelTestCaseFailed)
  static let parallelTestCasePassedMatcher = Regex(pattern: .parallelTestCasePassed)
  static let parallelTestCaseAppKitPassedMatcher = Regex(pattern: .parallelTestCaseAppKitPassed)
  static let parallelTestingStartedMatcher = Regex(pattern: .parallelTestingStarted)
  static let parallelTestingPassedMatcher = Regex(pattern: .parallelTestingPassed)
  static let parallelTestingFailedMatcher = Regex(pattern: .parallelTestingFailed)
  static let parallelTestSuiteStartedMatcher = Regex(pattern: .parallelTestSuiteStarted)
  static let pbxcpMatcher = Regex(pattern: .pbxcp)
  static let phaseScriptExecutionMatcher = Regex(pattern: .phaseScriptExecution)
  static let phaseSuccessMatcher = Regex(pattern: .phaseSuccess)
  static let podsErrorMatcher = Regex(pattern: .podsError)
  static let preprocessMatcher = Regex(pattern: .preprocess)
  static let processInfoPlistMatcher = Regex(pattern: .processInfoPlist)
  static let processPchCommandMatcher = Regex(pattern: .processPchCommand)
  static let processPchMatcher = Regex(pattern: .processPch)
  static let provisioningProfileRequiredMatcher = Regex(pattern: .provisioningProfileRequired)
  static let restartingTestsMatcher = Regex(pattern: .restartingTests)
  static let shellCommandMatcher = Regex(pattern: .shellCommand)
  static let symbolReferencedFromMatcher = Regex(pattern: .symbolReferencedFrom)
  static let testCaseMeasuredMatcher = Regex(pattern: .testCaseMeasured)
  static let testCasePassedMatcher = Regex(pattern: .testCasePassed)
  static let testCasePendingMatcher = Regex(pattern: .testCasePending)
  static let testCaseStartedMatcher = Regex(pattern: .testCaseStarted)
  static let testSuiteStartMatcher = Regex(pattern: .testSuiteStart)
  static let testSuiteStartedMatcher = Regex(pattern: .testSuiteStarted)
  static let testsRunCompletionMatcher = Regex(pattern: .testsRunCompletion)
  static let tiffutilMatcher = Regex(pattern: .tiffutil)
  static let touchMatcher = Regex(pattern: .touch)
  static let uiFailingTestMatcher = Regex(pattern: .uiFailingTest)
  static let undefinedSymbolLocationMatcher = Regex(pattern: .undefinedSymbolLocation)
  static let willNotBeCodeSignedMatcher = Regex(pattern: .willNotBeCodeSigned)
  static let writeAuxiliaryFilesMatcher = Regex(pattern: .writeAuxiliaryFiles)
  static let writeFileMatcher = Regex(pattern: .writeFile)
}