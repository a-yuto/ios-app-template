//
//  Font+App.swift
//  ios-app-template
//

import SwiftUI

extension Font {
    // システムフォントをラップして Dynamic Type / アクセシビリティを自動継承する。
    // カスタムフォント導入時はここを .custom(...) に差し替えるだけで全体に波及する。

    static let appDisplayLarge: Font = .largeTitle
    static let appHeadlineMedium: Font = .title2
    static let appBodyMedium: Font = .body
    static let appBodySmall: Font = .subheadline
    static let appCaption: Font = .caption
    static let appLabelLarge: Font = .callout.weight(.semibold)
}
