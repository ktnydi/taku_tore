# TakuTore
フィットネス講師と繋がれるマッチングアプリ

iOS：https://apps.apple.com/us/app/id1529380989



**モチベーション**

本格的なフィットネスを行うためにはジムに行くことが多いと思いますが、コロナ禍で外出を控えるようになりオンライン上で行えるようにはできないかと思って開発しました。



**機能**

- ユーザー認証機能
- SNS認証機能
- 画像投稿機能
- 講師登録機能
- レビュー機能
- ブックマーク機能
- 1対1のリアルタイムチャット機能
- 無限スクロール機能
- ユーザーブロック機能
- 報告機能
- フィードバック投稿機能
- 通知機能
- 強制アップデート機能

**追加予定の機能**

- 検索機能
- 決済機能

UI部分はFlutter、機能部分は主にFirebaseを使って実装しました。

報告機能、フィードバック機能はGASを使ってAPIを作成しGSSに内容を保存してSlackに通知がいくような仕組みにしました。

リファクタリングによるDB構造の変化やバグの改修などで利用者に必ずアップデートをするよう促すために強制アップデート機能を実装しました。

検索機能はAlgolia、決済機能はStripeまたはPaypalを使ってみたいなと思っています。

**使用技術**

- Flutter
- Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Cloud Functions
  - Cloud Storage
  - Firebase Cloud Messaging
  - Firebase Remote Config
- Google Spread Sheet
- Google App Script
