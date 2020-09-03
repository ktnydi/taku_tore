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

UI部分はFlutter、機能部分は主にFirebaseを使って実装してました。

報告機能、フィードバック機能はGASを使ってAPIを作成しGSSに内容を保存してSlackに通知がいくような仕組みにしました。



**使用技術**

- Flutter
- Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Cloud Functions
  - Cloud Storage
  - Firebase Cloud Messaging
- Google Spread Sheet
- Google App Script
