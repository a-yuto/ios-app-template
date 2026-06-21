//
//  Color+App.swift
//  ios-app-template
//

import SwiftUI

extension Color {
    // MARK: - Brand / Primary
    // AppPrimary.colorset / AppOnPrimary.colorset を差し替えるだけでテーマ変更できる

    static let appPrimary = Color("AppPrimary")
    static let appOnPrimary = Color("AppOnPrimary")

    // MARK: - Semantic (システムカラー参照)

    static let appBackground = Color(uiColor: .systemBackground)
    static let appSecondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let appLabel = Color(uiColor: .label)
    static let appSecondaryLabel = Color(uiColor: .secondaryLabel)
    static let appSeparator = Color(uiColor: .separator)
}
