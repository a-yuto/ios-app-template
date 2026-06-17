# ios-app-template

個人開発用の iOS アプリスターターテンプレート。
"Use this template" でクローンし、最低限の改名だけで実装を始められる構成。

## スタック

| 項目        | 採用                                           |
| ----------- | ---------------------------------------------- |
| UI          | SwiftUI                                        |
| アーキテクチャ | MV (`@Observable` + View)                     |
| 永続化      | SwiftData (`@Model`)                           |
| 最低 iOS    | 17.0                                           |
| Unit Test   | Swift Testing (`@Test`)                        |
| UI Test     | XCUITest                                       |
| Lint/Format | SwiftLint + SwiftFormat                        |
| CI          | Xcode Cloud (`ci_scripts/` + 共有スキーム)      |
| 配信        | Fastlane (`fastlane/`)                         |

## クイックスタート

### 1. プロジェクト名の変更

テンプレートからクローンしたら、まず置換でリネームします。`ios-app-template` / `ios_app_template` を新しいプロジェクト名に置き換えてください。

```bash
NEW_NAME="my-cool-app"        # ハイフン区切り
NEW_NAME_UNDERSCORE="my_cool_app"  # スネーク (Swiftシンボル用)

# ファイル / ディレクトリ名を置換
find . -depth -name "*ios-app-template*" -execdir bash -c 'mv "$1" "${1/ios-app-template/'"$NEW_NAME"'}"' _ {} \;
find . -depth -name "*ios_app_template*" -execdir bash -c 'mv "$1" "${1/ios_app_template/'"$NEW_NAME_UNDERSCORE"'}"' _ {} \;

# ファイル内容を置換
grep -rl "ios-app-template" --include="*.swift" --include="*.yml" --include="*.pbxproj" --include="*.md" --include="Fastfile" --include="Appfile" --include="Gemfile" --include="Pluginfile" --include="*.sh" . | xargs sed -i "" "s/ios-app-template/$NEW_NAME/g"
grep -rl "ios_app_template" --include="*.swift" --include="*.yml" --include="*.pbxproj" --include="*.md" . | xargs sed -i "" "s/ios_app_template/$NEW_NAME_UNDERSCORE/g"
```

> Xcode を一度閉じてから実行し、その後 Xcode で開き直してください。

### 2. Bundle ID / Team ID の差し替え

テンプレートのデフォルトはプレースホルダー値 (`com.example.*` / Team ID 空) です。
**そのままでもシミュレータでのビルド・テストは通りますが、実機・TestFlight 前に必ず差し替えてください。**

```bash
BUNDLE_PREFIX="com.yourdomain"   # あなたの Bundle ID プレフィックス

# Bundle ID (app / Tests / UITests の3箇所) を一括差し替え
sed -i "" "s/com\.example\./$BUNDLE_PREFIX./g" "$NEW_NAME.xcodeproj/project.pbxproj"

# Team ID は Xcode の Signing & Capabilities で設定するか、pbxproj の
# DEVELOPMENT_TEAM = ""; を直接編集

# 差し替え漏れの検知 (何も出なければOK)
grep -rn "com.example" --include="*.pbxproj" .
```

> `fastlane/Appfile` の `app_identifier` は pbxproj から自動解決されるため、編集不要です。

### 3. 依存ツールのインストール

```bash
# Homebrew で
brew install swiftlint swiftformat xcbeautify
```

#### Ruby (Fastlane 用)

Fastlane の最新版は Ruby 3.x を要求し、macOS 標準 Ruby (2.6) では動きません。`rbenv` 等で `.ruby-version` に揃えてください。

```bash
brew install rbenv ruby-build
rbenv install   # .ruby-version の版 (3.3.5) が入る
rbenv rehash
```

シェルの初期化 (`~/.zshrc` 等) に `eval "$(rbenv init - zsh)"` を追記しておきます。

#### Bundler / Fastlane

```bash
bundle install
```

### 4. 動作確認

```bash
# xcode-select が CommandLineTools を指している環境では swiftlint / simctl が
# 壊れるため、まず DEVELOPER_DIR を通す (詳細はスクリプト内コメント参照)
source scripts/dev-env.sh

# ビルド + Unit + UI テスト
bundle exec fastlane test

# Lint
bundle exec fastlane lint
```

## 開発フロー

### 日常コマンド

```bash
# 最初に1回 (シェルごと): Xcode ツールチェーンを通す
source scripts/dev-env.sh

# Format
swiftformat .

# Lint
swiftlint

# Unit テストのみ (simulator は scripts/pick-simulator.sh が動的に選ぶ)
UDID=$(scripts/pick-simulator.sh)
xcodebuild test \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:ios-app-templateTests | xcbeautify
```

### テスト方針 (徹底)

機能追加・バグ修正のたびに **Unit (Swift Testing) と E2E (XCUITest) の両方を必ず追加** します。後回しは禁止、テストなしのマージも禁止。詳細ルールは [`CLAUDE.md`](CLAUDE.md#テスト方針-徹底ルール) に集約しています。

### CI

**既定 CI は Xcode Cloud** です (GitHub Actions は廃止)。`main` への PR / push で以下が走ります。

- **lint ゲート**: `ci_scripts/ci_post_clone.sh` が SwiftLint (`--strict`) を実行
- **Test アクション**: 共有スキームの TestAction = build + Unit + XCUITest (UI は AX タイムアウト対策で並列 OFF)

ワークフローは App Store Connect 側で作成・有効化が必要です。手順は [`docs/XCODE_CLOUD.md`](docs/XCODE_CLOUD.md) を参照。

### App Store スクリーンショット

撮影専用 UI テスト (`ScreenshotCaptureUITests`) で再現性のあるスクリーンショットを撮れます。
UI が変わっても1コマンドで撮り直せます。

```bash
bundle exec fastlane screenshots
# → fastlane/screenshots/ に書き出される
```

### TestFlight 配信

```bash
# App Store Connect API Key を fastlane/.env に設定後
bundle exec fastlane beta
```

API キーの作成手順を含む詳細は [`fastlane/README.md`](fastlane/README.md) を参照。

### リリース準備

App Store 申請に必要なコード外の作業 (ASC 設定・メタデータ・プライバシーラベル等) は
[`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md) に順序付きでまとめています。
リードタイムの長い項目があるため、申請の数日前に一読を推奨。

## ディレクトリ構成

```
.
├── ci_scripts/
│   └── ci_post_clone.sh             # Xcode Cloud フック: SwiftLint 導入 + lint ゲート
├── .gitignore                       # Xcode / Fastlane 用
├── .swiftformat                     # SwiftFormat 設定
├── .swiftlint.yml                   # SwiftLint 設定
├── CLAUDE.md                        # Claude Code 向けプロジェクト情報
├── Config/
│   └── Info.plist                   # 手書き Info.plist (同期グループ外に置く)
├── Gemfile                          # Fastlane の依存
├── README.md
├── docs/
│   ├── RELEASE_CHECKLIST.md         # App Store 申請チェックリスト
│   └── XCODE_CLOUD.md               # Xcode Cloud (既定 CI) セットアップ手順
├── fastlane/                        # Fastlane 設定
│   ├── Appfile
│   ├── Fastfile
│   └── README.md
├── scripts/
│   ├── dev-env.sh                   # DEVELOPER_DIR を自動設定 (source して使う)
│   ├── generate-app-icon.sh         # プレースホルダー AppIcon 生成
│   └── pick-simulator.sh            # ローカル/CI 共通: iPhone Simulator 動的選択
├── ios-app-template/                # アプリ本体
│   ├── Assets.xcassets/
│   ├── ContentView.swift
│   ├── Item.swift                   # SwiftData モデルのサンプル
│   └── ios_app_templateApp.swift
├── ios-app-template.xcodeproj/
├── ios-app-templateTests/           # Unit (Swift Testing)
└── ios-app-templateUITests/         # UI / E2E (XCUITest)
```

## Issue 管理

このテンプレートおよび派生プロジェクトの issue は **すべて** [`a-yuto/niki-sandbox`](https://github.com/a-yuto/niki-sandbox/issues) に集約します。詳細は [`CLAUDE.md`](CLAUDE.md) を参照。
