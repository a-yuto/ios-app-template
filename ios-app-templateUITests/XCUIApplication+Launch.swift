//
//  XCUIApplication+Launch.swift
//  ios-app-templateUITests
//

import XCTest

extension XCUIApplication {
    /// UI テスト共通の起動ヘルパー。起動引数はここで一元管理する (niki-sandbox#102)。
    ///
    /// 規約 (CLAUDE.md「UI テストの起動規約」参照):
    /// - 初回起動オーバーレイ (オンボーディング・告知等) を追加したら、必ず `-skipXXX`
    ///   launch argument を併設し、このヘルパーのデフォルトに含める。
    ///   オーバーレイ自体のテストだけが、明示的に素の XCUIApplication() で起動する。
    /// - 外部依存 (audio / store / ads など) を増やすときは mock フラグも同時に追加する。
    ///   例: app.launchArguments += ["-mockAudio", "-mockStore", "-mockAds", "-skipOnboarding"]
    static func launchForUITest(extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTesting"] + extra
        app.launch()
        return app
    }
}
