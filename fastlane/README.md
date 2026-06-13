# Fastlane

## セットアップ

```bash
bundle install
```

## レーン一覧

| Lane                                 | 用途                                          |
| ------------------------------------ | --------------------------------------------- |
| `bundle exec fastlane test`          | ユニット + UIテストを実行                     |
| `bundle exec fastlane lint`          | SwiftLint を実行                              |
| `bundle exec fastlane screenshots`   | App Store 用スクリーンショットを撮影          |
| `bundle exec fastlane beta`          | TestFlight にビルドをアップロード             |
| `bundle exec fastlane release`       | App Store Connect にビルドを送信              |

## App Store Connect API キーの準備 (beta / release に必須)

`upload_to_testflight` / `upload_to_app_store` は ASC API キーか Apple ID + 2FA
セッションのどちらかが必要。API キーの方が CI でも使えて圧倒的に楽:

1. App Store Connect → **ユーザとアクセス** → **統合** → **App Store Connect API**
2. **チームキー** を役割 **App Manager** で作成
3. `.p8` をダウンロードして `~/.appstoreconnect/` など gitignore された場所に置く
   (ダウンロードは1回しかできない)
4. 下記の環境変数を設定して `bundle exec fastlane beta`

```bash
export ASC_KEY_ID="XXXXXXXXXX"          # キーID
export ASC_ISSUER_ID="xxxxxxxx-...."    # Issuer ID
export ASC_KEY_PATH="$HOME/.appstoreconnect/AuthKey_XXXXXXXXXX.p8"
```

キー未設定の場合は Apple ID 認証にフォールバックする (2FA の対話入力が必要)。

## 環境変数 (`.env`)

`fastlane/.env` は gitignore 対象です。必要な値:

```env
# app_identifier は通常 project.pbxproj から自動解決されるため設定不要。
# 上書きしたい場合のみ:
# APP_IDENTIFIER=com.your.bundle.id

FASTLANE_APPLE_ID=you@example.com
FASTLANE_TEAM_ID=XXXXXXXXXX

ASC_KEY_ID=XXXXXXXXXX
ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ASC_KEY_PATH=/Users/you/.appstoreconnect/AuthKey_XXXXXXXXXX.p8
```
