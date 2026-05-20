//
//  ios_app_templateUITests.swift
//  ios-app-templateUITests
//

import XCTest

final class ios_app_templateUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAddingItemIncreasesListCount() throws {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.buttons["Add Item"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))

        let initialCount = app.cells.count
        addButton.tap()
        XCTAssertEqual(app.cells.count, initialCount + 1)
    }
}
