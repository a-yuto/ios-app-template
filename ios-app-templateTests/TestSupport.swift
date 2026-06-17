//
//  TestSupport.swift
//  ios-app-templateTests
//

import Foundation

/// 条件が成立するまでポーリングして待つ Swift Testing 用ヘルパー (niki-sandbox#108)。
///
/// `condition` が `true` を返した時点で即座に return するため、`timeout` は
/// 「待つ上限」でしかない。広げてもグリーン時の速度は不変で、CI の遅さ/ジッタ
/// に対するフレーク耐性だけが上がる。そのため既定は CI 負荷に耐える **10s**。
///
/// 使用例:
/// ```swift
/// let ok = await waitUntil { model.state == .ready }
/// #expect(ok)
/// ```
///
/// - Parameters:
///   - timeout: 待つ上限。既定 10 秒。
///   - pollInterval: 条件を再評価する間隔。既定 50ms。
///   - condition: 成立を待つ条件。
/// - Returns: timeout 以内に条件が成立したら `true`、しなければ `false`。
@discardableResult
func waitUntil(
    timeout: Duration = .seconds(10),
    pollInterval: Duration = .milliseconds(50),
    _ condition: () -> Bool
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while clock.now < deadline {
        if condition() { return true }
        try? await Task.sleep(for: pollInterval)
    }
    return condition()
}
