//
//  SpacingTests.swift
//  ios-app-templateTests
//

import Foundation
import Testing
@testable import ios_app_template

struct SpacingTests {
    @Test
    func xsIs4() {
        #expect(Spacing.xs == 4)
    }

    @Test
    func smIs8() {
        #expect(Spacing.sm == 8)
    }

    @Test
    func md12Is12() {
        #expect(Spacing.md12 == 12)
    }

    @Test
    func mdIs16() {
        #expect(Spacing.md == 16)
    }

    @Test
    func lgIs24() {
        #expect(Spacing.lg == 24)
    }

    @Test
    func xlIs32() {
        #expect(Spacing.xl == 32)
    }

    @Test
    func xxlIs48() {
        #expect(Spacing.xxl == 48)
    }

    @Test
    func spacingIsStrictlyAscending() {
        #expect(Spacing.xs < Spacing.sm)
        #expect(Spacing.sm < Spacing.md12)
        #expect(Spacing.md12 < Spacing.md)
        #expect(Spacing.md < Spacing.lg)
        #expect(Spacing.lg < Spacing.xl)
        #expect(Spacing.xl < Spacing.xxl)
    }
}
