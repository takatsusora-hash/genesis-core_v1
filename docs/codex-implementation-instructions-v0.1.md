# GenesisCore App Codex Implementation Instructions v0.1

この文書は、GenesisCore App v0.1 を Codex / AI Agent が実装するための施工指示書である。

既存の `docs/genesiscore-app-design-v0.1.md` はプロダクト設計の正本とする。本書はその実装分解版として扱う。

---

## 0. 絶対方針

GenesisCore App v0.1 は、未来予測アプリではない。

目的は以下に限定する。

1. ユーザーをアカウント単位で保持する。
2. 出生情報と分析結果を保存する。
3. 占星術指標を独自タイプとして圧縮表示する。
4. AI会話で自己理解・行動整理・検証を行う。
5. 日次ログとフィードバックで検証データを回収する。
6. Labニュースで進化・検証中のプロダクトであることを示す。

実装時に以下を追加してはいけない。

- 未来予測機能
- 本格SaaS課金
- SNS / コミュニティ
- ライブ占い師相談
- 複雑な研究者向けダッシュボード
- 重いオンボーディング
- 初期MVPに不要なアニメーション過多UI

---

## 1. 完成条件

v0.1 の完成条件は、次のユーザーフローが通ること。

```text
新規ユーザーがアプリを起動
  ↓
メールまたはGoogle/Appleでログイン
  ↓
出生情報を登録
  ↓
分析結果が保存される
  ↓
Genesis Type が表示される
  ↓
AI Chat で3モードのいずれかを使える
  ↓
日次ログを保存できる
  ↓
検証フィードバックを1件送れる
  ↓
Labニュースを閲覧できる
```

この流れが実機またはエミュレータで確認できれば、v0.1 の骨格完成とする。

---

## 2. 技術スタック固定

### App

- Flutter
- Dart
- Riverpod
- go_router
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Firebase Analytics

### Backend

- Firebase Cloud Functions
- TypeScript
- Firestore Admin SDK
- AI API接続は Cloud Functions 経由
- GenesisCore Analysis API 接続も Cloud Functions 経由

### 課金

v0.1 では課金実装を行わない。
Firestore の `entitlements/{userId}` に `plan: free | plus` を保存し、UIと制限だけ分岐できるようにする。

---

## 3. リポジトリ構成

最終的に以下の構成を目指す。

```text
/
  README.md
  docs/
    genesiscore-app-design-v0.1.md
    codex-implementation-instructions-v0.1.md
    firestore-schema-v0.1.md
    archetype-engine-spec-v0.1.md
    ai-chat-spec-v0.1.md

  app/
    pubspec.yaml
    lib/
      main.dart
      app/
        app.dart
        router.dart
        theme.dart
      core/
        constants/
        errors/
        firebase/
        network/
        utils/
      shared/
        widgets/
        models/
        services/
      features/
        auth/
        onboarding/
        profile/
        analysis/
        archetype/
        chat/
        log/
        lab/
        settings/

  functions/
    package.json
    tsconfig.json
    src/
      index.ts
      modules/
        profile/
        analysis/
        archetype/
        chat/
        log/
        feedback/
        lab/
        entitlement/
      services/
        genesisCoreAnalysisService.ts
        archetypeCompiler.ts
        aiChatService.ts
        feedbackService.ts
      utils/
        validators.ts
        errors.ts
        logger.ts
```

`app/` は Flutter アプリ本体。  
`functions/` は Firebase Cloud Functions。  
`docs/` は設計正本。

---

## 4. Flutter Feature 構造

各 feature は、原則として以下の3層を持つ。

```text
feature_name/
  data/
    models/
    repositories/
    datasources/
  domain/
    entities/
    usecases/
  presentation/
    pages/
    widgets/
    providers/
```

小さい機能では `domain` を薄くしてよい。  
ただし、画面からFirestoreやFunctionsを直接叩かない。

---

## 5. Flutter 実装タスク分解

### Phase 1: App基盤

作成するファイル例。

```text
app/lib/main.dart
app/lib/app/app.dart
app/lib/app/router.dart
app/lib/app/theme.dart
app/lib/core/firebase/firebase_bootstrap.dart
app/lib/core/errors/app_exception.dart
app/lib/shared/widgets/app_scaffold.dart
app/lib/shared/widgets/primary_button.dart
app/lib/shared/widgets/loading_view.dart
app/lib/shared/widgets/error_view.dart
```

要件。

- Firebase 初期化
- RiverpodScope 設置
- go_router 設定
- BottomNavigation 5タブ準備
- 黒/深紺ベースの GenesisCore 風テーマ
- エラー/ローディング共通UI

受け入れ条件。

- `flutter run` が通る。
- Home / My Core / AI Chat / Log / Lab の空画面に遷移できる。

---

### Phase 2: Auth

対象 feature。

```text
app/lib/features/auth/
```

画面。

- LoginPage
- AuthGate

機能。

- Firebase Auth によるログイン状態監視
- メールログイン
- Googleログイン
- Appleログイン枠の準備
- ログアウト

保存。

ログイン成功時に `users/{userId}` を作成または更新。

必須フィールド。

```ts
users/{userId} {
  userId: string,
  email: string | null,
  displayName: string | null,
  photoUrl: string | null,
  createdAt: Timestamp,
  lastLoginAt: Timestamp,
  consentVersion: string | null,
  isDeleted: boolean
}
```

受け入れ条件。

- 初回ログインで users ドキュメントが作成される。
- 再ログインで lastLoginAt が更新される。
- ログアウトできる。

---

### Phase 3: Onboarding / Profile

対象 feature。

```text
app/lib/features/onboarding/
app/lib/features/profile/
```

入力項目。

- birthDate
- birthTime
- birthPlaceName
- birthLat
- birthLng
- timezone
- unknownBirthTime: boolean
- gender: optional

Firestore。

```ts
profiles/{userId} {
  userId: string,
  birthDate: string,
  birthTime: string | null,
  unknownBirthTime: boolean,
  birthPlaceName: string,
  birthLat: number,
  birthLng: number,
  timezone: string,
  gender: string | null,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

要件。

- 出生時刻不明でも保存できる。
- 緯度経度は最初は手入力または簡易候補でよい。
- 後でGoogle Places等に差し替え可能なRepository構造にする。

受け入れ条件。

- プロフィール未登録ユーザーは Onboarding に飛ぶ。
- 登録済みユーザーは Home に飛ぶ。
- 編集画面からプロフィールを更新できる。

---

### Phase 4: Analysis

対象 feature。

```text
app/lib/features/analysis/
```

目的。

GenesisCore Analysis API の結果を保存し、アプリ内で再利用する。

v0.1 では、既存API接続が未完成でもモックで代替してよい。

Firestore。

```ts
analyses/{analysisId} {
  analysisId: string,
  userId: string,
  status: 'mock' | 'running' | 'completed' | 'failed',
  createdAt: Timestamp,
  updatedAt: Timestamp,
  westernSummary: string,
  jyotishSummary: string,
  bigFiveSummary: string | null,
  pdfUrl: string | null,
  rawResultRef: string | null,
  aiProfileSummary: string,
  errorMessage: string | null
}
```

画面。

- AnalysisLatestCard
- AnalysisHistoryPage
- AnalysisDetailPage

受け入れ条件。

- 最新分析を取得できる。
- 分析がない場合、分析作成導線を出す。
- モック分析でも archetype 生成に進める。

---

### Phase 5: Archetype

対象 feature。

```text
app/lib/features/archetype/
functions/src/services/archetypeCompiler.ts
```

目的。

占星術指標を4軸に圧縮し、16タイプとして表示する。

4軸。

1. ignition: 起動力
2. cognition: 認知
3. emotion: 感情処理
4. social: 社会接続

Firestore。

```ts
archetypes/{userId} {
  userId: string,
  analysisId: string,
  typeCode: string,
  typeName: string,
  typeDescription: string,
  ignitionScore: number,
  cognitionScore: number,
  emotionScore: number,
  socialScore: number,
  confidenceScore: number,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

v0.1 の判定ルール。

- 各スコアは 0〜100。
- 50以上なら A 側、49以下なら B 側。
- typeCode は4文字。

例。

```text
I = ignition high / 起動発火
S = ignition low / 起動蓄積
N = cognition intuitive / 直観
L = cognition logical / 構造
R = emotion reactive / 即応
D = emotion deep / 深層
P = social personal / 個人主導
C = social connective / 関係調整
```

例: `INDP`, `SLDC` など。

v0.1 では計算ソースが不足するため、以下の優先順位で実装する。

1. 既存GenesisCore分析結果にスコアがある場合、それを使う。
2. スコアがない場合、mockCompilerで固定値を生成する。
3. mock値でもUIとDB保存の流れを完成させる。

受け入れ条件。

- My Core に Genesis Type が表示される。
- 4軸スコアがカード表示される。
- Firestore に archetypes/{userId} が保存される。

---

### Phase 6: AI Chat

対象 feature。

```text
app/lib/features/chat/
functions/src/modules/chat/
functions/src/services/aiChatService.ts
```

会話モード。

1. self_understanding
2. action_organize
3. verification

Firestore。

```ts
chat_sessions/{sessionId} {
  sessionId: string,
  userId: string,
  mode: 'self_understanding' | 'action_organize' | 'verification',
  startedAt: Timestamp,
  endedAt: Timestamp | null,
  summary: string | null,
  satisfactionScore: number | null,
  usefulnessScore: number | null
}

chat_messages/{messageId} {
  messageId: string,
  sessionId: string,
  userId: string,
  role: 'user' | 'assistant' | 'system',
  content: string,
  createdAt: Timestamp
}
```

AI入力構造。

```text
System Prompt
GenesisCore AI人格設定
ai_profile_summary
latest_archetype
recent_daily_logs
recent_chat_summary
user_message
```

v0.1 の重要条件。

- AI APIキーはアプリ側に置かない。
- 必ず Cloud Functions 経由にする。
- Free は1日3回まで。
- Plus は1日30回まで。
- 制限は entitlements と usage counter で判定する。

受け入れ条件。

- 3モードから選択できる。
- メッセージ送信でAI応答が返る。
- chat_sessions と chat_messages が保存される。
- Free の回数制限が動く。

---

### Phase 7: Daily Log

対象 feature。

```text
app/lib/features/log/
```

Firestore。

```ts
daily_logs/{logId} {
  logId: string,
  userId: string,
  date: string,
  moodScore: number,
  focusScore: number,
  actionScore: number,
  socialStressScore: number,
  fatigueScore: number,
  memo: string | null,
  typeFitScore: number | null,
  dominantTrait: string | null,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

入力UI。

- 5項目を1〜5で選択
- 一言メモ
- 今日の自分はGenesis Typeに近かったか
- 今日強く出た傾向

受け入れ条件。

- 今日のログを1件保存できる。
- 同日再入力時は更新になる。
- 過去7日分を一覧表示できる。

---

### Phase 8: Feedback

対象 feature。

```text
functions/src/modules/feedback/
```

Firestore。

```ts
feedback/{feedbackId} {
  feedbackId: string,
  userId: string,
  analysisId: string | null,
  targetType: 'analysis' | 'archetype' | 'chat' | 'daily_log' | 'lab_news',
  targetId: string | null,
  question: string,
  answer: string,
  score: number | null,
  freeText: string | null,
  createdAt: Timestamp
}
```

v0.1 の設問。

1. このタイプ説明は自分に近いですか？ 1〜5
2. 西洋占星術サマリーは納得できますか？ 1〜5
3. インド占星術サマリーは納得できますか？ 1〜5
4. AIの回答は役に立ちましたか？ 1〜5

受け入れ条件。

- Home に未回答フィードバックカードを出せる。
- 回答すると feedback に保存される。

---

### Phase 9: Lab

対象 feature。

```text
app/lib/features/lab/
functions/src/modules/lab/
```

Firestore。

```ts
lab_news/{newsId} {
  newsId: string,
  title: string,
  summary: string,
  body: string,
  category: 'research' | 'update' | 'notice',
  publishedAt: Timestamp,
  isPublic: boolean
}
```

v0.1 表示。

- Labニュース一覧
- ニュース詳細
- 簡易統計カード

簡易統計は Cloud Functions で返す。

```ts
{
  userCount: number,
  analysisCount: number,
  dailyLogCount: number,
  feedbackCount: number
}
```

受け入れ条件。

- 公開済みニュースだけ表示される。
- 詳細ページが開ける。
- 統計カードが表示される。

---

### Phase 10: Entitlements

Firestore。

```ts
entitlements/{userId} {
  userId: string,
  plan: 'free' | 'plus',
  source: 'manual' | 'test' | 'purchase_placeholder',
  expiresAt: Timestamp | null,
  updatedAt: Timestamp
}
```

v0.1 では課金を実装しない。

使う場所。

- AI会話回数制限
- 詳細タイプ説明の表示可否
- 複数分析履歴の表示可否

受け入れ条件。

- free/plus でUI表示と制限が変わる。
- Firestoreで手動変更できる。

---

## 6. Cloud Functions API 詳細

Callable Functions または HTTPS Functions で実装する。v0.1 では Callable 推奨。

### profileCreateOrUpdate

Input.

```ts
{
  birthDate: string,
  birthTime: string | null,
  unknownBirthTime: boolean,
  birthPlaceName: string,
  birthLat: number,
  birthLng: number,
  timezone: string,
  gender?: string | null
}
```

Output.

```ts
{ ok: true }
```

---

### analysisRun

Input.

```ts
{ useMock?: boolean }
```

Output.

```ts
{
  analysisId: string,
  status: 'mock' | 'completed'
}
```

---

### archetypeCompile

Input.

```ts
{ analysisId: string }
```

Output.

```ts
{
  typeCode: string,
  typeName: string,
  ignitionScore: number,
  cognitionScore: number,
  emotionScore: number,
  socialScore: number
}
```

---

### chatStart

Input.

```ts
{ mode: 'self_understanding' | 'action_organize' | 'verification' }
```

Output.

```ts
{ sessionId: string }
```

---

### chatSendMessage

Input.

```ts
{
  sessionId: string,
  message: string
}
```

Output.

```ts
{
  assistantMessageId: string,
  content: string,
  remainingToday: number
}
```

---

### dailyLogUpsert

Input.

```ts
{
  date: string,
  moodScore: number,
  focusScore: number,
  actionScore: number,
  socialStressScore: number,
  fatigueScore: number,
  memo?: string | null,
  typeFitScore?: number | null,
  dominantTrait?: string | null
}
```

Output.

```ts
{ logId: string }
```

---

### feedbackSubmit

Input.

```ts
{
  targetType: string,
  targetId?: string | null,
  analysisId?: string | null,
  question: string,
  answer: string,
  score?: number | null,
  freeText?: string | null
}
```

Output.

```ts
{ feedbackId: string }
```

---

### labNewsList

Input.

```ts
{ limit?: number }
```

Output.

```ts
{
  items: Array<{
    newsId: string,
    title: string,
    summary: string,
    category: string,
    publishedAt: string
  }>
}
```

---

### labStats

Input.

```ts
{}
```

Output.

```ts
{
  userCount: number,
  analysisCount: number,
  dailyLogCount: number,
  feedbackCount: number
}
```

---

## 7. Firestore Security Rules 方針

基本方針。

- ユーザーは自分の `users/{userId}` のみ読める。
- ユーザーは自分の `profiles/{userId}` のみ読書きできる。
- `analyses` は自分の userId のもののみ読める。
- `archetypes/{userId}` は自分のみ読める。
- `daily_logs` は自分の userId のもののみ読書きできる。
- `chat_sessions` / `chat_messages` は自分の userId のもののみ読める。
- `lab_news` は `isPublic == true` のみ全ログインユーザーが読める。
- 書き込みは原則 Cloud Functions 経由。

v0.1 ではルールを厳しめにし、アプリ直書きを最小化する。

---

## 8. GenesisCore UI 方針

視覚方針。

- 黒 / 深紺をベース
- 白文字
- ゴールドまたは淡い青をアクセント
- 過度なスピリチュアル感を避ける
- 研究装置 / 高級分析ツール / 個人OSの印象

画面密度。

- Home は軽く
- My Core は濃く
- AI Chat は迷わせない
- Log は30秒で終わる
- Lab はニュースアプリのように読む

禁止。

- 占い感の強い星柄過多
- 安っぽいグラデーション
- 長文を初期画面に詰め込む
- タブを増やしすぎる

---

## 9. Codex 作業ルール

Codex は以下の順で作業する。

1. 既存ファイルを確認する。
2. docs を正本として扱う。
3. 1 PR / 1 Phase で進める。
4. 各Phase完了時に README または docs に実装状況を追記する。
5. 動作確認コマンドを必ず記載する。
6. 未実装部分は TODO として残す。
7. APIキーや秘密情報はコミットしない。
8. モックで進めた箇所は `MOCK:` コメントを入れる。

---

## 10. 最初のPRでやること

最初のPRは実装ではなく、土台作成でよい。

PR名。

```text
Initialize GenesisCore App architecture
```

含めるもの。

- `app/` Flutter プロジェクト作成
- Firebase 初期化の雛形
- Riverpod / go_router 導入
- 5タブの空画面
- 共通テーマ
- `functions/` TypeScript 雛形
- README に起動手順追加

完了条件。

- Flutter アプリが起動する。
- 5タブを移動できる。
- Functions が build できる。

---

## 11. v0.1 開発ロードマップ

### PR 1
Initialize App + Functions architecture

### PR 2
Auth + User document creation

### PR 3
Onboarding + Profile storage

### PR 4
Analysis mock + Analysis history

### PR 5
Archetype compiler + My Core screen

### PR 6
AI Chat mock/function pipeline

### PR 7
Daily Log

### PR 8
Feedback

### PR 9
Lab news + stats

### PR 10
Entitlements + Free/Plus gating

---

## 12. v0.1で最も重要な判断

このアプリは、機能数で勝つアプリではない。

勝ち筋は、以下の循環を最短で成立させること。

```text
分析結果
  ↓
独自タイプ
  ↓
AI会話
  ↓
日次ログ
  ↓
フィードバック
  ↓
検証データ
```

この循環に関係しないものは、v0.1 では後回しにする。
