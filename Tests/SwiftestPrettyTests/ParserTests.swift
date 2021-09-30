import Rainbow
import XCTest

@testable import SwiftestPretty

final class SwiftestPrettyTests: XCTestCase {
  let parser = Parser()

  override class func setUp() {
    Rainbow.enabled = false
  }

  private func assertParsed(
    _ input: String,
    _ expected: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertEqual(parseLine(input), expected, file: file, line: line)
  }

  @discardableResult
  private func parseLine(_ string: String) -> String? {
    return parser.parse(line: string, colored: false, additionalLines: { nil })
  }

  func testTestSuiteStartCreatesTestSuite() {
    parseLine("Test Suite 'OutputHandlerTests' started at 2021-09-27 08:46:18.280")
    let suite = parser.testSuites["OutputHandlerTests"]
    XCTAssertNotNil(suite)
    XCTAssertEqual(suite!.name, "OutputHandlerTests")

    let df = DateFormatter()
    df.dateFormat = "ss.SSS"
    XCTAssertEqual(df.string(from: suite!.startedAt), "x18.280")
  }

  func testFatalErrorNew() throws {
    assertParsed(
      "swiftestTests/swiftestTests.swift:9: Fatal error: Unexpectedly found nil while unwrapping an Optional value",
      "Fatal error: Unexpectedly found nil while unwrapping an Optional value [swiftestTests/swiftestTests.swift:9]"
    )
  }

  func testAggregateTarget() throws {
    assertParsed(
      "=== BUILD AGGREGATE TARGET Be Aggro OF PROJECT AggregateExample WITH CONFIGURATION Debug ===",
      "Aggregate target Be Aggro of project AggregateExample with configuration Debug"
    )
  }

  func testAnalyze() throws {
    assertParsed(
      "AnalyzeShallow /Users/admin/CocoaLumberjack/Classes/DDTTYLogger.m normal x86_64 (in target: CocoaLumberjack-Static)",
      "[CocoaLumberjack-Static] Analyzing DDTTYLogger.m"
    )
  }

  func testAnalyzeTarget() throws {
    assertParsed(
      "=== ANALYZE TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===",
      "Analyze target The Spacer of project Pods with configuration Debug"
    )
  }

  func testBuildTarget() throws {
    assertParsed(
      "=== BUILD TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===",
      "Build target The Spacer of project Pods with configuration Debug"
    )
  }

  func testCheckDependenciesErrors() throws {
  }

  func testCheckDependencies() throws {
  }

  func testClangError() throws {
    assertParsed(
      "clang: error: linker command failed with exit code 1 (use -v to see invocation)",
      "\(Symbol.error.rawValue) clang: error: linker command failed with exit code 1 (use -v to see invocation)"
    )
  }

  func testCleanRemove() throws {
    assertParsed(
      "Clean.Remove clean /Users/admin/Library/Developer/Xcode/DerivedData/MyLibrary-abcd/Build/Intermediates/MyLibrary.build/Debug-iphonesimulator/MyLibraryTests.build",
      "Cleaning MyLibraryTests.build"
    )
  }

  func testCleanTarget() throws {
    assertParsed(
      "=== ANALYZE TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===",
      "Analyze target The Spacer of project Pods with configuration Debug"
    )
  }

  func testCodesignFramework() throws {
    assertParsed(
      "CodeSign build/Release/MyFramework.framework/Versions/A",
      "Signing build/Release/MyFramework.framework"
    )
  }

  func testCodesign() throws {
    assertParsed(
      "CodeSign build/Release/MyApp.app",
      "Signing MyApp.app"
    )
  }

  func testCompileCommand() throws {
  }

  func testCompileError() throws {
  }

  func testCompile() throws {
    #if os(macOS)
      // Xcode 10 and before
      let input1 =
        "CompileSwift normal x86_64 /Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift (in target: xcbeautify)"
      // Xcode 11+'s output
      let input2 =
        "CompileSwift normal x86_64 /Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift (in target 'xcbeautify' from project 'xcbeautify')"
      let output = "[xcbeautify] Compiling setup.swift"
      XCTAssertEqual(parseLine(input1), output)
      XCTAssertEqual(parseLine(input2), output)
    #endif
  }

  func testCompileStoryboard() throws {
    assertParsed(
      "CompileStoryboard /Users/admin/MyApp/MyApp/Main.storyboard (in target: MyApp)",
      "[MyApp] Compiling Main.storyboard"
    )
  }

  func testCompileWarning() throws {
  }

  func testCompileXib() throws {
  }

  func testCopyHeader() throws {
  }

  func testCopyPlist() throws {
  }

  func testCopyStrings() throws {
  }

  func testCpresource() throws {
  }

  func testCursor() throws {
  }

  func testFailingTest() throws {
  }

  func testFatalError() throws {
  }

  func testFileMissingError() throws {
  }

  func testGenerateCoverageData() throws {
    assertParsed(
      "Generating coverage data...",
      "Generating code coverage data..."
    )
  }

  func testGeneratedCoverageReport() throws {
    assertParsed(
      "Generated coverage report: /path/to/code coverage.xccovreport",
      "Generated code coverage report: /path/to/code coverage.xccovreport"
    )
  }

  func testGenerateDsym() throws {
  }

  func testGenericWarning() throws {
  }

  func testLdError() throws {
  }

  func testLdWarning() throws {
  }

  func testLibtool() throws {
  }

  func testLinkerDuplicateSymbolsLocation() throws {
  }

  func testLinkerDuplicateSymbols() throws {
  }

  func testLinkerUndefinedSymbolLocation() throws {
  }

  func testLinkerUndefinedSymbols() throws {
  }

  func testLinking() throws {
    #if os(macOS)
      assertParsed(
        "Ld /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-abcd/Build/Products/Debug/xcbeautify normal x86_64 (in target: xcbeautify)",
        "[xcbeautify] Linking xcbeautify"
      )

      assertParsed(
        "Ld /Users/admin/Library/Developer/Xcode/DerivedData/MyApp-abcd/Build/Intermediates.noindex/ArchiveIntermediates/MyApp/IntermediateBuildFilesPath/MyApp.build/Release-iphoneos/MyApp.build/Objects-normal/armv7/My\\ App normal armv7 (in target: MyApp)",
        "[MyApp] Linking My\\ App"
      )
    #endif
  }

  func testModuleIncludesError() throws {
  }

  func testNoCertificate() throws {
  }

  func testParallelTestCaseFailed() throws {
    assertParsed(
      "Test case 'XcbeautifyLibTests.testBuildTarget()' failed on 'xctest (49438)' (0.131 seconds)",
      "    ✖ testBuildTarget on 'xctest (49438)' (0.131 seconds)"
    )
  }

  func testParallelTestCasePassed() throws {
    assertParsed(
      "Test case 'XcbeautifyLibTests.testBuildTarget()' passed on 'xctest (49438)' (0.131 seconds)",
      "    ✔ testBuildTarget on 'xctest (49438)' (0.131 seconds)"
    )
  }

  func testConcurrentDestinationTestSuiteStarted() throws {
    assertParsed(
      "Test suite 'XcbeautifyLibTests (iOS).xctest' started on 'iPhone X'",
      "Test Suite XcbeautifyLibTests (iOS).xctest started on 'iPhone X'"
    )
  }

  func testConcurrentDestinationTestCaseFailed() throws {
    assertParsed(
      "Test case 'XcbeautifyLibTests.testBuildTarget()' failed on 'iPhone X' (77.158 seconds)",
      "    ✖ testBuildTarget on 'iPhone X' (77.158 seconds)"
    )
  }

  func testConcurrentDestinationTestCasePassed() throws {
    assertParsed(
      "Test case 'XcbeautifyLibTests.testBuildTarget()' passed on 'iPhone X' (77.158 seconds)",
      "    ✔ testBuildTarget on 'iPhone X' (77.158 seconds)"
    )
  }

  func testParallelTestCaseAppKitPassed() throws {
    assertParsed(
      "Test case '-[XcbeautifyLibTests.XcbeautifyLibTests testBuildTarget]' passed on 'xctest (49438)' (0.131 seconds).",
      "    ✔ testBuildTarget (0.131 seconds)"
    )
  }

  func testParallelTestingStarted() throws {
    assertParsed(
      "Testing started on 'iPhone X'",
      "Testing started on 'iPhone X'"
    )
  }

  func testParallelTestingPassed() throws {
    assertParsed(
      "Testing passed on 'iPhone X'",
      "Testing passed on 'iPhone X'"
    )
  }

  func testParallelTestingFailed() throws {
    assertParsed(
      "Testing failed on 'iPhone X'",
      "Testing failed on 'iPhone X'"
    )
  }

  func testPbxcp() throws {
    assertParsed(
      "PBXCp /Users/admin/CocoaLumberjack/Classes/Extensions/DDDispatchQueueLogFormatter.h /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Products/Release/include/CocoaLumberjack/DDDispatchQueueLogFormatter.h (in target: CocoaLumberjack-Static)",
      "[CocoaLumberjack-Static] Copying DDDispatchQueueLogFormatter.h"
    )
  }

  func testPhaseScriptExecution() throws {
    let input1 =
      "PhaseScriptExecution [CP]\\ Check\\ Pods\\ Manifest.lock /Users/admin/Library/Developer/Xcode/DerivedData/App-abcd/Build/Intermediates.noindex/ArchiveIntermediates/App/IntermediateBuildFilesPath/App.build/Release-iphoneos/App.build/Script-53BECF2B2F2E203E928C31AE.sh (in target: App)"
    let input2 =
      "PhaseScriptExecution [CP]\\ Check\\ Pods\\ Manifest.lock /Users/admin/Library/Developer/Xcode/DerivedData/App-abcd/Build/Intermediates.noindex/ArchiveIntermediates/App/IntermediateBuildFilesPath/App.build/Release-iphoneos/App.build/Script-53BECF2B2F2E203E928C31AE.sh (in target 'App' from project 'App')"
    XCTAssertEqual(parseLine(input1), "[App] Running script [CP] Check Pods Manifest.lock")
    XCTAssertEqual(parseLine(input2), "[App] Running script [CP] Check Pods Manifest.lock")
  }

  func testPhaseSuccess() throws {
    assertParsed(
      "** CLEAN SUCCEEDED ** [0.085 sec]",
      "Clean Succeeded"
    )
  }

  func testPodsError() throws {
  }

  func testPreprocess() throws {
  }

  func testProcessInfoPlist() throws {
    assertParsed(
      "ProcessInfoPlistFile /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-abcd/Build/Products/Debug/Guaka.framework/Versions/A/Resources/Info.plist /Users/admin/xcbeautify/xcbeautify.xcodeproj/Guaka_Info.plist",
      "Processing Guaka_Info.plist"
    )
  }

  func testProcessPchCommand() throws {
    assertParsed(
      "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -x c++-header -target x86_64-apple-macos10.13 -c /path/to/my.pch -o /path/to/output/AcVDiff_Prefix.pch.gch",
      "Preprocessing /path/to/my.pch"
    )
  }

  func testProcessPch() throws {
    assertParsed(
      "ProcessPCH /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Intermediates.noindex/PrecompiledHeaders/SharedPrecompiledHeaders/5872309797734264511/CocoaLumberjack-Prefix.pch.gch /Users/admin/CocoaLumberjack/Framework/Lumberjack/CocoaLumberjack-Prefix.pch normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.analyzer (in target: CocoaLumberjack)",
      "[CocoaLumberjack] Processing CocoaLumberjack-Prefix.pch"
    )
  }

  func testProcessPchPlusPlus() throws {
    assertParsed(
      "ProcessPCH++ /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Intermediates.noindex/PrecompiledHeaders/SharedPrecompiledHeaders/5872309797734264511/CocoaLumberjack-Prefix.pch.gch /Users/admin/CocoaLumberjack/Framework/Lumberjack/CocoaLumberjack-Prefix.pch normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.analyzer (in target: CocoaLumberjack)",
      "[CocoaLumberjack] Processing CocoaLumberjack-Prefix.pch"
    )
  }

  func testProvisioningProfileRequired() throws {
  }

  func testRestartingTests() throws {
  }

  func testShellCommand() throws {
    let parsed = parseLine("    cd /foo/bar/baz")
    XCTAssertNil(parsed)
    XCTAssertEqual(parser.outputType, .task)
  }

  func testSymbolReferencedFrom() throws {
    assertParsed(
      "  \"NetworkBusiness.ImageDownloadManager.saveImage(image: __C.UIImage, needWatermark: Swift.Bool, params: [Swift.String : Any], downloadHandler: (Swift.Bool) -> ()?) -> ()\", referenced from:",
      "\(Symbol.error.rawValue)   \"NetworkBusiness.ImageDownloadManager.saveImage(image: __C.UIImage, needWatermark: Swift.Bool, params: [Swift.String : Any], downloadHandler: (Swift.Bool) -> ()?) -> ()\", referenced from:"
    )
    XCTAssertEqual(parser.outputType, .warning)
  }

  func testUndefinedSymbolLocation() throws {
    assertParsed(
      "      MediaBrowser.ChatGalleryViewController.downloadImage() -> () in MediaBrowser(ChatGalleryViewController.o)",
      "\(Symbol.warning.rawValue)       MediaBrowser.ChatGalleryViewController.downloadImage() -> () in MediaBrowser(ChatGalleryViewController.o)"
    )
    XCTAssertEqual(parser.outputType, .warning)
  }

  func testTestCaseMeasured() throws {
  }

  func testTestCasePassed() throws {
    #if os(macOS)
      assertParsed(
        "Test Case '-[XcbeautifyLibTests.XcbeautifyLibTests testBuildTarget]' passed (0.131 seconds).",
        "    ✔ testBuildTarget (0.131 seconds)"
      )
    #endif
  }

  func testTestCasePending() throws {
  }

  func testTestCaseStarted() throws {
  }

  func testTestSuiteStart() throws {
  }

  func testTestSuiteStarted() throws {
  }

  func testTestsRunCompletion() throws {
  }

  func testTiffutil() throws {
  }

  func testTouch() throws {
    assertParsed(
      "Touch /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-dgnqmpfertotpceazwfhtfwtuuwt/Build/Products/Debug/XcbeautifyLib.framework (in target: XcbeautifyLib)",
      "[XcbeautifyLib] Touching XcbeautifyLib.framework"
    )
  }

  func testUiFailingTest() throws {
    assertParsed(
      "    t =    10.13s Assertion Failure: <unknown>:0: App crashed in <external symbol>",
      "    ✖ <unknown>:0, App crashed in <external symbol>"
    )
  }

  func testWillNotBeCodeSigned() throws {
  }

  func testWriteAuxiliaryFiles() throws {
  }

  func testWriteFile() throws {
  }

  func testPackageGraphResolved() throws {
    // Start
    let start = parseLine("Resolve Package Graph")
    XCTAssertEqual(start, "Resolve Package Graph")

    // Ended
    let ended = parseLine("Resolved source packages:")
    XCTAssertEqual(ended, "Resolved source packages")

    // Package
    let package = parseLine(
      "  StrasbourgParkAPI: https://github.com/yageek/StrasbourgParkAPI.git @ 3.0.2")
    XCTAssertEqual(
      package, "StrasbourgParkAPI - https://github.com/yageek/StrasbourgParkAPI.git @ 3.0.2")
  }
}
