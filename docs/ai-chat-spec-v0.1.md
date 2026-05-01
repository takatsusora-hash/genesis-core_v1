# GenesisCore AI Chat Spec v0.1

この文書は GenesisCore App v0.1 における AI会話機能の仕様正本である。

AI Chat は単なる雑談機能ではない。  
GenesisCore の分析結果、独自タイプ、日次ログ、フィードバックを接続し、ユーザーの自己理解と検証データ回収を進めるための中核機能である。

---

## 0. AI Chat の目的

v0.1 の AI Chat は以下の3目的に限定する。

1. ユーザーの自己理解を深める。
2. ユーザーの日々の行動整理を助ける。
3. GenesisCore の分析・タイプ説明に対する検証データを回収する。

未来予測は扱わない。  
本格的な占い相談にも寄せすぎない。  
会話を、日次ログ・フィードバック・タイプ検証に接続する。

---

## 1. 会話モード

v0.1 では3モード固定。

| mode | 表示名 | 目的 |
|---|---|---|
| self_understanding | 自己理解 | 自分の性質、反応、思考傾向を整理する |
| action_organize | 行動整理 | 今日やること、迷い、優先順位を整理する |
| verification | 検証 | 分析やタイプ説明が当たっているか確認する |

---

## 2. AIの基本人格

AIは GenesisCore App 内の分析補助AIとして振る舞う。

### 口調

- 日本語
- 丁寧
- 明確
- 短め
- 一般論を増やさない
- ユーザーの分析情報を前提に答える
- 抽象的な励ましより、具体的な整理を優先する

### 禁止

- 未来予測を断定する
- 医療・法律・金融判断を断定する
- 霊感商法的表現
- 恐怖訴求
- 課金誘導過多
- 長すぎる一般論
- 分析情報を読んでいないような汎用回答

---

## 3. AI入力構造

AIへ送る情報は、必ず Cloud Functions 側で組み立てる。

アプリ側にAI APIキーを置かない。

```text
System Prompt
  ↓
Mode Prompt
  ↓
User AI Profile Summary
  ↓
Latest Archetype
  ↓
Recent Daily Logs
  ↓
Recent Chat Summary
  ↓
User Message
```

---

## 4. System Prompt v0.1

Cloud Functions 内で保持する。

```text
あなたは GenesisCore App の分析補助AIです。
あなたの役割は、ユーザーの占星術分析、独自タイプ、心理傾向、日次ログをもとに、自己理解・行動整理・検証を支援することです。

未来予測は行わないでください。
医療、法律、金融などの専門判断を断定しないでください。
ユーザーの入力を一般論に薄めず、渡されたプロフィール情報と現在の質問に直接答えてください。
回答は日本語で、丁寧かつ明確にしてください。
長い講義ではなく、ユーザーが次に理解または行動できる形で返してください。
```

---

## 5. Mode Prompt

### self_understanding

```text
現在のモードは「自己理解」です。
ユーザーのGenesis Type、4軸スコア、占星術サマリー、Big Five傾向をもとに、ユーザーの性質・反応・思考傾向を整理してください。
回答では、ユーザーが自分を把握しやすいように、具体的な傾向と言語化を優先してください。
必要以上に行動計画へ寄せず、まず理解を深めてください。
```

### action_organize

```text
現在のモードは「行動整理」です。
ユーザーのGenesis Type、直近日次ログ、会話内容をもとに、今日やること、優先順位、迷い、詰まりを整理してください。
回答では、短い結論、優先順位、次に取る行動を明確にしてください。
大きな計画を広げすぎず、今の行動に落としてください。
```

### verification

```text
現在のモードは「検証」です。
ユーザーの分析結果、Genesis Type、4軸スコアについて、どの部分が当たっているか、どの部分に違和感があるかを確認してください。
回答では、ユーザーに自然な形で確認質問を返し、検証データとして保存しやすい内容へ導いてください。
```

---

## 6. User AI Profile Summary

AI会話時に毎回渡す圧縮プロフィール。

### 生成元

- analyses.aiProfileSummary
- archetypes/{userId}
- profiles/{userId}
- 直近 daily_logs
- 必要に応じて Big Five summary

### 例

```text
ユーザーのGenesis Typeは Ignis Architect。
起動力は高く、認知は構造型、感情処理は深層型、社会接続は個人主導型。
西洋占星術サマリーでは、行動力と自己主導性が強く出ている。
インド占星術サマリーでは、内的な集中と長期的な構築傾向が示されている。
Big Fiveでは開放性と誠実性が高め。
会話では、抽象的な慰めよりも、具体的な整理・戦略・短い行動分解が有効。
避けるべき応答は、曖昧な一般論、過度な留保、ユーザーの主張を薄める表現。
```

### 文字数

v0.1 では 800〜1500字以内を目安にする。

---

## 7. chat_sessions

### Path

```text
chat_sessions/{sessionId}
```

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

---

## 8. chat_messages

### Path

```text
chat_messages/{messageId}
```

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

---

## 9. Cloud Functions

AI Chat は必ず Cloud Functions 経由で実装する。

### chatStart

Input.

```ts
{
  mode: 'self_understanding' | 'action_organize' | 'verification'
}
```

Process.

1. auth uid を確認。
2. mode を検証。
3. chat_sessions を作成。
4. sessionId を返す。

Output.

```ts
{
  sessionId: string
}
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

Process.

1. auth uid を確認。
2. sessionId が本人のものか確認。
3. entitlements を読む。
4. usage_counters を確認。
5. Free/Plus の回数制限を判定。
6. user message を chat_messages に保存。
7. AI入力を組み立てる。
8. AI API に送信。
9. assistant message を保存。
10. usage_counters を increment。
11. assistant response と remainingToday を返す。

Output.

```ts
{
  assistantMessageId: string,
  content: string,
  remainingToday: number
}
```

---

### chatEnd

Input.

```ts
{
  sessionId: string,
  satisfactionScore?: number,
  usefulnessScore?: number,
  reuseIntentionScore?: number
}
```

Process.

1. auth uid を確認。
2. session の所有者確認。
3. 必要なら会話要約を作る。
4. chat_sessions を更新。

Output.

```ts
{ ok: true }
```

---

## 10. 回数制限

v0.1 の制限。

```text
free: 3 messages / day
plus: 30 messages / day
```

対象は assistant 応答を発生させる user message 数。

### usage_counters

```text
usage_counters/{userId}_{YYYY-MM-DD}
```

```ts
type UsageCounterDocument = {
  counterId: string;
  userId: string;
  date: string;
  chatMessageCount: number;
  analysisRunCount: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

---

## 11. remainingToday 計算

```ts
const limit = plan === 'plus' ? 30 : 3;
const remainingToday = Math.max(0, limit - chatMessageCountAfterIncrement);
```

制限超過時。

```ts
throw new HttpsError('resource-exhausted', 'Daily chat limit reached');
```

アプリ側表示。

```text
本日のAI会話回数に達しました。
```

Plus誘導は軽く表示する。過剰な課金圧は出さない。

---

## 12. AI Response Format

AI応答は基本プレーンテキスト。  
v0.1 ではJSON強制しない。

ただし verification mode では、最後に保存しやすい確認質問を1つ含める。

例。

```text
今の話だと、あなたは「起動力は高いが、感情処理は表に出すより内側で深める」傾向が強く出ています。

確認です。
今回の説明は、今の自分にどれくらい近いですか？
1〜5で答えてください。
```

---

## 13. Mode別UI

### AI Chat Top

表示。

```text
自己理解
行動整理
検証
```

各カードに短い説明。

### Chat Page

表示。

- mode title
- message list
- input field
- remainingToday
- end session button

---

## 14. 初期メッセージ

chatStart 後、画面側で assistant の初期文を表示してよい。  
DB保存するかは任意。

### self_understanding

```text
あなたのGenesis Typeと直近の状態をもとに、性質や反応を整理します。今いちばん知りたい自分の傾向を教えてください。
```

### action_organize

```text
今日の行動を短く整理します。今やるべきこと、迷っていること、詰まっていることをそのまま書いてください。
```

### verification

```text
分析結果やタイプ説明がどれくらい合っているか確認します。違和感がある部分、当たっている部分を教えてください。
```

---

## 15. AI入力組み立て擬似コード

```ts
async function buildChatPrompt(userId: string, sessionId: string, message: string) {
  const session = await getChatSession(sessionId);
  const profile = await getProfile(userId);
  const latestAnalysis = await getLatestAnalysis(userId);
  const archetype = await getArchetype(userId);
  const recentLogs = await getRecentDailyLogs(userId, 7);
  const recentSummary = await getRecentChatSummary(userId);

  return [
    { role: 'system', content: SYSTEM_PROMPT },
    { role: 'system', content: getModePrompt(session.mode) },
    { role: 'system', content: buildAiProfileSummary(profile, latestAnalysis, archetype, recentLogs) },
    { role: 'system', content: recentSummary ?? '直近の会話要約はありません。' },
    { role: 'user', content: message },
  ];
}
```

---

## 16. aiProfileSummary生成

### 入力

```ts
profile
latestAnalysis
archetype
recentDailyLogs
```

### 出力

800〜1500字程度の日本語テキスト。

### 方針

- typeName
- 4軸ラベル
- 4軸スコア
- 西洋サマリー
- インドサマリー
- Big Fiveサマリー
- 直近日次ログ傾向
- 会話上の注意

---

## 17. 会話要約

v0.1 では chatEnd 時に summary を生成する。

### summary 内容

```text
ユーザーが話した主題
AIが返した主な整理
次回引き継ぐべき点
検証に使えそうな発言
```

AI要約が未実装の場合は、手動で簡易要約してよい。

```text
summary: 'MOCK: summary generation pending'
```

---

## 18. Feedback 連携

AI会話終了時、以下の評価を取る。

```text
この会話は役に立ちましたか？ 1〜5
自分に合っていると感じましたか？ 1〜5
また使いたいですか？ 1〜5
```

保存先。

- chat_sessions.satisfactionScore
- chat_sessions.usefulnessScore
- chat_sessions.reuseIntentionScore
- feedback collectionにも保存してよい

---

## 19. Verification Mode の追加処理

verification mode では、ユーザーの回答から feedback を作成できるようにする。

例。

ユーザーが「4」と答えた場合。

```ts
feedbackSubmit({
  targetType: 'archetype',
  targetId: archetype.typeCode,
  question: 'このタイプ説明は今の自分に近いですか？',
  answer: '4',
  score: 4
})
```

v0.1 では自動抽出が難しければ、会話画面下に明示的な1〜5ボタンを出す。

---

## 20. Error Handling

### AI API失敗

アプリ表示。

```text
AI応答の生成に失敗しました。少し時間を置いて再度お試しください。
```

保存。

- user message は保存済みでよい。
- assistant message は作らない。
- usage count は assistant 応答成功時のみ increment 推奨。

### session不正

```ts
HttpsError('permission-denied', 'Invalid session owner')
```

### limit超過

```ts
HttpsError('resource-exhausted', 'Daily chat limit reached')
```

---

## 21. Privacy 方針 v0.1

- AI APIキーはアプリに置かない。
- Cloud Functionsで必要情報だけAIへ送る。
- `chat_messages` は userId 紐づけ。
- ユーザーは自分の会話だけ読める。
- 将来のデータ削除に備え、userIdで関連データを辿れる設計にする。

---

## 22. Mock 実装

AI API接続前でもアプリを進めるため、mock応答を必ず用意する。

### Mock response

```ts
function mockAiReply(mode, userMessage, archetype) {
  return `MOCK: ${archetype.typeName} の情報をもとに、${mode} として応答します。入力: ${userMessage}`;
}
```

環境変数。

```text
USE_MOCK_AI=true
```

---

## 23. Environment Variables

Functions で使う想定。

```text
USE_MOCK_AI=true
AI_PROVIDER=openai_or_google_or_anthropic
AI_API_KEY=secret
AI_MODEL=model_name
```

秘密情報はGitHubにコミットしない。

---

## 24. 受け入れ条件

```text
3モードから会話を開始できる
chat_sessions が作成される
user message が保存される
assistant message が保存される
Free は1日3回で止まる
Plus は1日30回まで使える
remainingToday がUIに出る
AIが archetype と recent logs を参照した応答を返す
verification mode から feedback を保存できる
chatEnd で評価スコアを保存できる
```

---

## 25. 実装順序

1. chat_sessions / chat_messages schema 実装
2. chatStart Function
3. chatSendMessage Function mock版
4. Flutter Chat UI
5. usage_counters 制限
6. aiProfileSummary 組み立て
7. real AI API 接続
8. chatEnd + 評価保存
9. verification feedback 連携

---

## 26. v0.1 でやらないこと

- 長期記憶ベクトルDB
- 自動人格進化
- 未来予測
- 音声会話
- アバター表示
- 画像生成
- 複雑な安全審査UI
- 多言語対応

この文書では、GenesisCore App v0.1 のAI会話を、自己理解・行動整理・検証回収に限定して完成させる。
