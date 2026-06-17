//
//  ScreenshotCaptureUITests.swift
//  ios-app-templateUITests
//

import XCTest

/// App Store 提出用スクリーンショットを撮影する専用テスト (niki-sandbox#100)。
/// 通常のテスト実行では XCTSkip されるため、CI や `fastlane test` には影響しない。
///
/// 実行方法 (推奨):
///   bundle exec fastlane screenshots
/// 手動の場合:
///   TEST_RUNNER_CAPTURE_SCREENSHOTS=1 xcodebuild test \
///     -only-testing:ios-app-templateUITests/ScreenshotCaptureUITests \
///     -resultBundlePath shots.xcresult ...
///   xcrun xcresulttool export attachments --path shots.xcresult --output-path out/
///
/// ハマりどころ:
/// - `TEST_RUNNER_` 接頭辞の変数は xcodebuild の「引数」ではなく「環境変数」として
///   渡すこと (引数渡しだとテストランナーに届かず、テストが skip される)
/// - 広告 SDK を導入したら mock 広告フラグを必ず立てること
///   (忘れると撮影中にインタースティシャルや本物の広告が写り込む)
/// - 6.5" (1284x2778) 等のサイズ要件はシミュレータの出力 (例: 1320x2868) から
///   `sips -z 2778 1284 shot.png` でリサイズできる
final class ScreenshotCaptureUITests: XCTestCase {
    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["CAPTURE_SCREENSHOTS"] == "1",
            "撮影モード専用 (TEST_RUNNER_CAPTURE_SCREENSHOTS=1 で有効化)"
        )
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureMainScreen() {
        let app = XCUIApplication.launchForUITest()
        XCTAssertTrue(app.buttons["Add Item"].waitForExistence(timeout: 30))
        capture(named: "01-main")
    }

    @MainActor
    private func capture(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
