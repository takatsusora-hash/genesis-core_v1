# GenesisCore App TASKS

このファイルは GenesisCore App v0.1 実装の作業台帳である。

Codex / AI Agent は、このファイルを実装順序の正本として扱う。  
詳細仕様は `docs/` 配下の各文書を参照する。

---

## 0. 参照する正本文書

実装時は必ず以下を読む。

```text
docs/genesiscore-app-design-v0.1.md
docs/codex-implementation-instructions-v0.1.md
docs/firestore-schema-v0.1.md
docs/archetype-engine-spec-v0.1.md
docs/ai-chat-spec-v0.1.md
```

---

## 1. v0.1 の完成定義

GenesisCore App v0.1 は、以下の流れが通れば完成とする。

```text
ユーザーがログインする
  ↓
出生情報を登録する
  ↓
分析結果が作成/保存される
  ↓
Genesis Type が表示される
  ↓
AI Chat で3モードを使える
  ↓
日次ログを保存できる
  ↓
検証フィードバックを送れる
  ↓
Labニュースを読める
  ↓
Free/Plus の権限差が動く
```

v0.1 では未来予測、本格SaaS課金、SNS、ライブ相談、多言語化、音声会話、アバターは実装しない。

---

## 2. PR単位の実装タスク

原則として、1 PR = 1 Phase で進める。

---

# PR 1: Initialize App + Functions Architecture

## 目的

FlutterアプリとFirebase Functionsの最小構成を作り、以後の開発土台を固定する。

## 作業

- [ ] `app/` に Flutter プロジェクトを作成する。
- [ ] `functions/` に TypeScript Firebase Functions プロジェクトを作成する。
- [ ] Flutter に Riverpod を導入する。
- [ ] Flutter に go_router を導入する。
- [ ] Firebase 初期化の雛形を作る。
- [ ] 5タブ構成を作る。
  - Home
  - My Core
  - AI Chat
  - Log
  - Lab
- [ ] 共通テーマを作る。
  - 黒/深紺ベース
  - 白文字
  - ゴールドまたは淡い青アクセント
- [ ] 共通Widgetを作る。
  - PrimaryButton
  - LoadingView
  - ErrorView
  - AppScaffold
- [ ] README に起動手順を追記する。

## 主要ファイル

```text
app/lib/main.dart
app/lib/app/app.dart
app/lib/app/router.dart
app/lib/app/theme.dart
app/lib/core/firebase/firebase_bootstrap.dart
app/lib/shared/widgets/app_scaffold.dart
app/lib/shared/widgets/primary_button.dart
app/lib/shared/widgets/loading_view.dart
app/lib/shared/widgets/error_view.dart
functions/src/index.ts
```

## 完了条件

- [ ] `flutter run` でアプリが起動する。
- [ ] 5タブを移動できる。
- [ ] `npm run build` または `npm run lint` が functions で通る。
- [ ] APIキーや秘密情報がコミットされていない。

---

# PR 2: Auth + User Document Creation

## 目的

Firebase Auth と `users/{userId}` の作成を実装する。

## 作業

- [ ] AuthGate を作る。
- [ ] LoginPage を作る。
- [ ] メールログインを実装する。
- [ ] Googleログインを実装する。
- [ ] Appleログイン枠を準備する。
- [ ] ログアウトを実装する。
- [ ] 初回ログイン時に `users/{userId}` を作成する。
- [ ] 再ログイン時に `lastLoginAt` を更新する。
- [ ] `entitlements/{userId}` を未作成なら `free` で作成する。

## Firestore

```text
users/{userId}
entitlements/{userId}
```

## 完了条件

- [ ] ログインできる。
- [ ] ログアウトできる。
- [ ] 初回ログインで `users/{userId}` が作成される。
- [ ] `entitlements/{userId}.plan = free` が作成される。

---

# PR 3: Onboarding + Profile Storage

## 目的

出生情報登録と `profiles/{userId}` の保存を実装する。

## 作業

- [ ] OnboardingPage を作る。
- [ ] ProfileEditPage を作る。
- [ ] birthDate を入力できる。
- [ ] birthTime を入力できる。
- [ ] 出生時刻不明フラグを保存できる。
- [ ] birthPlaceName / birthLat / birthLng / timezone を保存できる。
- [ ] プロフィール未登録なら Onboarding へ送る。
- [ ] プロフィール登録済みなら Home へ送る。

## Firestore

```text
profiles/{userId}
```

## 完了条件

- [ ] プロフィールを新規保存できる。
- [ ] プロフィールを編集できる。
- [ ] 出生時刻不明でも保存できる。
- [ ] 保存後に Home へ遷移する。

---

# PR 4: Analysis Mock + Analysis History

## 目的

既存GenesisCore分析API未接続でも、分析結果保存と履歴表示を成立させる。

## 作業

- [ ] `analysisRun` Function を作る。
- [ ] mock分析結果を生成する。
- [ ] `analyses/{analysisId}` に保存する。
- [ ] AnalysisLatestCard を作る。
- [ ] AnalysisHistoryPage を作る。
- [ ] AnalysisDetailPage を作る。
- [ ] 分析がない場合の作成導線を作る。

## Firestore

```text
analyses/{analysisId}
```

## 完了条件

- [ ] mock分析を作成できる。
- [ ] 最新分析をHomeまたはMy Coreで取得できる。
- [ ] 分析履歴を表示できる。
- [ ] 分析詳細を表示できる。

---

# PR 5: Archetype Compiler + My Core

## 目的

独自タイプ判定エンジンと My Core 画面を実装する。

## 参照

```text
docs/archetype-engine-spec-v0.1.md
```

## 作業

- [ ] `TYPE_DEFINITIONS` を作る。
- [ ] `mockCompiler` を作る。
- [ ] `buildTypeCode(scores)` を作る。
- [ ] `calculateConfidence(scores)` を作る。
- [ ] `compileArchetype(input)` を作る。
- [ ] `archetypeCompile` Function を作る。
- [ ] `archetypes/{userId}` に保存する。
- [ ] My Core 画面を作る。
- [ ] Genesis Type 名を表示する。
- [ ] 4軸スコアを表示する。
- [ ] confidenceScore を表示する。
- [ ] dominantAxis / borderlineAxis をUI表示する。

## Firestore

```text
archetypes/{userId}
```

## 完了条件

- [ ] mock分析からタイプ生成できる。
- [ ] typeCode が4文字で生成される。
- [ ] My Core に typeName / description / 4軸が表示される。
- [ ] `archetypes/{userId}` が保存される。

---

# PR 6: AI Chat Mock Pipeline

## 目的

AI API実接続前に、会話画面、セッション、メッセージ保存、回数制限の流れを作る。

## 参照

```text
docs/ai-chat-spec-v0.1.md
```

## 作業

- [ ] AI Chat Top を作る。
- [ ] 3モード選択を作る。
  - self_understanding
  - action_organize
  - verification
- [ ] ChatPage を作る。
- [ ] `chatStart` Function を作る。
- [ ] `chatSendMessage` Function を mock応答で作る。
- [ ] `chat_sessions/{sessionId}` を保存する。
- [ ] `chat_messages/{messageId}` を保存する。
- [ ] `usage_counters/{userId}_{date}` を更新する。
- [ ] Free 1日3回制限を実装する。
- [ ] Plus 1日30回制限を実装する。
- [ ] remainingToday をUIに表示する。

## Firestore

```text
chat_sessions/{sessionId}
chat_messages/{messageId}
usage_counters/{userId}_{date}
```

## 完了条件

- [ ] 3モードから会話を開始できる。
- [ ] user/assistant のメッセージが保存される。
- [ ] Free で4回目が止まる。
- [ ] Plus で30回まで使える。
- [ ] mock応答に Genesis Type 情報が含まれる。

---

# PR 7: Real AI Connection + aiProfileSummary

## 目的

Cloud Functions 経由でAI APIへ接続し、GenesisCoreの分析情報を反映した応答を出す。

## 作業

- [ ] AI関連の環境変数を設定する。
- [ ] `USE_MOCK_AI` を実装する。
- [ ] `aiChatService.ts` を実装する。
- [ ] System Prompt を実装する。
- [ ] Mode Prompt を実装する。
- [ ] aiProfileSummary を組み立てる。
- [ ] latest analysis / archetype / recent logs をAI入力に含める。
- [ ] AI API失敗時のエラーハンドリングを実装する。

## 完了条件

- [ ] mock/real AIを環境変数で切り替えられる。
- [ ] AIがtypeNameや4軸情報を参照した応答を返す。
- [ ] APIキーがGitHubに入っていない。
- [ ] AI失敗時にアプリでエラー表示できる。

---

# PR 8: Daily Log

## 目的

日次ログを30秒で記録できるようにする。

## 作業

- [ ] LogPage を作る。
- [ ] moodScore を入力できる。
- [ ] focusScore を入力できる。
- [ ] actionScore を入力できる。
- [ ] socialStressScore を入力できる。
- [ ] fatigueScore を入力できる。
- [ ] memo を保存できる。
- [ ] typeFitScore を保存できる。
- [ ] dominantTrait を保存できる。
- [ ] 同日再入力時は更新する。
- [ ] 過去7日分を表示する。

## Firestore

```text
daily_logs/{userId}_{YYYY-MM-DD}
```

## 完了条件

- [ ] 今日のログを保存できる。
- [ ] 同日に再保存すると更新される。
- [ ] 過去7日分が一覧表示される。

---

# PR 9: Feedback

## 目的

タイプ・分析・AI会話に対する検証フィードバックを保存する。

## 作業

- [ ] `feedbackSubmit` Function を作る。
- [ ] Home に未回答フィードバックカードを出す。
- [ ] Archetype評価UIを作る。
- [ ] AI会話終了時評価UIを作る。
- [ ] verification mode から feedback を保存できるようにする。

## Firestore

```text
feedback/{feedbackId}
```

## 初期設問

```text
このタイプ説明は自分に近いですか？ 1〜5
西洋占星術サマリーは納得できますか？ 1〜5
インド占星術サマリーは納得できますか？ 1〜5
AIの回答は役に立ちましたか？ 1〜5
```

## 完了条件

- [ ] feedback が保存される。
- [ ] targetType / targetId が入る。
- [ ] AI会話評価が chat_sessions と feedback に残る。

---

# PR 10: Lab News + Stats

## 目的

検証ニュースと簡易統計を表示する。

## 作業

- [ ] LabPage を作る。
- [ ] LabNewsList を作る。
- [ ] LabNewsDetailPage を作る。
- [ ] `labNewsList` Function を作る。
- [ ] `labStats` Function を作る。
- [ ] 統計カードを表示する。
- [ ] seed用サンプルニュースを投入できるようにする。

## Firestore

```text
lab_news/{newsId}
```

## 完了条件

- [ ] `isPublic == true` のニュースだけ表示される。
- [ ] ニュース詳細を読める。
- [ ] userCount / analysisCount / dailyLogCount / feedbackCount が出る。

---

# PR 11: Entitlements + UI Gating

## 目的

Free / Plus の表示・制限差を整える。

## 作業

- [ ] entitlement provider を作る。
- [ ] Free / Plus をUIに表示する。
- [ ] AI会話回数制限をplanで分ける。
- [ ] Plus限定表示を作る。
  - 詳細タイプ説明
  - 複数分析履歴
  - PDF閲覧枠
  - 月次まとめ枠
  - ニュース詳細枠
- [ ] 課金実装はしない。
- [ ] Plus付与はFirestore手動変更でよい。

## 完了条件

- [ ] `plan: free` と `plan: plus` でUIが変わる。
- [ ] 回数制限が変わる。
- [ ] 課金処理は未実装のまま。

---

# PR 12: Firestore Rules + Final MVP Validation

## 目的

Security Rules と最終動作確認を整える。

## 作業

- [ ] Firestore Security Rules を作る。
- [ ] Storage Rules を作る。
- [ ] 自分のデータだけ読めることを確認する。
- [ ] `lab_news` 公開記事だけ読めることを確認する。
- [ ] entitlements 直接書き込み禁止を確認する。
- [ ] README に最終起動手順を書く。
- [ ] MVPチェックリストを埋める。

## 完了条件

- [ ] 新規ユーザーの一連フローが通る。
- [ ] Free/Plus差が動く。
- [ ] 主要Firestore書き込みが確認できる。
- [ ] 秘密情報がコミットされていない。

---

## 3. 実装中に守ること

- [ ] docs を正本として扱う。
- [ ] 未来予測機能を混ぜない。
- [ ] 本格課金処理を混ぜない。
- [ ] AI APIキーをアプリ側に置かない。
- [ ] モック実装には `MOCK:` コメントを入れる。
- [ ] 各PRで動作確認コマンドを書く。
- [ ] 迷ったら機能追加ではなくMVP循環の完成を優先する。

---

## 4. v0.1で使う確認コマンド

Flutter。

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run
```

Functions。

```bash
cd functions
npm install
npm run build
npm run lint
```

Firebase Emulator を使う場合。

```bash
firebase emulators:start
```

---

## 5. MVP最終チェックリスト

- [ ] ログインできる。
- [ ] `users/{userId}` が作られる。
- [ ] `entitlements/{userId}` が作られる。
- [ ] 出生情報を保存できる。
- [ ] `profiles/{userId}` が作られる。
- [ ] mock分析を作れる。
- [ ] `analyses/{analysisId}` が作られる。
- [ ] Genesis Type を生成できる。
- [ ] `archetypes/{userId}` が作られる。
- [ ] My Core にタイプが出る。
- [ ] AI Chat 3モードが使える。
- [ ] `chat_sessions` と `chat_messages` が作られる。
- [ ] Free 1日3回制限が動く。
- [ ] Plus 1日30回制限が動く。
- [ ] 日次ログを保存できる。
- [ ] `daily_logs/{userId}_{date}` が作られる。
- [ ] フィードバックを保存できる。
- [ ] `feedback/{feedbackId}` が作られる。
- [ ] Labニュースを読める。
- [ ] Lab統計が出る。
- [ ] READMEに起動手順がある。
- [ ] APIキーがコミットされていない。

---

## 6. 最重要判断

GenesisCore App v0.1 は、機能を増やして完成させるのではない。

以下の循環を通すことで完成させる。

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

この循環に関係しない実装は、v0.1では後回しにする。
