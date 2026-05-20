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

### Unit テストの粒度

- SwiftData の `@Model` は、初期化と振る舞いを最低1ケース。
- ロジックを持つ `@Observable` クラスは、状態遷移ごとにケースを書く。
- `View` 自体の単体テストは原則書かない (E2E でカバーする)。

### CI での扱い

`.github/workflows/ci.yml` で以下を全PRで実行します。1つでも落ちたらマージ不可:

- `lint` (SwiftLint `--strict`)
- `build-and-test` (Build + Unit Test)
- `ui-test` (XCUITest)

CI を落としたままの放置は禁止。

### ローカル実行

```bash
# 全テスト (Unit + UI)
bundle exec fastlane test

# Unit のみ
xcodebuild test \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
  -only-testing:ios-app-templateTests | xcbeautify

# UI のみ
xcodebuild test \
  -project ios-app-template.xcodeproj \
  -scheme ios-app-template \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
  -only-testing:ios-app-templateUITests | xcbeautify
```

## プロジェクトの基本構成

- **アーキテクチャ**: MV (SwiftUI + `@Observable` を基本)。ViewModel層は最初は導入しない。
- **永続化**: SwiftData (`@Model`)。
- **最低サポート iOS**: 17.0
- **テスト**: Unit は Swift Testing (`@Test`)、UI は XCUITest。
- **Lint / Format**: SwiftLint + SwiftFormat。
- **CI**: GitHub Actions (`.github/workflows/ci.yml`)。
- **配信**: Fastlane (`fastlane/`)。

詳細とセットアップ手順は `README.md` を参照してください。
