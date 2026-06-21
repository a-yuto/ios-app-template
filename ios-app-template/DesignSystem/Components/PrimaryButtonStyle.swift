//
//  PrimaryButtonStyle.swift
//  ios-app-template
//

import SwiftUI

// AppPrimary / AppOnPrimary カラーセットを差し替えるだけでテーマが変わる
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appLabelLarge)
            .foregroundStyle(Color.appOnPrimary)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        Button("プライマリボタン") {}
            .buttonStyle(PrimaryButtonStyle())
        Button("無効状態") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
    }
    .padding(Spacing.lg)
}
