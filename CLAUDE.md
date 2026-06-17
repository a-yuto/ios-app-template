# CLAUDE.md

このリポジトリは、個人開発でiOSアプリを始める際の出発点となるテンプレートです。Claude Code がこのプロジェクト(およびこのテンプレートを複製して作られたプロジェクト)で作業する際の前提を以下にまとめます。

## Issue 管理

このテンプレートおよび、このテンプレートから派生する個人開発プロジェクトのissueは **すべて以下のリポジトリに集約** します。各プロジェクトのリポジトリには個別にissueを立てません。

- **集約先**: https://github.com/a-yuto/niki-sandbox/issues

### 運用ルール

- バグ報告 / 機能要望 / TODO / 検討メモ など、issueとして残したいものは上記リポジトリに作成する。
- どのプロジェクトのissueかを判別できるよう、**ラベルまたはタイトル接頭辞でプロジェクト名を付与する** (例: `[ios-app-template] ...`)。
- issueを参照・作成・更新する操作は `gh` CLI で `--repo a-yuto/niki-sandbox` を明示して行う。

```bash
# 例: issueを作成
gh issue create --repo a-yuto/niki-sandbox --title "[ios-app-template] ..." --body "..."

# 例: issue一覧を取得
gh issue list --repo a-yuto/niki-sandbox
```

Claude Code に issue 関連の作業を依頼する場合は、上記リポジトリを既定の対象として扱ってください。ローカルのリポジトリ名から推測した別のリポジトリに対してissue操作を行ってはいけません。

## テスト方針 (徹底ルール)

このテンプレートとその派生プロジェクトでは、**機能追加・修正時に必ずテストを書く** ことを必須とします。「あとで書く」は禁止です。Claude Code が実装を行う場合も、テストなしで完了報告してはいけません。

### 必須レイヤー

| レイヤー       | ツール                  | 何をテストするか                                                                  |
| -------------- | ----------------------- | --------------------------------------------------------------------------------- |
| **Unit**       | Swift Testing (`@Test`) | モデル / ロジック / `@Observable` クラスの状態遷移 / 純粋関数                     |
| **E2E (UI)**   | XCUITest                | ユーザー操作のゴールデンパス。画面の追加・主要ボタンの動作変更・遷移は必ずカバー  |

### 実装時のルール

1. **新規機能を追加したら、Unit + E2E の両方を追加する。** 片方だけで終わらせない。
2. **バグ修正は、まず再現テスト (Unit か E2E) を書いてから直す。** 再発防止が目的。
3. **既存テストが落ちている状態でPRを出さない / マージしない。** ローカルで `bundle exec fastlane test` がグリーンであることを確認。
4. **Claude Code がコード変更を行うときは、関連するテストの追加・更新も同じ変更セットに含める。** 「テストは別途」は不可。
5. **テストが書きにくい設計に出会ったら、設計を見直す。** モックを増やすのではなく、依存を減らす方向で対処。

### E2E テストの最低ライン

各画面について、少なくとも以下を1ケースずつ用意:

- 画面が表示できること (主要要素の `waitForExistence`)
- 主要なユーザー操作 (タップ / 入力) が期待どおりの状態変化を起こすこと
- 画面遷移が想定どおりに動くこと

#### 過渡状態でなく安定状態を待つ (niki-sandbox#109)

UI テストでは **短時間しか表示されない過渡状態や、周期的に切り替わる状態を待ってはいけない**。一度成立したら持続する安定状態 (例: 「アイドルでない」) を待つこと。過渡状態の検証は Unit テストで行う。

- NG: 「録音中」のように録音/再生ループ中 ~0.5s しか出ない過渡状態を述語ポーリングで待つ。CI の遅さで窓を取りこぼし、timeout を伸ばしても捕まらない (設計上の脆さ)。
- OK: 「待機中から抜けた = 動作中」のように、一度成立したら成立し続ける安定状態を待つ (`label != "待機中"` 等)。
- 細かい遷移 (録音中 → 再生中) は Unit テストで担保し、UI テストは「ボタンが状態を切り替える」を安定状態で検証する粒度にする。

### Unit テストの粒度

- SwiftData の `@Model` は、初期化と振る舞いを最低1ケース。
- ロジックを持つ `@Observable` クラスは、状態遷移ごとにケースを書く。
- `View` 自体の単体テストは原則書かない (E2E でカバーする)。

### UI テストの起動規約

UI テストでのアプリ起動は、素の `XCUIApplication().launch()` ではなく **共通起動ヘルパー `XCUIApplication.launchForUITest()`** (`ios-app-templateUITests/XCUIApplication+Launch.swift`) を使う。起動引数をファイルごとにコピペすると、フラグを1つ足すたびに全ファイルを直すことになるため。

1. **初回起動時オーバーレイ (オンボーディング・告知等) を追加するときは、必ず `-skipXXX` launch argument を併設し、共通起動ヘルパーのデフォルトに含める。** これを怠ると既存 UI テストがすべてオーバーレイに遮られて落ちる。オーバーレイ自体のテストだけが明示的にフラグを外して素の起動を使う。
2. **外部依存 (audio / store / ads など) を増やすときは、mock 用 launch argument も同時に追加し、ヘルパーのデフォルトに含める。**

### UI テスト用 accessibilityIdentifier の付け方 (niki-sandbox#110)

**`accessibilityIdentifier` は葉の操作要素 (Button 本体など) に付ける。Button を含むコンテナ (VStack 等) には付けない。**

コンテナに `accessibilityIdentifier` を付けると、SwiftUI が **内側の Button や、場合によっては後続の兄弟要素まで 1 個のアクセシビリティ要素に統合**してしまい、内側の identifier が AX ツリーから消える。結果として UI テストが内側のボタンを見つけられなくなる。

- 折りたたみパネル等のタップ対象には、外側コンテナではなく **ヘッダ Button 自身** に identifier を付ける。
- 要素が見つからないときは UI テストで `print(app.debugDescription)` し、AX ツリーで実際の要素型 / identifier を確認するのが速い。

### App Store スクリーンショット撮影

`ScreenshotCaptureUITests` は撮影専用テストで、環境変数 `CAPTURE_SCREENSHOTS=1` が無い限り XCTSkip される (通常の CI / `fastlane test` には影響しない)。撮影は `bundle exec fastlane screenshots`。新しい主要画面を追加したら撮影ケースも追加する。

### CI での扱い

**既定 CI は Xcode Cloud** です (GitHub Actions は廃止)。`main` への PR / push で以下が走り、1つでも落ちたらマージ不可:

- **lint ゲート** (`ci_scripts/ci_post_clone.sh` が SwiftLint `--strict` を実行)
- **Test アクション** (共有スキーム `ios-app-template.xcscheme` の TestAction = Build + Unit + XCUITest。UI テストは AX タイムアウト対策で `parallelizable = "NO"`)

ワークフロー定義は App Store Connect 側にあり、リポジトリにはコミットできない。リポジトリに入るのは共有スキームと `ci_scripts/` のフックだけ。セットアップ手順は [`docs/XCODE_CLOUD.md`](docs/XCODE_CLOUD.md) を参照。CI を落としたままの放置は禁止。

### コミット前ローカルチェック (必須)

**`git commit` を実行する前に、CI と同じコマンドをローカルで必ず走らせてグリーンを確認する。** CI で初めて気づくのは禁止。Claude Code がコミットを行う場合も例外なくこの手順を踏むこと。

#### 0. ツールチェーンの確認 (最初に1回)

`xcode-select -p` が `/Library/Developer/CommandLineTools` を指している環境では、swiftlint (SourceKit ロード失敗) / `xcrun simctl` / fastlane scan がすべて壊れる。以下のチェックコマンドを流す前に必ず:

```bash
source scripts/dev-env.sh   # Xcode.app を自動検出して DEVELOPER_DIR を export する
```

#### 1. Lint (CI: lint ゲート `ci_scripts/ci_post_clone.sh` と同等)

```bash
swiftlint --strict --reporter emoji
```

#### 2. Build for testing (CI: Test アクションの Build 相当)

```bash
set -o pipefail
xcodebuild \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "generic/platform=iOS Simulator" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build-for-testing | xcbeautify
```

#### 3. Unit Test (CI: Test アクションの Unit テスト相当)

```bash
set -o pipefail
UDID=$(scripts/pick-simulator.sh)
xcodebuild \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "platform=iOS Simulator,id=$UDID" \
  -configuration Debug \
  -only-testing:ios-app-templateTests \
  CODE_SIGNING_ALLOWED=NO \
  test-without-building | xcbeautify
```

#### 4. UI / E2E Test (CI: Test アクションの UI テスト相当)

```bash
set -o pipefail
UDID=$(scripts/pick-simulator.sh)
xcodebuild \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "platform=iOS Simulator,id=$UDID" \
  -configuration Debug \
  -only-testing:ios-app-templateUITests \
  CODE_SIGNING_ALLOWED=NO \
  test | xcbeautify
```

#### まとめて流す (推奨)

```bash
bundle exec fastlane lint && bundle exec fastlane test
```

> `scripts/pick-simulator.sh` は優先順 (iPhone 17 系 → 16 系 → ...) で利用可能な simulator を1つ選び、UDID を返す (ローカル実行用。Xcode Cloud は workflow 側で destination を指定する)。明示指定したい場合は `SIMULATOR_NAME="iPhone 16 Pro" scripts/pick-simulator.sh`。

### テスト変更時のユーザー確認 (必須)

**既存テストの修正・削除・スキップを行う場合は、Claude Code は実装前に必ずユーザーに確認すること。** これは例外なし、自動判断禁止。

- 対象: `ios-app-templateTests/` および `ios-app-templateUITests/` 配下の既存テスト
- 確認が必要な操作:
  - 既存テストケースの assertion / 期待値の変更
  - 既存テストケースの削除や `disabled` / `skip` 化
  - テスト対象のリネーム・移動でテストが追従できなくなるケース
- 確認なしで進めて良い操作:
  - **新しいテストの追加** (むしろ追加は徹底ルール参照)
  - 機能の挙動変更に伴って、既存テストが落ちるためのテスト更新を提案すること自体は可。**ただし変更コミット前にユーザーの合意を取る。**

**理由**: テストはプロダクトコードと違って「仕様の最後の砦」として機能している。仕様変更がテスト変更を必須とするときも、ユーザーが意図した変更かを必ず人間が判断する必要がある。テストを通すために assertion を緩めるような対処をClaude Codeが独断で行うのは絶対に禁止。

### ローカル実行

```bash
# 全テスト (Unit + UI)
bundle exec fastlane test

# Unit のみ
UDID=$(scripts/pick-simulator.sh)
xcodebuild test \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:ios-app-templateTests | xcbeautify

# UI のみ
UDID=$(scripts/pick-simulator.sh)
xcodebuild test \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "platform=iOS Simulator,id=$UDID" \
  -only-testing:ios-app-templateUITests | xcbeautify
```

## プロジェクトの基本構成

- **アーキテクチャ**: MV (SwiftUI + `@Observable` を基本)。ViewModel層は最初は導入しない。
- **永続化**: SwiftData (`@Model`)。
- **最低サポート iOS**: 17.0
- **テスト**: Unit は Swift Testing (`@Test`)、UI は XCUITest。
- **Lint / Format**: SwiftLint + SwiftFormat。
- **CI**: Xcode Cloud (共有スキーム + `ci_scripts/`。手順は `docs/XCODE_CLOUD.md`)。
- **配信**: Fastlane (`fastlane/`)。

詳細とセットアップ手順は `README.md` を参照してください。
