//
//  ios_app_templateTests.swift
//  ios-app-templateTests
//

import Foundation
import Testing
@testable import ios_app_template

struct ItemTests {
    @Test
    func initializesWithGivenTimestamp() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let item = Item(timestamp: now)
        #expect(item.timestamp == now)
    }
}
