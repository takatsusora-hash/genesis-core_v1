# GenesisCore App Firestore Schema v0.1

この文書は GenesisCore App v0.1 の Firestore データ設計正本である。

`docs/genesiscore-app-design-v0.1.md` と `docs/codex-implementation-instructions-v0.1.md` を上位方針とし、本書では Firestore のコレクション、フィールド、保存責務、アクセス方針を固定する。

---

## 0. 基本方針

v0.1 の Firestore は、以下の循環を支えるために設計する。

```text
ユーザー
  ↓
出生情報
  ↓
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

未来予測、SNS、ライブ相談、本格課金、重い研究ダッシュボードは v0.1 のスキーマに入れない。

---

## 1. 命名規則

### Collection

- 複数形の snake_case を使う。
- 例: `daily_logs`, `chat_sessions`, `lab_news`

### Document ID

- `users/{userId}` のように、ユーザーごとに1件のものは `userId` を document id にする。
- 複数作成されるものは UUID を使う。
- 日次ログは重複防止のため、`{userId}_{date}` 形式を推奨する。

例。

```text
users/{userId}
profiles/{userId}
archetypes/{userId}
entitlements/{userId}
daily_logs/{userId}_2026-05-01
```

### Timestamp

- 作成日時: `createdAt`
- 更新日時: `updatedAt`
- 公開日時: `publishedAt`
- Firebase Admin SDK の serverTimestamp を使う。

### 削除

v0.1 では原則 soft delete を使う。

```ts
isDeleted: boolean
```

---

## 2. users

### Path

```text
users/{userId}
```

### 目的

Firebase Auth のユーザーに対応するアプリ上の基本ユーザー情報。

### 作成タイミング

初回ログイン時。

### 更新タイミング

ログイン時、プロフィール変更時、同意更新時、退会処理時。

### Schema

```ts
type UserDocument = {
  userId: string;
  email: string | null;
  displayName: string | null;
  photoUrl: string | null;

  providerIds: string[];

  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastLoginAt: Timestamp;

  consentVersion: string | null;
  consentedAt: Timestamp | null;

  isDeleted: boolean;
  deletedAt: Timestamp | null;
};
```

### 必須

- userId
- createdAt
- updatedAt
- lastLoginAt
- isDeleted

### 備考

`email` は Appleログイン等で null になる可能性を許容する。

---

## 3. profiles

### Path

```text
profiles/{userId}
```

### 目的

出生情報と分析に必要な入力情報を保持する。

### 作成タイミング

オンボーディング完了時。

### 更新タイミング

プロフィール編集時。

### Schema

```ts
type ProfileDocument = {
  userId: string;

  birthDate: string;          // YYYY-MM-DD
  birthTime: string | null;   // HH:mm
  unknownBirthTime: boolean;

  birthPlaceName: string;
  birthLat: number;
  birthLng: number;
  timezone: string;           // Asia/Tokyo など

  gender: string | null;

  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

### 必須

- userId
- birthDate
- unknownBirthTime
- birthPlaceName
- birthLat
- birthLng
- timezone

### Validation

```text
birthDate: YYYY-MM-DD
birthTime: HH:mm または null
birthLat: -90〜90
birthLng: -180〜180
unknownBirthTime == true の場合 birthTime は null を許容
```

---

## 4. analyses

### Path

```text
analyses/{analysisId}
```

### 目的

GenesisCore の分析結果をアプリ内に保存する。

### 作成タイミング

分析実行時。

### 更新タイミング

分析完了時、PDF生成完了時、AI用サマリー生成時。

### Schema

```ts
type AnalysisDocument = {
  analysisId: string;
  userId: string;

  status: 'mock' | 'running' | 'completed' | 'failed';

  createdAt: Timestamp;
  updatedAt: Timestamp;
  completedAt: Timestamp | null;

  westernSummary: string;
  jyotishSummary: string;
  bigFiveSummary: string | null;

  pdfUrl: string | null;
  rawResultRef: string | null;

  aiProfileSummary: string;

  source: 'web_import' | 'app_generated' | 'mock';

  errorMessage: string | null;
};
```

### Index候補

```text
analyses: userId ASC, createdAt DESC
analyses: userId ASC, status ASC, createdAt DESC
```

### 備考

v0.1 では既存 GenesisCore API 接続が未完成でも `source: mock` で保存してよい。

---

## 5. archetypes

### Path

```text
archetypes/{userId}
```

### 目的

ユーザーの最新 Genesis Type を保持する。

### 作成タイミング

分析完了後、または mock分析作成後。

### 更新タイミング

再分析、タイプ再計算、フィードバック反映時。

### Schema

```ts
type ArchetypeDocument = {
  userId: string;
  analysisId: string;

  typeCode: string;           // 例: INRP
  typeName: string;           // 例: Ignis Navigator
  typeDescription: string;

  axisLabels: {
    ignition: 'ignition' | 'storage';
    cognition: 'intuitive' | 'logical';
    emotion: 'reactive' | 'deep';
    social: 'personal' | 'connective';
  };

  ignitionScore: number;      // 0-100
  cognitionScore: number;     // 0-100
  emotionScore: number;       // 0-100
  socialScore: number;        // 0-100

  confidenceScore: number;    // 0-100

  detailScores: {
    fireScore: number | null;
    earthScore: number | null;
    airScore: number | null;
    waterScore: number | null;
    cardinalScore: number | null;
    fixedScore: number | null;
    mutableScore: number | null;
    sunStrength: number | null;
    moonStrength: number | null;
    marsStrength: number | null;
    mercuryStrength: number | null;
    venusStrength: number | null;
    jupiterStrength: number | null;
    saturnStrength: number | null;
  };

  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

### 備考

最新表示用は `archetypes/{userId}`。  
履歴が必要になった段階で `archetype_history/{historyId}` を追加する。

---

## 6. daily_logs

### Path

```text
daily_logs/{logId}
```

推奨 document id。

```text
{userId}_{YYYY-MM-DD}
```

### 目的

日々の状態、行動、タイプ一致度を軽量に回収する。

### 作成タイミング

ユーザーが今日の記録を保存した時。

### 更新タイミング

同日再入力時。

### Schema

```ts
type DailyLogDocument = {
  logId: string;
  userId: string;
  date: string; // YYYY-MM-DD

  moodScore: number;          // 1-5
  focusScore: number;         // 1-5
  actionScore: number;        // 1-5
  socialStressScore: number;  // 1-5
  fatigueScore: number;       // 1-5

  memo: string | null;

  typeFitScore: number | null;    // 1-5
  dominantTrait: string | null;   // ignition/cognition/emotion/social/none

  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

### Index候補

```text
daily_logs: userId ASC, date DESC
```

### Validation

各スコアは 1〜5 の整数。

---

## 7. feedback

### Path

```text
feedback/{feedbackId}
```

### 目的

分析、タイプ、AI会話、日次ログ、Labニュースに対する明示的評価を保存する。

### 作成タイミング

ユーザーがフィードバックに回答した時。

### Schema

```ts
type FeedbackDocument = {
  feedbackId: string;
  userId: string;

  analysisId: string | null;

  targetType: 'analysis' | 'archetype' | 'chat' | 'daily_log' | 'lab_news';
  targetId: string | null;

  question: string;
  answer: string;
  score: number | null;       // 1-5 or null
  freeText: string | null;

  createdAt: Timestamp;
};
```

### Index候補

```text
feedback: userId ASC, createdAt DESC
feedback: targetType ASC, createdAt DESC
feedback: analysisId ASC, createdAt DESC
```

---

## 8. feedback_prompts

### Path

```text
feedback_prompts/{promptId}
```

### 目的

Home に出す未回答フィードバック設問を管理する。

### Schema

```ts
type FeedbackPromptDocument = {
  promptId: string;
  targetType: 'analysis' | 'archetype' | 'chat' | 'daily_log' | 'lab_news';
  question: string;
  answerType: 'score_1_5' | 'choice' | 'text';
  choices: string[] | null;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

### 備考

v0.1 では固定設問をFunctions側に持ってもよい。  
管理画面を作る段階でこのコレクションを使う。

---

## 9. chat_sessions

### Path

```text
chat_sessions/{sessionId}
```

### 目的

AI会話のセッション単位情報。

### Schema

```ts
type ChatSessionDocument = {
  sessionId: string;
  userId: string;

  mode: 'self_understanding' | 'action_organize' | 'verification';

  startedAt: Timestamp;
  endedAt: Timestamp | null;

  summary: string | null;

  satisfactionScore: number | null;
  usefulnessScore: number | null;
  reuseIntentionScore: number | null;
};
```

### Index候補

```text
chat_sessions: userId ASC, startedAt DESC
chat_sessions: userId ASC, mode ASC, startedAt DESC
```

---

## 10. chat_messages

### Path

```text
chat_messages/{messageId}
```

### 目的

AI会話メッセージ本文を保存する。

### Schema

```ts
type ChatMessageDocument = {
  messageId: string;
  sessionId: string;
  userId: string;

  role: 'user' | 'assistant' | 'system';
  content: string;

  createdAt: Timestamp;
};
```

### Index候補

```text
chat_messages: sessionId ASC, createdAt ASC
chat_messages: userId ASC, createdAt DESC
```

### 備考

v0.1 では全文保存。  
将来、会話要約・ベクトルDB等を追加する場合も、この schema を壊さない。

---

## 11. usage_counters

### Path

```text
usage_counters/{userId}_{date}
```

### 目的

Free / Plus の日次利用回数制限を管理する。

### Schema

```ts
type UsageCounterDocument = {
  counterId: string; // {userId}_{YYYY-MM-DD}
  userId: string;
  date: string;

  chatMessageCount: number;
  analysisRunCount: number;

  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

### 制限

```text
free.chatMessageCount <= 3 / day
plus.chatMessageCount <= 30 / day
```

---

## 12. lab_news

### Path

```text
lab_news/{newsId}
```

### 目的

検証ニュース、研究メモ、更新情報を配信する。

### Schema

```ts
type LabNewsDocument = {
  newsId: string;

  title: string;
  summary: string;
  body: string;

  category: 'research' | 'update' | 'notice';

  publishedAt: Timestamp;
  createdAt: Timestamp;
  updatedAt: Timestamp;

  isPublic: boolean;
};
```

### Index候補

```text
lab_news: isPublic ASC, publishedAt DESC
lab_news: category ASC, isPublic ASC, publishedAt DESC
```

---

## 13. entitlements

### Path

```text
entitlements/{userId}
```

### 目的

Free / Plus の権限状態を保持する。

### Schema

```ts
type EntitlementDocument = {
  userId: string;

  plan: 'free' | 'plus';
  source: 'manual' | 'test' | 'purchase_placeholder';

  expiresAt: Timestamp | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

### 備考

v0.1 では課金処理を行わない。  
Firestore Console から手動で `plus` 付与できればよい。

---

## 14. app_config

### Path

```text
app_config/{configId}
```

推奨 document id。

```text
app_config/global
```

### 目的

アプリ全体の軽い設定を持つ。

### Schema

```ts
type AppConfigDocument = {
  minSupportedVersion: string;
  latestVersion: string;
  maintenanceMode: boolean;
  maintenanceMessage: string | null;
  updatedAt: Timestamp;
};
```

---

## 15. Security Rules 方針

### 基本

- ログイン必須。
- ユーザーは自分のデータのみ読める。
- 重要書き込みは Cloud Functions 経由を優先。
- `lab_news` の公開記事のみ全ログインユーザーが読める。
- `entitlements` はユーザー本人が読めるが、直接書き込みは禁止。

### 擬似ルール

```js
function isSignedIn() {
  return request.auth != null;
}

function isOwner(userId) {
  return isSignedIn() && request.auth.uid == userId;
}
```

### 読み書き方針

| Collection | Read | Write |
|---|---|---|
| users | owner | owner or functions |
| profiles | owner | owner or functions |
| analyses | owner by userId | functions |
| archetypes | owner | functions |
| daily_logs | owner by userId | owner or functions |
| feedback | owner by userId | owner or functions |
| chat_sessions | owner by userId | functions |
| chat_messages | owner by userId | functions |
| usage_counters | owner by userId | functions |
| lab_news | signed-in public only | admin/functions |
| entitlements | owner | admin/functions |
| app_config | signed-in | admin/functions |

---

## 16. 初期Seedデータ

v0.1 開発時、以下を手動投入してよい。

### lab_news sample

```json
{
  "title": "GenesisCore Lab を開始しました",
  "summary": "分析結果と日次ログをもとに、独自タイプの検証を始めます。",
  "body": "GenesisCore App v0.1 では、ユーザーの分析結果、日次ログ、フィードバックをもとに、独自タイプの納得度と傾向を検証します。",
  "category": "notice",
  "isPublic": true
}
```

### entitlements sample

```json
{
  "plan": "free",
  "source": "manual",
  "expiresAt": null
}
```

---

## 17. 実装優先度

最初に必ず作る。

1. users
2. profiles
3. analyses
4. archetypes
5. chat_sessions
6. chat_messages
7. daily_logs
8. feedback
9. lab_news
10. entitlements
11. usage_counters

`feedback_prompts` と `app_config` は後続でもよい。

---

## 18. v0.1 のスキーマ完成条件

以下が確認できれば v0.1 schema 完成。

```text
ログインで users が作成される
プロフィール保存で profiles が作成される
分析実行で analyses が作成される
タイプ生成で archetypes が作成される
AI会話で chat_sessions / chat_messages が作成される
日次記録で daily_logs が作成/更新される
フィードバックで feedback が作成される
Lab画面で lab_news が読める
Free/Plus判定で entitlements が読める
AI回数制限で usage_counters が更新される
```
