# GenesisCore App IMPLEMENTATION PLAN

この文書は GenesisCore App v0.1 を実装開始するための実行計画である。

`TASKS.md` が作業台帳、`docs/` が仕様正本、本書が実装進行の運用計画である。

---

## 0. 現在地

現時点のリポジトリは、設計・仕様・実装指示の準備段階にある。

作成済みの正本。

```text
README.md
TASKS.md
IMPLEMENTATION_PLAN.md
docs/genesiscore-app-design-v0.1.md
docs/codex-implementation-instructions-v0.1.md
docs/firestore-schema-v0.1.md
docs/archetype-engine-spec-v0.1.md
docs/ai-chat-spec-v0.1.md
```

次の段階は、PR 1 から実装へ入ること。

---

## 1. v0.1 の開発思想

GenesisCore App v0.1 は、占いアプリではない。

目的は、以下の循環を最短で成立させること。

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

この循環に関係しない機能は、v0.1では実装しない。

---

## 2. 実装対象

v0.1 で実装する。

```text
Flutter iOS/Android App
Firebase Auth
Cloud Firestore
Firebase Cloud Functions
Genesis Type / Archetype Engine
AI Chat 3 Modes
Daily Log
Feedback
Lab News
Free/Plus権限フラグ
```

v0.1 で実装しない。

```text
未来予測
本格SaaS課金
SNS
コミュニティ
ライブ占い師相談
音声会話
アバター
多言語対応
高度研究ダッシュボード
```

---

## 3. ブランチ運用

### 基本

- `main` は常に正本。
- 作業は phase ごとにブランチを切る。
- 1 PR = 1 Phase。
- PR本文に実装内容、動作確認、未実装TODOを書く。

### ブランチ名

```text
phase-01-init-architecture
phase-02-auth-users
phase-03-onboarding-profile
phase-04-analysis-mock
phase-05-archetype-mycore
phase-06-ai-chat-mock
phase-07-ai-chat-real
phase-08-daily-log
phase-09-feedback
phase-10-lab-news
phase-11-entitlements
phase-12-rules-validation
```

---

## 4. PRテンプレート

各PRは以下の形式で説明を書く。

```md
## Summary
- 

## Implemented
- 

## Verification
- [ ] flutter analyze
- [ ] flutter test
- [ ] flutter run
- [ ] npm run build
- [ ] npm run lint

## Firestore touched
- 

## Mock / TODO
- 

## Screens / Notes
- 
```

---

## 5. 開発フェーズ一覧

## Phase 1: Initialize Architecture

### Goal

Flutter / Functions の土台を作る。

### Output

```text
app/
functions/
5 tab shell
common theme
common widgets
README boot instructions
```

### Done

- Flutterが起動する。
- 5タブを移動できる。
- Functionsがbuildできる。

---

## Phase 2: Auth + Users

### Goal

ログインとユーザー作成。

### Output

```text
AuthGate
LoginPage
users/{userId}
entitlements/{userId}
```

### Done

- ログインできる。
- usersが作られる。
- free entitlementが作られる。

---

## Phase 3: Onboarding + Profile

### Goal

出生情報登録。

### Output

```text
OnboardingPage
ProfileEditPage
profiles/{userId}
```

### Done

- 出生情報保存。
- 未登録ユーザーはOnboardingへ。
- 登録済みユーザーはHomeへ。

---

## Phase 4: Analysis Mock

### Goal

分析結果保存の流れをmockで完成させる。

### Output

```text
analysisRun function
analyses/{analysisId}
AnalysisLatestCard
AnalysisHistoryPage
AnalysisDetailPage
```

### Done

- mock分析が保存される。
- 最新分析を表示できる。
- 履歴を表示できる。

---

## Phase 5: Archetype + My Core

### Goal

Genesis Typeを生成し、My Coreに表示する。

### Output

```text
archetypeCompiler.ts
TYPE_DEFINITIONS
archetypeCompile function
archetypes/{userId}
My Core screen
```

### Done

- typeCodeが出る。
- typeNameが出る。
- 4軸スコアが出る。
- My Coreに表示される。

---

## Phase 6: AI Chat Mock

### Goal

AI会話のUI・DB・回数制限をmockで完成させる。

### Output

```text
AI Chat top
ChatPage
chatStart
chatSendMessage mock
chat_sessions
chat_messages
usage_counters
```

### Done

- 3モードで会話開始。
- メッセージ保存。
- Free/Plus制限。

---

## Phase 7: Real AI Connection

### Goal

Cloud Functions経由で実AIへ接続する。

### Output

```text
aiChatService.ts
System Prompt
Mode Prompt
aiProfileSummary builder
USE_MOCK_AI switching
```

### Done

- mock/realを切り替えられる。
- AI応答がtype情報を参照する。
- APIキーが漏れない。

---

## Phase 8: Daily Log

### Goal

日次ログを保存し、過去7日を表示する。

### Output

```text
LogPage
daily_logs/{userId}_{date}
RecentLogList
```

### Done

- 当日ログ保存。
- 同日更新。
- 過去7日表示。

---

## Phase 9: Feedback

### Goal

検証フィードバックを保存する。

### Output

```text
feedbackSubmit
feedback/{feedbackId}
Home feedback card
Chat end rating
Archetype rating
```

### Done

- feedback保存。
- AI会話評価保存。
- Archetype評価保存。

---

## Phase 10: Lab News + Stats

### Goal

Labニュースと簡易統計を表示する。

### Output

```text
LabPage
LabNewsList
LabNewsDetailPage
labNewsList
labStats
```

### Done

- 公開ニュースだけ表示。
- 詳細閲覧。
- 統計カード表示。

---

## Phase 11: Entitlements

### Goal

Free/Plus差をUIと制限に反映する。

### Output

```text
EntitlementProvider
Free/Plus UI
Plus gated widgets
```

### Done

- Firestoreのplan変更でUIが変わる。
- 回数制限が変わる。
- 課金処理は未実装。

---

## Phase 12: Rules + MVP Validation

### Goal

Firestore Rules、Storage Rules、最終フロー確認。

### Output

```text
firestore.rules
storage.rules
README final setup
MVP checklist
```

### Done

- 自分のデータだけ読める。
- Lab公開記事だけ読める。
- Entitlements直接書き込み禁止。
- 新規ユーザーフローが通る。

---

## 6. 最初にCodexへ渡す指示

Codexへ最初に投げる指示は以下。

```text
Repository: takatsusora-hash/genesis-core_v1

Read these files first:
- README.md
- TASKS.md
- IMPLEMENTATION_PLAN.md
- docs/genesiscore-app-design-v0.1.md
- docs/codex-implementation-instructions-v0.1.md
- docs/firestore-schema-v0.1.md
- docs/archetype-engine-spec-v0.1.md
- docs/ai-chat-spec-v0.1.md

Start with PR 1 only:
Initialize GenesisCore App architecture.

Do not implement future prediction, paid subscription processing, SNS, community, avatar, voice, or multilingual support.

Create:
- app/ Flutter project
- functions/ Firebase Functions TypeScript project
- Riverpod and go_router setup
- Firebase bootstrap placeholder
- 5 bottom tabs: Home, My Core, AI Chat, Log, Lab
- dark GenesisCore theme
- common widgets
- README setup instructions

After implementation, report:
- files changed
- commands run
- what works
- what is mock/TODO
```

---

## 7. 実装時の品質基準

### UI

- 画面は軽く、黒/深紺ベース。
- Homeは情報を詰め込まない。
- My Coreだけ濃くする。
- Logは30秒で終わる。
- Chatは3モードを迷わせない。

### Data

- userId を必ず保存する。
- Timestamp は serverTimestamp。
- 欠損を許容する。
- mockは明示する。

### Functions

- auth.uid を必ず確認する。
- 他人のsession/profile/analysisに触らせない。
- AI APIキーをアプリに置かない。
- usage counter はFunctions側で更新する。

### Docs

- 仕様変更したらdocsも更新する。
- 未実装はTODOで残す。
- PRごとにREADMEか実装メモを更新する。

---

## 8. 環境変数方針

ローカル `.env` や Firebase Functions config / secrets を使う。

GitHubに入れてはいけない。

```text
AI_API_KEY
AI_PROVIDER
AI_MODEL
USE_MOCK_AI
FIREBASE_PROJECT_ID
```

`.env.example` は置いてよい。

```text
USE_MOCK_AI=true
AI_PROVIDER=mock
AI_MODEL=mock
```

---

## 9. モック方針

v0.1 初期は mock を積極的に使う。

許可するmock。

```text
Analysis mock
Archetype mockCompiler
AI mock response
Lab seed news
Plus manual entitlement
```

禁止するmock。

```text
Authが動いているふり
Firestore保存しているふり
回数制限が動いているふり
```

つまり、外部APIはmockでよい。  
アプリ内フローとDB保存は本物で作る。

---

## 10. MVP Validation Scenario

最後に以下のシナリオで確認する。

```text
1. 新規ユーザーでログイン
2. users と entitlements が作成される
3. 出生情報を保存
4. profiles が作成される
5. mock分析を実行
6. analyses が作成される
7. archetypeCompile を実行
8. archetypes が作成される
9. My Core にGenesis Typeが出る
10. AI Chat 自己理解モードで1回会話
11. chat_sessions / chat_messages / usage_counters が作成される
12. 日次ログを保存
13. daily_logs が作成される
14. Archetypeフィードバックを送信
15. feedback が作成される
16. Labニュースを閲覧
17. labStatsが表示される
18. Freeで4回目のAI会話が止まる
19. entitlementsをplusに変更
20. AI会話上限が30回になる
```

この20ステップが通れば、v0.1 MVPは成立する。

---

## 11. 優先順位

開発で迷ったら、以下の順で優先する。

1. ユーザーフローが通ること
2. Firestoreに正しく保存されること
3. 独自タイプが表示されること
4. AI会話が保存されること
5. 日次ログとフィードバックが検証データになること
6. UIの美しさ
7. 外部APIの本接続

美しさより、まず循環を通す。

---

## 12. 完成時に残してよいTODO

v0.1 完成時点で残してよい。

```text
GenesisCore既存APIとの本接続
本格課金
RevenueCat導入
PDF閲覧の完成
Lab管理画面
AI会話要約の高精度化
高度なSecurity Rulesテスト
Google Places連携
Apple Sign-In本番設定
Push通知本番運用
```

---

## 13. 完成時に残してはいけないTODO

v0.1 完成時点で残してはいけない。

```text
ログインできない
プロフィール保存できない
分析保存できない
Genesis Typeが出ない
AI Chatが保存されない
日次ログが保存されない
フィードバックが保存されない
Labニュースが読めない
Free/Plus判定が動かない
APIキーが露出している
```

---

## 14. 実装開始判定

以下が揃っているため、PR 1 に進んでよい。

- プロダクト設計
- 実装施工指示
- Firestore Schema
- Archetype Engine Spec
- AI Chat Spec
- TASKS
- IMPLEMENTATION PLAN

次の作業は `phase-01-init-architecture` ブランチ作成である。
