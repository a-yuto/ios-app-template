# Xcode Cloud (既定 CI) セットアップ

このテンプレートの **既定 CI は Xcode Cloud** です。以前の GitHub Actions
(`.github/workflows/ci.yml`) は廃止し、CI は Xcode Cloud に一本化しています。

Xcode Cloud のワークフロー定義 (どのブランチで何を走らせるか・環境・デバイス等) は
**App Store Connect 側に保存され、リポジトリには入りません**。リポジトリに入っているのは
次の「下地」だけです:

| 何 | 場所 | 役割 |
| --- | --- | --- |
| 共有スキーム | `ios-app-template.xcodeproj/xcshareddata/xcschemes/ios-app-template.xcscheme` | Xcode Cloud が読む Build/Test 設定。UI テストは `parallelizable = "NO"` (AX タイムアウト対策 niki-sandbox#107) |
| post-clone フック | `ci_scripts/ci_post_clone.sh` | SwiftLint を入れて `--strict` ゲートを実行 (旧 GHA の lint ジョブ相当) |

実際にワークフローを作成・有効化する操作は App Store Connect / Xcode 上で1度だけ必要です。
以下の手順で行ってください。

## 前提

- Apple Developer Program に加入済み (Xcode Cloud は無料枠あり)
- このリポジトリが GitHub などにあり、App Store Connect から接続できること
- Xcode で対象 Apple ID にサインイン済み

## ワークフロー作成手順 (1度だけ)

Xcode から作るのが最短です。

1. **Xcode で `ios-app-template.xcodeproj` を開く**
2. メニュー **Product → Xcode Cloud → Create Workflow** (または Report navigator の Cloud タブ)
3. 対象アプリ/プロダクトとして **`ios-app-template` スキーム** を選択
   - 共有スキームなので一覧に出る (出ない場合は本リポジトリの xcscheme が push 済みか確認)
4. **Start Conditions (開始条件)** を設定:
   - `Pull Request Changes` → ブランチ `main` (PR を全部 CI に通す)
   - 必要なら `Branch Changes` → `main` (push 時にも回す)
5. **Actions (アクション)** に **Test** を追加:
   - Scheme: `ios-app-template`
   - Platform: `iOS`
   - Destination: シミュレータ (例 `iPhone 17` / Recommended Destinations)
   - Test Plan / Scheme の TestAction をそのまま使う (Unit + UITest)
6. (任意) **Archive / TestFlight** アクションは配信を Xcode Cloud に寄せたいときだけ追加。
   ローカル配信は従来どおり `bundle exec fastlane beta` でも可。
7. **環境 (Environment)**: Xcode のバージョンはローカル/`project.pbxproj` の
   `CreatedOnToolsVersion` (現状 26.x) に合わせる。
8. ワークフローを保存し、初回ビルドを走らせて緑を確認。

`ci_scripts/ci_post_clone.sh` は Xcode Cloud が**自動検出**して clone 直後に実行します
(ワークフロー側で個別設定は不要)。ここで SwiftLint のインストールと
`swiftlint --strict` ゲートが走り、違反があればビルドが失敗します。

## CI で走る内容 (旧 GHA との対応)

| 旧 GitHub Actions | Xcode Cloud での担保 |
| --- | --- |
| `lint` ジョブ (`swiftlint --strict`) | `ci_scripts/ci_post_clone.sh` |
| `test` ジョブ Build ステップ | Test アクションのビルド |
| `test` ジョブ Unit/UI テスト | Test アクション (共有スキームの TestAction、UI は並列 OFF) |

## フレーク対策 (このテンプレに入っている前提)

Xcode Cloud は共有ランナーで CPU 競合・ジッタが大きいため、以下を前提化済み:

- **UI テストの並列実行 OFF** (`parallelizable = "NO"`): AX `Timed out waiting for AX
  loaded notification` 対策 (niki-sandbox#107)
- **タイムアウト既定を緩めに**: `waitUntil` 既定 10s / `waitForExistence` 30s
  (成立で即 return するので成功時は遅くならない / niki-sandbox#108)
- **過渡状態でなく安定状態を待つ** UI テスト方針 (niki-sandbox#109、`CLAUDE.md` 参照)

## ローカル事前チェック

Xcode Cloud に投げる前に、CI と同じ内容をローカルで確認できます (`CLAUDE.md`
「コミット前ローカルチェック」参照):

```bash
source scripts/dev-env.sh
swiftlint --strict --reporter emoji   # = ci_post_clone.sh のゲート
bundle exec fastlane test             # = Test アクション相当 (Unit + UI)
```

## トラブルシュート

- **スキームが Xcode Cloud に出ない**: 共有スキーム
  (`xcshareddata/xcschemes/ios-app-template.xcscheme`) が push されているか確認。
  `xcuserdata` 配下のスキームは Xcode Cloud から見えない。
- **`swiftlint: command not found`**: `ci_scripts/ci_post_clone.sh` に実行権限
  (`chmod +x`) が付いたままコミットされているか確認 (`git ls-files -s` のモードが
  `100755`)。
- **AX タイムアウトが復活した**: スキームの TestAction で UI テストの
  `parallelizable` が `NO` のままか確認。
