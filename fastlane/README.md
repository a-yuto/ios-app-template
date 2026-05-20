# Fastlane

## セットアップ

```bash
bundle install
bundle exec fastlane add_plugin swiftlint   # 初回のみ
```

## レーン一覧

| Lane                              | 用途                                   |
| --------------------------------- | -------------------------------------- |
| `bundle exec fastlane test`       | ユニット + UIテストを実行              |
| `bundle exec fastlane lint`       | SwiftLint を実行                       |
| `bundle exec fastlane beta`       | TestFlight にビルドをアップロード      |
| `bundle exec fastlane release`    | App Store Connect にビルドを送信       |

## 環境変数 (`.env`)

`fastlane/.env` は gitignore 対象です。必要な値:

```env
APP_IDENTIFIER=com.your.bundle.id
FASTLANE_APPLE_ID=you@example.com
FASTLANE_TEAM_ID=XXXXXXXXXX
APP_STORE_CONNECT_API_KEY_PATH=./AuthKey_XXXX.p8
APP_STORE_CONNECT_API_KEY_ID=XXXXXXXXXX
APP_STORE_CONNECT_API_KEY_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```
