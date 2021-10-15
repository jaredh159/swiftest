import XCTest

@testable import SwiftestPretty

final class PatternTests: XCTestCase {

  func testExecuted() throws {
    let line = "   Executed 85 tests, with 0 failures (0 unexpected) in 0.026 (0.039) seconds"
    assertCaptured(.executed, line, ["85", "0", "0", "0.039"])
  }

  func testTestSuiteFinished() throws {
    assertCaptured(
      .testSuiteFinished,
      "Test Suite 'PatternTests' passed at 2021-10-15 08:12:43.680.",
      ["PatternTests", "passed", "2021-10-15 08:12:43.680"]
    )
  }

  func testPassingTestMacAndLinux() throws {
    let macOS = #"Test Case '-[FooTests.FooTests testFoobar]' passed (0.007 seconds)."#
    assertCaptured(.testCaseFinished, macOS, ["FooTests", "testFoobar", "passed", "0.007"])

    let linux = #"Test Case 'FooTests.testFoobar' passed (0.342 seconds)"#
    assertCaptured(.testCaseFinished, linux, ["FooTests", "testFoobar", "passed", "0.342"])
  }

  func testFailingTest() throws {
    let linux =
      #"/home/jared/deploy/staging/Tests/AppTests/Token+ResolverTests.swift:38: error: TokenResolverTests.testTokenByValue : XCTAssertEqual failed: ("1") is not equal to ("2") -"#

    assertCaptured(
      .failingTest,
      linux,
      [
        "/home/jared/deploy/staging/Tests/AppTests/Token+ResolverTests.swift",
        "38",
        "TokenResolverTests",
        "testTokenByValue",
        #"XCTAssertEqual failed: ("1") is not equal to ("2") -"#,
      ])

    let macOS =
      #"Users/jared/jaredh159/Swiftest/Tests/SwiftestPrettyTests/ParserTests.swift:35: error: -[SwiftestPrettyTests.SwiftestPrettyTests testTestSuiteStartCreatesTestSuite] : XCTAssertEqual failed: ("18.280") is not equal to ("x18.280")"#

    assertCaptured(
      .failingTest,
      macOS,
      [
        "Users/jared/jaredh159/Swiftest/Tests/SwiftestPrettyTests/ParserTests.swift",
        "35",
        "SwiftestPrettyTests",
        "testTestSuiteStartCreatesTestSuite",
        #"XCTAssertEqual failed: ("18.280") is not equal to ("x18.280")"#,
      ])
  }

  func testFatalError_Isolate() throws {
    assertCaptured(.exit, "Exited with signal code 4", ["4"])
    assertCaptured(
      .fatalError,
      "swiftestTests/swiftestTests.swift:9: Fatal error: Unexpectedly found nil while unwrapping an Optional value",
      [
        "swiftestTests/swiftestTests.swift:9",
        "Unexpectedly found nil while unwrapping an Optional value",
      ]
    )

    assertCaptured(
      .fatalError,
      "Swift/ContiguousArrayBuffer.swift:580: Fatal error: Index out of range",
      ["Swift/ContiguousArrayBuffer.swift:580", "Index out of range"]
    )
  }

  func testAggregateTarget() throws {
    assertCaptured(
      .aggregateTarget,
      "=== BUILD AGGREGATE TARGET Be Aggro OF PROJECT AggregateExample WITH CONFIGURATION Debug ===",
      ["Be Aggro", "AggregateExample", "Debug"]
    )
  }

  func testAnalyze() throws {
    assertCaptured(
      .analyze,
      "AnalyzeShallow /Users/admin/CocoaLumberjack/Classes/DDTTYLogger.m normal x86_64 (in target: CocoaLumberjack-Static)",
      [
        "/Users/admin/CocoaLumberjack/Classes/DDTTYLogger.m",
        "DDTTYLogger.m",
        "in target: CocoaLumberjack-Static",
        "CocoaLumberjack-Static",
      ]
    )
  }

  func testAnalyzeTarget() throws {
    assertCaptured(
      .analyzeTarget,
      "=== ANALYZE TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===",
      ["The Spacer", "Pods", "Debug"]
    )
  }

  func testBuildTarget() throws {
    assertCaptured(
      .buildTarget,
      "=== BUILD TARGET The Spacer OF PROJECT Pods WITH THE DEFAULT CONFIGURATION Debug ===",
      ["The Spacer", "Pods", "Debug"]
    )
  }

  func testCleanTarget() throws {
    assertCaptured(
      .cleanTarget,
      "=== CLEAN TARGET The Spacer OF PROJECT Pods WITH CONFIGURATION Debug ===",
      ["The Spacer", "Pods", "Debug"]
    )
  }

  func testClangError() throws {
    assertCaptured(
      .clangError,
      "clang: error: linker command failed with exit code 1 (use -v to see invocation)",
      ["clang: error: linker command failed with exit code 1 (use -v to see invocation)"]
    )
  }

  func testCleanRemove() throws {
    assertCaptured(
      .cleanRemove,
      "Clean.Remove clean /Users/admin/Library/Developer/Xcode/DerivedData/MyLibrary-abcd/Build/Intermediates/MyLibrary.build/Debug-iphonesimulator/MyLibraryTests.build",
      [
        " clean /Users/admin/Library/Developer/Xcode/DerivedData/MyLibrary-abcd/Build/Intermediates/MyLibrary.build/Debug-iphonesimulator/MyLibraryTests.build"
      ]
    )
  }

  func testCodesignFramework() throws {
    assertCaptured(
      .codesignFramework,
      "CodeSign build/Release/MyFramework.framework/Versions/A",
      ["build/Release/MyFramework.framework"]
    )
  }

  func testCodesign() throws {
    assertCaptured(
      .codesign,
      "CodeSign build/Release/MyApp.app",
      ["build/Release/MyApp.app"]
    )
  }

  func testCompile() throws {
    #if os(macOS)
      // Xcode 10 and before
      let xcode10 =
        "CompileSwift normal x86_64 /Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift (in target: xcbeautify)"

      // Xcode 11+'s output
      let xcode11Plus =
        "CompileSwift normal x86_64 /Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift (in target 'xcbeautify' from project 'xcbeautify')"

      assertCaptured(
        .compile,
        xcode10,
        [
          "/Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift", "setup.swift",
          "in target: xcbeautify", "xcbeautify",
        ]
      )
      assertCaptured(
        .compile,
        xcode11Plus,
        [
          "/Users/admin/dev/Swifttrain/xcbeautify/Sources/xcbeautify/setup.swift", "setup.swift",
          "in target \'xcbeautify\' from project \'xcbeautify\'",
          "xcbeautify",
        ]
      )
    #endif
  }

  func testCompileStoryboard() throws {
    assertCaptured(
      .compileStoryboard,
      "CompileStoryboard /Users/admin/MyApp/MyApp/Main.storyboard (in target: MyApp)",
      ["/Users/admin/MyApp/MyApp/Main.storyboard", "Main.storyboard", "in target: MyApp", "MyApp"]
    )
  }

  func testGenerateCoverageData() throws {
    assertCaptured(.generateCoverageData, "Generating coverage data...", [])
  }

  func testGeneratedCoverageReport() throws {
    assertCaptured(
      .generatedCoverageReport,
      "Generated coverage report: /path/to/code coverage.xccovreport",
      ["/path/to/code coverage.xccovreport"]
    )
  }

  func testLinking() throws {
    #if os(macOS)
      assertCaptured(
        .linking,
        "Ld /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-abcd/Build/Products/Debug/xcbeautify normal x86_64 (in target: xcbeautify)",
        ["xcbeautify", "in target: xcbeautify", "xcbeautify"]
      )

      assertCaptured(
        .linking,
        "Ld /Users/admin/Library/Developer/Xcode/DerivedData/MyApp-abcd/Build/Intermediates.noindex/ArchiveIntermediates/MyApp/IntermediateBuildFilesPath/MyApp.build/Release-iphoneos/MyApp.build/Objects-normal/armv7/My\\ App normal armv7 (in target: MyApp)",
        ["My\\ App", "in target: MyApp", "MyApp"]
      )
    #endif
  }

  func testParallelTestCaseFailed() throws {
    assertCaptured(
      .parallelTestCaseFailed,
      "Test case 'XcbeautifyLibTests.testBuildTarget()' failed on 'xctest (49438)' (0.131 seconds)",
      ["XcbeautifyLibTests", "testBuildTarget", "xctest (49438)", "0.131", ""]
    )
  }

  func testParallelTestCasePassed() throws {
    assertCaptured(
      .parallelTestCasePassed,
      "Test case 'XcbeautifyLibTests.testBuildTarget()' passed on 'xctest (49438)' (0.131 seconds)",
      ["XcbeautifyLibTests", "testBuildTarget", "xctest (49438)", "0.131", ""]
    )
  }

  func testParallelTestSuiteStarted() throws {
    assertCaptured(
      .parallelTestSuiteStarted,
      "Test suite 'XcbeautifyLibTests (iOS).xctest' started on 'iPhone X'",
      ["XcbeautifyLibTests (iOS).xctest", "iPhone X"]
    )
  }

  func testParallelTestCaseFailed2() throws {
    assertCaptured(
      .parallelTestCaseFailed,
      "Test case 'XcbeautifyLibTests.testBuildTarget()' failed on 'iPhone X' (77.158 seconds)",
      ["XcbeautifyLibTests", "testBuildTarget", "iPhone X", "77.158", ""]
    )
  }

  func testParallelTestCasePassed2() throws {
    assertCaptured(
      .parallelTestCasePassed,
      "Test case 'XcbeautifyLibTests.testBuildTarget()' passed on 'iPhone X' (77.158 seconds)",
      ["XcbeautifyLibTests", "testBuildTarget", "iPhone X", "77.158", ""]
    )
  }

  func testParallelTestCaseAppKitPassed() throws {
    assertCaptured(
      .parallelTestCaseAppKitPassed,
      "Test case '-[XcbeautifyLibTests.XcbeautifyLibTests testBuildTarget]' passed on 'xctest (49438)' (0.131 seconds).",
      ["XcbeautifyLibTests.XcbeautifyLibTests", "testBuildTarget", "0.131"]
    )
  }

  func testParallelTestingStarted() throws {
    assertCaptured(.parallelTestingStarted, "Testing started on 'iPhone X'", ["iPhone X"])
  }

  func testParallelTestingPassed() throws {
    assertCaptured(.parallelTestingPassed, "Testing passed on 'iPhone X'", ["iPhone X"])
  }

  func testParallelTestingFailed() throws {
    assertCaptured(.parallelTestingFailed, "Testing failed on 'iPhone X'", ["iPhone X"])
  }

  func testPbxcp() throws {
    assertCaptured(
      .pbxcp,
      "PBXCp /Users/admin/CocoaLumberjack/Classes/Extensions/DDDispatchQueueLogFormatter.h /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Products/Release/include/CocoaLumberjack/DDDispatchQueueLogFormatter.h (in target: CocoaLumberjack-Static)",
      [
        "/Users/admin/CocoaLumberjack/Classes/Extensions/DDDispatchQueueLogFormatter.h",
        "Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Products/Release/include/CocoaLumberjack/DDDispatchQueueLogFormatter.h",
        "in target: CocoaLumberjack-Static",
        "CocoaLumberjack-Static",
      ]
    )
  }

  func testPhaseScriptExecution() throws {
    assertCaptured(
      .phaseScriptExecution,
      "PhaseScriptExecution [CP]\\ Check\\ Pods\\ Manifest.lock /Users/admin/Library/Developer/Xcode/DerivedData/App-abcd/Build/Intermediates.noindex/ArchiveIntermediates/App/IntermediateBuildFilesPath/App.build/Release-iphoneos/App.build/Script-53BECF2B2F2E203E928C31AE.sh (in target: App)",
      ["[CP]\\ Check\\ Pods\\ Manifest.lock", "in target: App", "App"]
    )
    assertCaptured(
      .phaseScriptExecution,
      "PhaseScriptExecution [CP]\\ Check\\ Pods\\ Manifest.lock /Users/admin/Library/Developer/Xcode/DerivedData/App-abcd/Build/Intermediates.noindex/ArchiveIntermediates/App/IntermediateBuildFilesPath/App.build/Release-iphoneos/App.build/Script-53BECF2B2F2E203E928C31AE.sh (in target 'App' from project 'App')",
      ["[CP]\\ Check\\ Pods\\ Manifest.lock", "in target \'App\' from project \'App\'", "App"]
    )
  }

  func testPhaseSuccess() throws {
    assertCaptured(.phaseSuccess, "** CLEAN SUCCEEDED ** [0.085 sec]", ["CLEAN"])
  }

  func testProcessInfoPlist() throws {
    assertCaptured(
      .processInfoPlist,
      "ProcessInfoPlistFile /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-abcd/Build/Products/Debug/Guaka.framework/Versions/A/Resources/Info.plist /Users/admin/xcbeautify/xcbeautify.xcodeproj/Guaka_Info.plist",
      ["/Users/admin/xcbeautify/xcbeautify.xcodeproj/Guaka_Info.plist", "Guaka_Info.plist"]
    )
  }

  func testProcessPchCommand() throws {
    assertCaptured(
      .processPchCommand,
      "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -x c++-header -target x86_64-apple-macos10.13 -c /path/to/my.pch -o /path/to/output/AcVDiff_Prefix.pch.gch",
      ["/path/to/my.pch"]
    )
  }

  func testProcessPch() throws {
    assertCaptured(
      .processPch,
      "ProcessPCH /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Intermediates.noindex/PrecompiledHeaders/SharedPrecompiledHeaders/5872309797734264511/CocoaLumberjack-Prefix.pch.gch /Users/admin/CocoaLumberjack/Framework/Lumberjack/CocoaLumberjack-Prefix.pch normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.analyzer (in target: CocoaLumberjack)",
      ["CocoaLumberjack-Prefix.pch", "in target: CocoaLumberjack", "CocoaLumberjack"]
    )
  }

  func testProcessPchPlusPlus() throws {
    assertCaptured(
      .processPch,
      "ProcessPCH++ /Users/admin/Library/Developer/Xcode/DerivedData/Lumberjack-abcd/Build/Intermediates.noindex/PrecompiledHeaders/SharedPrecompiledHeaders/5872309797734264511/CocoaLumberjack-Prefix.pch.gch /Users/admin/CocoaLumberjack/Framework/Lumberjack/CocoaLumberjack-Prefix.pch normal x86_64 objective-c com.apple.compilers.llvm.clang.1_0.analyzer (in target: CocoaLumberjack)",
      ["CocoaLumberjack-Prefix.pch", "in target: CocoaLumberjack", "CocoaLumberjack"]
    )
  }

  func testShellCommand() throws {
    assertCaptured(.shellCommand, "    cd /foo/bar", ["cd", "/foo/bar"])
  }

  func testSymbolReferencedFrom() throws {
    assertCaptured(
      .symbolReferencedFrom,
      "  \"NetworkBusiness.ImageDownloadManager.saveImage(image: __C.UIImage, needWatermark: Swift.Bool, params: [Swift.String : Any], downloadHandler: (Swift.Bool) -> ()?) -> ()\", referenced from:",
      [
        "NetworkBusiness.ImageDownloadManager.saveImage(image: __C.UIImage, needWatermark: Swift.Bool, params: [Swift.String : Any], downloadHandler: (Swift.Bool) -> ()?) -> ()"
      ]
    )
  }

  func testUndefinedSymbolLocation() throws {
    assertCaptured(
      .undefinedSymbolLocation,
      "      MediaBrowser.ChatGalleryViewController.downloadImage() -> () in MediaBrowser(ChatGalleryViewController.o)",
      ["MediaBrowser", "ChatGalleryViewController"]
    )
  }

  func testTestCaseFinishedPassing() throws {
    assertCaptured(
      .testCaseFinished,
      "Test Case '-[XcbeautifyLibTests.XcbeautifyLibTests testBuildTarget]' passed (0.131 seconds).",
      ["XcbeautifyLibTests", "testBuildTarget", "passed", "0.131"]
    )
  }

  func testTouch() throws {
    assertCaptured(
      .touch,
      "Touch /Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-dgnqmpfertotpceazwfhtfwtuuwt/Build/Products/Debug/XcbeautifyLib.framework (in target: XcbeautifyLib)",
      [
        "/Users/admin/Library/Developer/Xcode/DerivedData/xcbeautify-dgnqmpfertotpceazwfhtfwtuuwt/Build/Products/Debug/XcbeautifyLib.framework",
        "XcbeautifyLib.framework",
        " (in target: XcbeautifyLib)",
        "in target: XcbeautifyLib",
        "XcbeautifyLib",
      ]
    )
  }

  func testUiFailingTest() throws {
    assertCaptured(
      .uiFailingTest,
      "    t =    10.13s Assertion Failure: <unknown>:0: App crashed in <external symbol>",
      ["<unknown>:0", "App crashed in <external symbol>"]
    )
  }

  func testPackageGraphResolved() throws {
    // start
    assertCaptured(
      .packageGraphResolvingStart,
      "Resolve Package Graph",
      ["Resolve Package Graph"]
    )

    // ended
    assertCaptured(
      .packageGraphResolvingEnded,
      "Resolved source packages:",
      ["Resolved source packages"]
    )

    // Package
    assertCaptured(
      .packageGraphResolvedItem,
      "  StrasbourgParkAPI: https://github.com/yageek/StrasbourgParkAPI.git @ 3.0.2",
      ["StrasbourgParkAPI", "https://github.com/yageek/StrasbourgParkAPI.git", "3.0.2"]
    )
  }

  private func assertCaptured(
    _ pattern: SwiftestPretty.Pattern,
    _ input: String,
    _ expected: [String],
    file: StaticString = #filePath,
    line: UInt = #line
  ) {

    XCTAssertTrue(
      input.match(regex: Regex(pattern: pattern)),
      file: file,
      line: line
    )

    XCTAssertEqual(
      input.capturedGroups(with: pattern),
      expected,
      file: file,
      line: line
    )
  }
}

/* Linux failing test ouput:

Test Suite 'Selected tests' started at 2021-09-29 08:17:42.047
Test Suite 'TokenResolverTests' started at 2021-09-29 08:17:42.089
Test Case 'TokenResolverTests.testTokenByValue' started at 2021-09-29 08:17:42.089
2021-09-29T08:17:42-0400 notice codes.vapor.application : App environment is `testing`
2021-09-29T08:17:42-0400 info codes.vapor.request : request-id=EF395938-D3D8-4321-B557-C51968AACE79 POST /graphql
/home/jared/deploy/staging/.build/checkouts/vapor-utils/Sources/XCTVaporUtils/GraphQLTestCase.swift:98: error: TokenResolverTests.testTokenByValue : XCTAssertTrue failed - {"data":{"getTokenByValue":{"description":"test","id":"331BA3F8-194F-4DE0-BD79-A1FC6138D8D7","scopes":[{"scope":"queryOrders"}],"value":"0A9B1FC4-8120-4F3C-9346-900455C8F151"}}} does not contain "description":"Xtest"
/home/jared/deploy/staging/Tests/AppTests/Token+ResolverTests.swift:38: error: TokenResolverTests.testTokenByValue : XCTAssertEqual failed: ("1") is not equal to ("2") -
Test Case 'TokenResolverTests.testTokenByValue' failed (0.235 seconds)
Test Suite 'TokenResolverTests' failed at 2021-09-29 08:17:42.325
	 Executed 1 test, with 2 failures (0 unexpected) in 0.235 (0.235) seconds
Test Suite 'Selected tests' failed at 2021-09-29 08:17:42.325
	 Executed 1 test, with 2 failures (0 unexpected) in 0.235 (0.235) seconds

*/

/* Linux passing test output:

Test Suite 'Selected tests' started at 2021-09-29 08:15:37.814
Test Suite 'TokenResolverTests' started at 2021-09-29 08:15:37.857
Test Case 'TokenResolverTests.testTokenByValue' started at 2021-09-29 08:15:37.857
2021-09-29T08:15:38-0400 notice codes.vapor.application : App environment is `testing`
2021-09-29T08:15:38-0400 info codes.vapor.request : request-id=175B53DF-2798-4292-83E8-8B022B666784 POST /graphql
Test Case 'TokenResolverTests.testTokenByValue' passed (0.342 seconds)
Test Suite 'TokenResolverTests' passed at 2021-09-29 08:15:38.199
	 Executed 1 test, with 0 failures (0 unexpected) in 0.342 (0.342) seconds
Test Suite 'Selected tests' passed at 2021-09-29 08:15:38.200
	 Executed 1 test, with 0 failures (0 unexpected) in 0.342 (0.342) seconds

*/
