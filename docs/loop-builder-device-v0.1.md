# GenesisCore Loop Builder Device v0.1

この文書は、GenesisCore を「設計されたアプリ」から「検証データを受けて自分を更新していく装置」へ進めるための実装正本である。

目的は、抽象的な自律AIをいきなり作ることではない。  
まず、現在の GenesisCore v0.1 が持つ以下の循環を、実装・観測・評価・改善タスク生成まで閉じる。

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
  ↓
改善候補
  ↓
実装タスク
  ↓
次バージョン
```

---

## 0. この装置の定義

Loop Builder Device は、以下を行う。

1. GenesisCore 内のユーザー行動・AI会話・日次ログ・フィードバックを収集する。
2. それらを `LoopEvent` として正規化する。
3. 評価ルールに通して、どこが壊れているか・弱いか・伸びているかを判定する。
4. 改善候補を生成する。
5. 改善候補を、実装可能な GitHub Issue / TASKS / PR 単位へ圧縮する。
6. 実装後、同じ指標で改善したかを再評価する。

この装置は、最初からコードを自動変更しない。  
最初の v0.1 では、**改善対象の発見と実装タスク化**までを自動化し、採用・実装・マージは人間が承認する。

---

## 1. 絶対方針

- 自律AIをいきなり作らない。
- まず deterministic な閉ループを作る。
- AIは「要約」「分類」「改善案の文章化」に使う。
- AIに本番データを書き換えさせない。
- 改善候補は必ず根拠イベントを持つ。
- 根拠イベントのない改善案は破棄する。
- 1回の loop run で扱う改善候補は最大3件に制限する。
- 採用単位は必ず 1 Issue = 1 改善仮説 とする。
- 未来予測・課金・SNS・複雑な研究ダッシュボードには広げない。

---

## 2. 実装圧縮の意味

「実装圧縮」とは、巨大構想を以下の形に潰すことを指す。

```text
観測できる1事象
  ↓
判定できる1指標
  ↓
変更できる1箇所
  ↓
確認できる1受け入れ条件
```

例。

```text
verification mode の回答後に feedback が保存されない
  ↓
verification_session_feedback_rate < 60%
  ↓
ChatPage 下部に 1〜5 ボタンを固定表示する
  ↓
verification mode 終了時に feedback が1件保存される
```

この形式にならないものは、Loop Builder Device に入れない。

---

## 3. 最小閉ループ v0.1

v0.1 では以下だけを通す。

```text
feedback / daily_logs / chat_sessions / chat_messages
  ↓
loopCollectSnapshot
  ↓
loopEvaluate
  ↓
improvement_candidates
  ↓
loopCompileTask
  ↓
GitHub Issue
```

PR自動生成、コード自動編集、重み自動変更は v0.1 では行わない。

---

## 4. Firestore Schema

### loop_runs

```text
loop_runs/{loopRunId}
```

```ts
type LoopRunDocument = {
  loopRunId: string;
  status: 'running' | 'completed' | 'failed';

  startedAt: Timestamp;
  completedAt: Timestamp | null;

  targetWindowStart: string; // YYYY-MM-DD
  targetWindowEnd: string;   // YYYY-MM-DD

  collectedEventCount: number;
  candidateCount: number;
  compiledTaskCount: number;

  errorMessage: string | null;
};
```

---

### loop_events

```text
loop_events/{eventId}
```

```ts
type LoopEventDocument = {
  eventId: string;
  loopRunId: string;

  userId: string | null;

  sourceType:
    | 'analysis'
    | 'archetype'
    | 'chat_session'
    | 'chat_message'
    | 'daily_log'
    | 'feedback'
    | 'usage_counter'
    | 'github_snapshot';

  sourceId: string;

  eventType:
    | 'positive_signal'
    | 'negative_signal'
    | 'missing_data'
    | 'friction'
    | 'validation'
    | 'system_error';

  targetArea:
    | 'analysis'
    | 'archetype'
    | 'chat'
    | 'log'
    | 'feedback'
    | 'lab'
    | 'entitlement'
    | 'infra';

  severity: 1 | 2 | 3 | 4 | 5;

  title: string;
  evidenceText: string;
  rawRef: string | null;

  createdAt: Timestamp;
};
```

---

### loop_metrics

```text
loop_metrics/{metricId}
```

```ts
type LoopMetricDocument = {
  metricId: string;
  loopRunId: string;

  name: string;
  targetArea: string;

  value: number;
  unit: 'count' | 'rate' | 'score' | 'seconds';

  thresholdMin: number | null;
  thresholdMax: number | null;

  status: 'good' | 'warning' | 'bad' | 'unknown';

  createdAt: Timestamp;
};
```

初期 metric。

```text
feedback_submit_rate
verification_feedback_rate
daily_log_7d_retention
chat_limit_hit_count
chat_error_count
avg_feedback_score_archetype
avg_feedback_score_ai_chat
analysis_to_archetype_success_rate
```

---

### improvement_candidates

```text
improvement_candidates/{candidateId}
```

```ts
type ImprovementCandidateDocument = {
  candidateId: string;
  loopRunId: string;

  targetArea:
    | 'analysis'
    | 'archetype'
    | 'chat'
    | 'log'
    | 'feedback'
    | 'lab'
    | 'entitlement'
    | 'infra';

  title: string;
  problem: string;
  evidenceEventIds: string[];
  currentMetricName: string | null;
  currentMetricValue: number | null;

  proposedChange: string;
  expectedEffect: string;
  risk: 'low' | 'medium' | 'high';

  implementationScope:
    | 'ui_only'
    | 'functions_only'
    | 'schema_change'
    | 'prompt_change'
    | 'docs_only'
    | 'multi_layer';

  status:
    | 'proposed'
    | 'approved'
    | 'rejected'
    | 'compiled_to_issue'
    | 'implemented'
    | 'measured';

  githubIssueUrl: string | null;

  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

---

### implementation_tasks

```text
implementation_tasks/{taskId}
```

```ts
type ImplementationTaskDocument = {
  taskId: string;
  candidateId: string;

  title: string;
  body: string;

  repo: 'takatsusora-hash/genesis-core_v1';
  githubIssueNumber: number | null;
  githubIssueUrl: string | null;

  acceptanceCriteria: string[];
  filesLikelyTouched: string[];
  verificationCommands: string[];

  status: 'draft' | 'created' | 'in_progress' | 'done' | 'rejected';

  createdAt: Timestamp;
  updatedAt: Timestamp;
};
```

---

## 5. Cloud Functions

### loopCollectSnapshot

Input.

```ts
{
  targetWindowStart: string,
  targetWindowEnd: string
}
```

Process.

1. auth admin / owner only を確認。
2. loop_runs を作成する。
3. feedback / daily_logs / chat_sessions / chat_messages / usage_counters を読む。
4. 異常・摩擦・検証シグナルを `loop_events` に正規化する。
5. collectedEventCount を更新する。

Output.

```ts
{ loopRunId: string, collectedEventCount: number }
```

---

### loopEvaluate

Input.

```ts
{ loopRunId: string }
```

Process.

1. loop_events を読む。
2. 初期 metric を計算する。
3. `loop_metrics` に保存する。
4. threshold を下回った metric から improvement_candidates を作る。
5. severity と件数で候補を並べる。
6. 上位3件だけ proposed として残す。

Output.

```ts
{ candidateCount: number }
```

---

### loopCompileTask

Input.

```ts
{ candidateId: string, createGithubIssue: boolean }
```

Process.

1. candidate を読む。
2. evidenceEventIds を展開する。
3. Issue body を生成する。
4. implementation_tasks を作る。
5. createGithubIssue が true の場合、GitHub Issue を作る。
6. candidate.status を compiled_to_issue にする。

Output.

```ts
{ taskId: string, githubIssueUrl: string | null }
```

---

## 6. GitHub Issue Template

Loop Builder Device が生成する Issue は、必ず以下の形式にする。

```md
# Problem

何が起きているか。

# Evidence

- eventId:
- sourceType:
- sourceId:
- metric:
- current value:

# Proposed Change

何を変えるか。

# Scope

- UI:
- Functions:
- Firestore:
- Prompt:
- Docs:

# Acceptance Criteria

- [ ] 条件1
- [ ] 条件2
- [ ] 条件3

# Verification Commands

```bash
cd app
flutter analyze
flutter test

cd ../functions
npm run build
npm run lint
```
```

---

## 7. 初期評価ルール

### Rule 1: verification feedback が保存されない

```text
metric: verification_feedback_rate
bad: < 0.60
warning: < 0.80
candidate: verification mode 下部に 1〜5 feedback button を固定表示する
```

---

### Rule 2: AI会話が一般論化している

```text
source: feedback.freeText / chat rating
condition: avg_feedback_score_ai_chat < 3.5
candidate: aiProfileSummary と mode prompt の注入位置を強化する
```

---

### Rule 3: 日次ログが続かない

```text
metric: daily_log_7d_retention
bad: < 0.30
candidate: LogPage を 30 秒入力に圧縮し、未入力項目を減らす
```

---

### Rule 4: Archetype の納得度が低い

```text
metric: avg_feedback_score_archetype
bad: < 3.5
candidate: borderlineAxis と confidenceScore の説明を表示し、断定感を下げる
```

---

### Rule 5: 分析から Archetype 生成に失敗する

```text
metric: analysis_to_archetype_success_rate
bad: < 0.95
candidate: analysisRun 完了時に archetypeCompile を自動実行し、失敗時 error event を保存する
```

---

## 8. Flutter UI

v0.1 では管理者用として Lab 配下に隠し画面を置く。

```text
Lab
  ↓
Loop Builder
  ↓
Loop Runs
  ↓
Candidates
  ↓
Implementation Tasks
```

表示するもの。

- 最新 loop run
- 収集イベント数
- bad / warning metrics
- improvement candidates
- GitHub Issue 作成ボタン
- rejected / approved 切り替え

---

## 9. AIの使い方

AIは以下に限定して使う。

- feedback.freeText の分類
- chat summary の要約
- improvement candidate の説明文生成
- GitHub Issue body の下書き生成

AIにやらせないこと。

- Firestore schema の自動変更
- production data の自動書き換え
- GitHub PR の自動 merge
- ユーザーへの断定的診断
- root cause の根拠なき決定

---

## 10. 実装順序

### PR 1: Loop schema + admin gate

- [ ] loop_runs schema を追加する。
- [ ] loop_events schema を追加する。
- [ ] loop_metrics schema を追加する。
- [ ] improvement_candidates schema を追加する。
- [ ] implementation_tasks schema を追加する。
- [ ] owner/admin only の guard を作る。

### PR 2: loopCollectSnapshot

- [ ] feedback を LoopEvent に変換する。
- [ ] daily_logs を LoopEvent に変換する。
- [ ] chat_sessions を LoopEvent に変換する。
- [ ] chat_messages の error / empty response を検出する。
- [ ] usage_counters の limit hit を検出する。

### PR 3: loopEvaluate

- [ ] metric calculation を実装する。
- [ ] threshold 判定を実装する。
- [ ] candidate 生成を実装する。
- [ ] 上位3件に圧縮する。

### PR 4: loopCompileTask

- [ ] candidate から implementation_task を作る。
- [ ] Issue body を生成する。
- [ ] GitHub Issue 作成は手動トリガーにする。

### PR 5: Lab Loop Builder UI

- [ ] Loop Runs 一覧を作る。
- [ ] Metrics 表示を作る。
- [ ] Candidates 表示を作る。
- [ ] approve / reject を実装する。
- [ ] GitHub Issue 作成ボタンを置く。

---

## 11. v0.1 完成条件

```text
loopCollectSnapshot を実行できる
  ↓
loop_runs が作られる
  ↓
loop_events が作られる
  ↓
loopEvaluate で loop_metrics が作られる
  ↓
improvement_candidates が最大3件作られる
  ↓
候補を承認できる
  ↓
loopCompileTask で implementation_tasks が作られる
  ↓
GitHub Issue を作れる
```

この時点で、GenesisCore は「ただ作るアプリ」ではなく、検証データから次の実装タスクを生成する装置になる。

---

## 12. v0.2 以降

v0.1 が安定した後にのみ検討する。

- Git Orbit Mobile の repo snapshot を LoopEvent に取り込む。
- GitHub Actions の失敗を loop_events に取り込む。
- PR diff を candidate と紐づける。
- 実装後 metric が改善したかを before / after 比較する。
- 安全な範囲で Codex / AI Agent に PR 作成を依頼する。
- 採用された改善と棄却された改善を学習用データにする。

---

## 13. 核心

Loop Builder Device の核は、AIではない。

```text
事実ログ
  ↓
評価ルール
  ↓
改善候補
  ↓
実装単位
  ↓
再評価
```

この5段を固定することが、GenesisCore を「おもちゃ」から「育つ装置」に変える最短経路である。
