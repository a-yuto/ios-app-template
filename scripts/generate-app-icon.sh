#!/usr/bin/env bash
# AppIcon 用のプレースホルダー PNG (1024x1024) を生成して
# Assets.xcassets/AppIcon.appiconset/ に配置する (niki-sandbox#98)。
#
# AppIcon.appiconset に PNG が1枚も無いと、App Store 向けアーカイブの検証で
# 必ず弾かれる (シミュレータ実行では困らないため、リリース直前まで気づきにくい)。
# このスクリプトの出力をテンプレートに同梱しておき、リリース前に本物へ差し替える。
#
# 使い方:
#   scripts/generate-app-icon.sh [イニシャル文字]   # 省略時 "A"
#
# 生成物 (iOS 18 の light / dark / tinted 3バリアント構成):
#   AppIcon.png        : グラデーション + イニシャル
#   AppIcon-dark.png   : light と同一 (差し替え時に専用デザインにする)
#   AppIcon-tinted.png : グレースケール版 (sips で自動生成)
#
# 本格的なアイコンを SVG から作る場合は headless Chrome でもレンダリングできる:
#   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
#     --headless --disable-gpu --screenshot=icon.png \
#     --window-size=1024,1024 --hide-scrollbars file://$PWD/icon.html
#   落とし穴: 縦線など zero-width bbox の要素に objectBoundingBox の gradient を
#   当てると描画されない → gradientUnits="userSpaceOnUse" を使うこと。

set -euo pipefail
cd "$(dirname "$0")/.."

INITIALS="${1:-A}"
APPICONSET=$(ls -d ./*/Assets.xcassets/AppIcon.appiconset 2>/dev/null | head -1)
if [[ -z "$APPICONSET" ]]; then
  echo "generate-app-icon.sh: AppIcon.appiconset が見つかりません" >&2
  exit 1
fi

TMP_SWIFT=$(mktemp -t generate-app-icon).swift
trap 'rm -f "$TMP_SWIFT"' EXIT

cat > "$TMP_SWIFT" <<'EOF'
import AppKit

let initials = ProcessInfo.processInfo.environment["ICON_INITIALS"] ?? "A"
let outPath = ProcessInfo.processInfo.environment["ICON_OUT"]!

// NSImage.lockFocus は画面の backing scale に引きずられて 2048px になることが
// あるため、ピクセル数を明示した CGContext に直接描画する。
// App Store のマーケティングアイコンはアルファ無しが必須なので noneSkipLast。
guard let cgContext = CGContext(
    data: nil,
    width: 1024,
    height: 1024,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
    fatalError("CGContext の作成に失敗")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: cgContext, flipped: false)

let rect = NSRect(x: 0, y: 0, width: 1024, height: 1024)
let gradient = NSGradient(
    starting: NSColor(calibratedRed: 0.27, green: 0.47, blue: 0.95, alpha: 1),
    ending: NSColor(calibratedRed: 0.12, green: 0.20, blue: 0.46, alpha: 1)
)!
gradient.draw(in: rect, angle: -60)

let style = NSMutableParagraphStyle()
style.alignment = .center
let text = NSAttributedString(
    string: initials,
    attributes: [
        .font: NSFont.systemFont(ofSize: 440, weight: .bold),
        .foregroundColor: NSColor.white,
        .paragraphStyle: style,
    ]
)
let textSize = text.size()
text.draw(in: NSRect(x: 0, y: (1024 - textSize.height) / 2, width: 1024, height: textSize.height))

NSGraphicsContext.restoreGraphicsState()

guard let cgImage = cgContext.makeImage(),
      let png = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:]) else {
    fatalError("PNG エンコードに失敗")
}
try! png.write(to: URL(fileURLWithPath: outPath))
EOF

LIGHT="$APPICONSET/AppIcon.png"
DARK="$APPICONSET/AppIcon-dark.png"
TINTED="$APPICONSET/AppIcon-tinted.png"

ICON_INITIALS="$INITIALS" ICON_OUT="$LIGHT" swift "$TMP_SWIFT"
cp "$LIGHT" "$DARK"
sips -m "/System/Library/ColorSync/Profiles/Generic Gray Profile.icc" \
  "$LIGHT" --out "$TINTED" >/dev/null

echo "生成完了:"
ls -la "$LIGHT" "$DARK" "$TINTED"
echo "Contents.json の filename が上記3ファイルを指しているか確認してください。"
