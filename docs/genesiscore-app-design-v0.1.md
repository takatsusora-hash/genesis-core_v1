# GenesisCore App 設計 v0.1

## 1. 目的
GenesisCore App は、占星術分析の単発利用をやめ、**自己理解を継続的に深める母艦アプリ**として設計する。

- 入口: 出生情報に基づく分析
- 中核: 独自タイプ + AI会話 + 日次ログ
- 成果: 検証データ回収による分析精度向上

### Web版との違い
- Web版: 入力 → 分析 → 結果表示/PDF → 終了
- App版: 登録 → 分析保存 → 独自タイプ → AI会話 → 日次ログ → 検証回収 → ニュース配信

---

## 2. スコープ

### やること（MVP v0.1）
1. アカウント登録
2. 出生情報登録
3. 分析結果保存
4. 独自タイプ表示
5. AI会話（3モード）
6. 日次ログ
7. 検証フィードバック
8. Labニュース
9. Free/Plus（500円想定）権限フラグ

### やらないこと
- 未来予測
- 本格SaaS課金プラン
- SNS/コミュニティ/ライブ相談
- 毎月未来レポート
- 高度研究ダッシュボード（管理側で後回し）

---

## 3. 技術構成

### 全体アーキテクチャ
- Flutter App（iOS/Android）
- Firebase Auth
- Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Analytics
- Cloud Functions
- GenesisCore Analysis API
- AI Chat API（Cloud Functions 経由）

### 採用方針
- 状態管理: Riverpod
- 画面遷移: go_router
- DB: Cloud Firestore
- 認証: Firebase Auth
- 通知: Firebase Cloud Messaging
- 課金: v0.1では実装保留（planフラグのみ）

### 自作優先領域
1. GenesisCore独自タイプ計算
2. AI会話用プロファイル圧縮
3. 検証フィードバック設計
4. GenesisCoreらしいUI情報設計

---

## 4. 画面構成

### Bottom Navigation（5タブ）
1. Home
2. My Core
3. AI Chat
4. Log
5. Lab

### 右上メニュー
- アカウント
- 通知設定
- データ管理
- 同意設定
- 有料プラン
- ヘルプ

---

## 5. 主要画面要件

### Home
- 今日の状態カード
- 「今日の記録」導線
- Genesis Type の要約
- AI相談導線
- 最新Labニュース、前回会話、未回答フィードバック

### My Core
- Genesis Type
- 4分類軸スコア
- 西洋/インド占星術サマリー
- Big Five サマリー
- AI要約プロフィール
- 分析履歴

### AI Chat
- 自己理解モード
- 行動整理モード
- 検証モード

### Log（軽量）
- 気分/集中/行動量/対人ストレス/疲労（各1〜5）
- 一言メモ
- タイプ一致度
- 今日強く出た傾向

### Lab
- 検証参加人数
- タイプ別傾向
- Big Five一致傾向
- 西洋/インド比較
- 研究メモ
- 更新情報

---

## 6. 独自タイプ（Archetype）設計

### 変換フロー
占星術データ → スコア化 → 4分類軸 → 16タイプ

### 4分類軸
1. 起動力: 発火型 / 蓄積型
2. 認知: 直観型 / 構造型
3. 感情処理: 即応型 / 深層型
4. 社会接続: 個人主導型 / 関係調整型

> 外部表示は16タイプ中心、内部は詳細スコアを保持。

### 内部スコア（例）
- ignition/cognition/emotion/social
- 4元素、3区分
- sun/moon/mars/mercury/venus/jupiter/saturn strength
- lagna/nakshatra profile

---

## 7. AI会話設計

### ai_profile_summary（毎回送る圧縮情報）
- Genesis Type
- 4軸スコア
- 西洋/インド主要特徴
- Big Five傾向
- 注意すべき反応、励まし方、避けるべき言い方

### 推論入力順
System Prompt → AI人格設定 → ai_profile_summary → 直近ログ → 直近会話 → ユーザー入力

### 保存
- chat_sessions
- chat_messages
- 会話後評価（納得度/実用度/再利用意向）

---

## 8. 検証データ設計
1. 明示的フィードバック
2. 日次ログ
3. 会話後評価

これにより、占星術指標 × 独自タイプ × 心理傾向 × 行動ログ × AI評価を連結する。

---

## 9. Firestore コレクション
- users
- profiles
- analyses
- archetypes
- daily_logs
- feedback
- chat_sessions
- chat_messages
- lab_news
- entitlements

### 権限の基本
`plan: free | plus`

---

## 10. API（Cloud Functions）
- profile: create/update/me
- analysis: run/latest/detail
- archetype: compile/me
- chat: start/message/end
- log: daily/recent
- feedback: submit/pending
- lab: news/stats

---

## 11. Free / Plus（500円想定）

### Free
- 独自タイプ表示
- 基本分析保存
- AI会話 1日3回
- 日次ログ
- ニュース閲覧

### Plus
- AI会話 1日30回
- 詳細タイプ説明
- 複数分析履歴
- PDF閲覧
- 月次まとめ
- ニュース詳細

---

## 12. 通知（初期4種）
1. 日次記録リマインド
2. AI会話リマインド
3. 検証ニュース
4. 未回答フィードバック

---

## 13. 管理機能（初期）
- KPI確認（登録、分析、会話、ログ、FB、Free/Plus）
- Labニュース投稿
- ユーザー検索
- Plus手動付与
- フィードバック設問管理

初期運用は Firebase Console + 簡易管理UIで対応する。

---

## 14. ディレクトリ方針
- Flutter: `lib/app`, `lib/core`, `lib/features/*`, `lib/shared`
- Functions: `functions/src/modules/*`, `services/*`, `utils/*`

---

## 15. 開発順序
1. 基盤（Flutter/Firebase/Auth/Router/Riverpod）
2. プロフィール
3. 分析連携
4. 独自タイプ
5. AI会話
6. 日次ログ
7. Lab
8. Free/Plus権限

---

## 16. プロダクト核（重要）
このアプリの核は「分析結果を毎日の記録と会話に接続すること」。

占星術分析 → 独自タイプ → AI会話 → 日次ログ → 検証 → 分析改善

この循環の成立を v0.1 の完成条件とする。
