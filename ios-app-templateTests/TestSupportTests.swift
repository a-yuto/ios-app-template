//
//  TestSupportTests.swift
//  ios-app-templateTests
//

import Foundation
import Testing

struct WaitUntilTests {
    @Test
    func returnsTrueImmediatelyWhenConditionAlreadyHolds() async {
        let result = await waitUntil(timeout: .seconds(1)) { true }
        #expect(result)
    }

    @Test
    func returnsTrueOnceConditionBecomesTrue() async {
        let start = ContinuousClock().now
        var calls = 0
        // 3 回目の評価で成立させ、ポーリングが成立を捉えることを確認する。
        let result = await waitUntil(timeout: .seconds(5), pollInterval: .milliseconds(10)) {
            calls += 1
            return calls >= 3
        }
        #expect(result)
        #expect(calls >= 3)
        #expect(ContinuousClock().now - start < .seconds(5))
    }

    @Test
    func returnsFalseWhenConditionNeverHolds() async {
        let result = await waitUntil(timeout: .milliseconds(100), pollInterval: .milliseconds(10)) { false }
        #expect(result == false)
    }
}
