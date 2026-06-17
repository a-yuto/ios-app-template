//
//  LaunchHelperUITests.swift
//  ios-app-templateUITests
//

import XCTest

/// 共通起動ヘルパー `XCUIApplication.launchForUITest()` 経由でアプリが
/// 正常に起動し、メイン画面が表示されることを保証する。
final class LaunchHelperUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchForUITestShowsMainScreen() {
        let app = XCUIApplication.launchForUITest()
        XCTAssertTrue(app.buttons["Add Item"].waitForExistence(timeout: 30))
    }
}
