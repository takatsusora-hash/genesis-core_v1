# GenesisCore Archetype Engine Spec v0.1

この文書は GenesisCore App v0.1 における独自タイプ判定エンジンの仕様正本である。

目的は、新しい占星術体系を発明することではない。  
既存の占星術指標を、アプリ上で比較しやすく、会話に出しやすく、検証しやすい形式へ圧縮することである。

---

## 0. エンジンの目的

Archetype Engine は、占星術の複雑な情報を以下に変換する。

```text
西洋占星術 / インド占星術 / Big Five
  ↓
内部スコア
  ↓
4軸
  ↓
16タイプ
  ↓
AI会話・日次ログ・検証フィードバックで利用
```

v0.1 では完全な占星術計算エンジンを作るのではなく、既存 GenesisCore 分析結果を受け取り、タイプ表示と検証データ回収に必要な形へ変換する。

---

## 1. 絶対方針

- 16タイプは最終分類ではない。
- 16タイプは外部表示用の圧縮ラベルである。
- 内部では詳細スコアを保持する。
- 将来、64タイプ、128タイプ、連続スコア表示へ拡張できるようにする。
- v0.1 では mock 入力でもUI/DB/APIの流れを完成させる。

---

## 2. 外部表示と内部情報の分離

### 外部表示

ユーザーに見せるもの。

```text
Genesis Type
4軸ラベル
4軸スコア
短い説明
AIに相談する導線
```

### 内部情報

AI会話と検証に使うもの。

```text
惑星強度
4元素
3区分
ラグナ情報
ナクシャトラ情報
西洋サマリー
インドサマリー
Big Five傾向
日次ログとの一致度
```

---

## 3. 4軸固定

v0.1 の4軸は以下で固定する。

| Key | 日本語 | A側 | B側 | 意味 |
|---|---|---|---|---|
| ignition | 起動力 | ignition / 発火型 | storage / 蓄積型 | 外へ動き出す速度と押し出し |
| cognition | 認知 | intuitive / 直観型 | logical / 構造型 | 世界の掴み方、判断の組み方 |
| emotion | 感情処理 | reactive / 即応型 | deep / 深層型 | 感情の出方と処理の深さ |
| social | 社会接続 | personal / 個人主導型 | connective / 関係調整型 | 人や集団との接続形式 |

---

## 4. Type Code 仕様

4軸それぞれを1文字で表す。

### ignition

| Label | Code | 条件 |
|---|---|---|
| ignition | I | ignitionScore >= 50 |
| storage | S | ignitionScore < 50 |

### cognition

| Label | Code | 条件 |
|---|---|---|
| intuitive | N | cognitionScore >= 50 |
| logical | L | cognitionScore < 50 |

### emotion

| Label | Code | 条件 |
|---|---|---|
| reactive | R | emotionScore >= 50 |
| deep | D | emotionScore < 50 |

### social

| Label | Code | 条件 |
|---|---|---|
| personal | P | socialScore >= 50 |
| connective | C | socialScore < 50 |

### typeCode 例

```text
INRP
SLDC
ILDP
SNR C -> spaces are invalid. Correct: SNRC
```

必ず4文字にする。

```text
[ I | S ][ N | L ][ R | D ][ P | C ]
```

---

## 5. 16タイプ一覧 v0.1

v0.1 では、名前は暫定でよい。  
ただし表示名は高級感・分析感・人格ラベル感を持たせる。

| Code | Name | Short Description |
|---|---|---|
| INRP | Ignis Navigator | 直観で素早く動き、自分主導で道を切り開くタイプ |
| INRC | Ignis Harmonizer | 直観と反応速度が強く、人との接続で力を出すタイプ |
| INDP | Ignis Oracle | 直観を内側で深め、自分の道として発火させるタイプ |
| INDC | Ignis Empath | 直観と深い感情処理を、人との接続に使うタイプ |
| ILRP | Ignis Strategist | 構造判断と即応力で、自分主導の突破を行うタイプ |
| ILRC | Ignis Coordinator | 構造判断と反応速度を、人間関係の中で使うタイプ |
| ILDP | Ignis Architect | 構造を深く組み、自分主導で形にするタイプ |
| ILDC | Ignis Mediator | 構造と深い感情処理で、関係を整えるタイプ |
| SNRP | Aether Seeker | 内側に蓄積した直観を、自分の探索に使うタイプ |
| SNRC | Aether Connector | 直観と反応感度を、関係接続に使うタイプ |
| SNDP | Aether Mystic | 深層直観を内側で育て、自分の核にするタイプ |
| SNDC | Aether Listener | 深層直観と共感性で、人の流れを読むタイプ |
| SLRP | Terra Executor | 構造判断を蓄積し、必要時に即行動へ変えるタイプ |
| SLRC | Terra Operator | 構造判断と調整力で、現実を動かすタイプ |
| SLDP | Terra Architect | 深く蓄積した構造力で、長期的に形を作るタイプ |
| SLDC | Terra Keeper | 深い処理と調整力で、場と関係を安定させるタイプ |

---

## 6. Score Model v0.1

各軸は 0〜100 の整数で保持する。

```ts
type AxisScores = {
  ignitionScore: number;
  cognitionScore: number;
  emotionScore: number;
  socialScore: number;
  confidenceScore: number;
};
```

### 判定

```ts
ignitionScore >= 50 ? 'I' : 'S'
cognitionScore >= 50 ? 'N' : 'L'
emotionScore >= 50 ? 'R' : 'D'
socialScore >= 50 ? 'P' : 'C'
```

### 50点付近の扱い

45〜55 は境界域とする。

```ts
isBorderline = score >= 45 && score <= 55
```

境界域が多い場合、`confidenceScore` を下げる。

---

## 7. Confidence Score

タイプ判定の確信度。

### 計算方針 v0.1

各軸について、50からの距離を出す。

```ts
distance = abs(score - 50)
```

4軸の平均距離を 0〜100 に変換する。

```ts
averageDistance = mean([
  abs(ignitionScore - 50),
  abs(cognitionScore - 50),
  abs(emotionScore - 50),
  abs(socialScore - 50),
])

confidenceScore = clamp(round(averageDistance * 2), 0, 100)
```

例。

```text
全軸が80/20付近 → confidence高い
全軸が50付近 → confidence低い
```

---

## 8. 入力データ仕様

Archetype Engine は以下の入力を受け取る。

```ts
type ArchetypeInput = {
  analysisId: string;
  userId: string;

  western?: WesternAstrologyInput;
  jyotish?: JyotishInput;
  bigFive?: BigFiveInput | null;

  summaries?: {
    westernSummary?: string;
    jyotishSummary?: string;
    bigFiveSummary?: string | null;
  };

  mock?: boolean;
};
```

---

## 9. WesternAstrologyInput v0.1

v0.1 では受け取れる範囲だけ使う。

```ts
type WesternAstrologyInput = {
  elements?: {
    fire?: number;
    earth?: number;
    air?: number;
    water?: number;
  };
  modes?: {
    cardinal?: number;
    fixed?: number;
    mutable?: number;
  };
  planets?: {
    sun?: PlanetScore;
    moon?: PlanetScore;
    mercury?: PlanetScore;
    venus?: PlanetScore;
    mars?: PlanetScore;
    jupiter?: PlanetScore;
    saturn?: PlanetScore;
  };
  houses?: {
    first?: number;
    fourth?: number;
    seventh?: number;
    eighth?: number;
    tenth?: number;
    eleventh?: number;
  };
};

type PlanetScore = {
  strength?: number; // 0-100
  sign?: string | null;
  house?: number | null;
};
```

---

## 10. JyotishInput v0.1

```ts
type JyotishInput = {
  lagna?: {
    sign?: string;
    strength?: number; // 0-100
  };
  moonNakshatra?: {
    name?: string;
    pada?: number | null;
  };
  grahaStrengths?: {
    sun?: number;
    moon?: number;
    mars?: number;
    mercury?: number;
    jupiter?: number;
    venus?: number;
    saturn?: number;
    rahu?: number;
    ketu?: number;
  };
};
```

---

## 11. BigFiveInput v0.1

Big Five は占星術判定の主軸ではない。  
補正と検証に使う。

```ts
type BigFiveInput = {
  openness?: number;         // 0-100
  conscientiousness?: number;
  extraversion?: number;
  agreeableness?: number;
  neuroticism?: number;
};
```

---

## 12. Axis Calculation v0.1

### ignitionScore

起動力。外へ動き出す速度、押し出し、行動熱量。

主材料。

- fire element
- cardinal mode
- sun strength
- mars strength
- 1st house
- 10th house
- jyotish lagna strength
- jyotish mars strength
- Big Five extraversion

重み v0.1。

```ts
ignitionScore = weightedAverage([
  fireScore * 0.20,
  cardinalScore * 0.15,
  sunStrength * 0.15,
  marsStrength * 0.20,
  firstHouseScore * 0.10,
  tenthHouseScore * 0.10,
  lagnaStrength * 0.05,
  bigFiveExtraversion * 0.05,
])
```

### cognitionScore

認知。直観・象徴・全体把握に寄るほど高い。構造・検証・現実処理に寄るほど低い。

主材料。

- air element
- fire element
- mercury strength
- jupiter strength
- saturn strength
- earth element
- Big Five openness
- conscientiousness

重み v0.1。

```ts
cognitionScore = weightedAverage([
  airScore * 0.18,
  fireScore * 0.10,
  mercuryStrength * 0.15,
  jupiterStrength * 0.18,
  bigFiveOpenness * 0.14,
  inverse(earthScore) * 0.10,
  inverse(saturnStrength) * 0.10,
  inverse(bigFiveConscientiousness) * 0.05,
])
```

### emotionScore

感情処理。即時反応が強いほど高い。深く内部処理するほど低い。

主材料。

- moon strength
- venus strength
- water element
- 4th house
- 8th house
- fixed mode
- Big Five neuroticism

重み v0.1。

```ts
emotionScore = weightedAverage([
  moonStrength * 0.20,
  venusStrength * 0.10,
  waterScore * 0.15,
  fourthHouseScore * 0.10,
  bigFiveNeuroticism * 0.15,
  inverse(eighthHouseScore) * 0.10,
  inverse(fixedScore) * 0.10,
  inverse(saturnStrength) * 0.10,
])
```

### socialScore

社会接続。個人主導が強いほど高い。関係調整が強いほど低い。

主材料。

- 1st house
- 10th house
- mars strength
- sun strength
- 7th house
- 11th house
- venus strength
- moon strength
- agreeableness

重み v0.1。

```ts
socialScore = weightedAverage([
  firstHouseScore * 0.15,
  tenthHouseScore * 0.10,
  marsStrength * 0.15,
  sunStrength * 0.10,
  inverse(seventhHouseScore) * 0.15,
  inverse(eleventhHouseScore) * 0.10,
  inverse(venusStrength) * 0.10,
  inverse(bigFiveAgreeableness) * 0.15,
])
```

---

## 13. Missing Data Handling

v0.1 では、全ての占星術指標が揃わない前提で設計する。

### ルール

- 入力がある項目だけで weightedAverage を再正規化する。
- 全項目がない場合は mock default を使う。
- Big Five がない場合は Big Five 項目を無視する。
- Jyotish がない場合は Western のみで判定する。
- Western がない場合は Jyotish + summary keyword + mock補完。

### weightedAverage

```ts
function weightedAverage(items: Array<{ value: number | null, weight: number }>): number {
  const valid = items.filter(x => x.value !== null && x.value !== undefined);
  if (valid.length === 0) return 50;
  const totalWeight = valid.reduce((sum, x) => sum + x.weight, 0);
  const raw = valid.reduce((sum, x) => sum + x.value! * x.weight, 0) / totalWeight;
  return clamp(Math.round(raw), 0, 100);
}
```

### inverse

```ts
function inverse(value: number | null | undefined): number | null {
  if (value === null || value === undefined) return null;
  return 100 - value;
}
```

---

## 14. Mock Compiler v0.1

既存API接続前でも開発を進めるため、mockCompiler を必ず実装する。

### 入力

```ts
{
  userId: string,
  analysisId: string,
  seed?: string
}
```

### 出力

以下を固定または seed から生成する。

```ts
{
  ignitionScore: 72,
  cognitionScore: 68,
  emotionScore: 42,
  socialScore: 76
}
```

初期固定値では `INDP` または `INRP` など、UI映えするタイプでよい。

---

## 15. Type Description 生成

v0.1 ではAI生成ではなく、固定テンプレートを使う。

### Template

```ts
const TYPE_DEFINITIONS = {
  INRP: {
    name: 'Ignis Navigator',
    description: '直観で素早く動き、自分主導で道を切り開くタイプ。'
  },
  ...
}
```

### 表示内容

My Core では以下を表示する。

```text
Type Name
Short Description
4 Axis Scores
Dominant Axis
Borderline Axis
AIに相談するボタン
```

---

## 16. Dominant Axis

最も50から離れている軸を dominantAxis とする。

```ts
dominantAxis = maxBy([
  { key: 'ignition', distance: abs(ignitionScore - 50) },
  { key: 'cognition', distance: abs(cognitionScore - 50) },
  { key: 'emotion', distance: abs(emotionScore - 50) },
  { key: 'social', distance: abs(socialScore - 50) },
])
```

Firestore v0.1 では保存必須ではないが、UI計算で使う。

---

## 17. Borderline Axis

45〜55 の軸を borderline とする。

```ts
borderlineAxes = axes.filter(score => score >= 45 && score <= 55)
```

UIでは「この軸は変動しやすい」と表示してよい。

---

## 18. Output Type

Cloud Functions の `archetypeCompile` は以下を返す。

```ts
type ArchetypeOutput = {
  userId: string;
  analysisId: string;

  typeCode: string;
  typeName: string;
  typeDescription: string;

  axisLabels: {
    ignition: 'ignition' | 'storage';
    cognition: 'intuitive' | 'logical';
    emotion: 'reactive' | 'deep';
    social: 'personal' | 'connective';
  };

  ignitionScore: number;
  cognitionScore: number;
  emotionScore: number;
  socialScore: number;
  confidenceScore: number;

  detailScores: Record<string, number | null>;
};
```

この出力を `archetypes/{userId}` に保存する。

---

## 19. AI Profile への接続

Archetype Engine の出力は `aiProfileSummary` に反映する。

例。

```text
このユーザーのGenesis Typeは Ignis Architect。起動力は高く、認知は構造型、感情処理は深層型、社会接続は個人主導型。会話では、抽象的な慰めよりも具体的な整理、戦略、短い行動分解が有効。
```

v0.1 では analysis.aiProfileSummary にこの内容を入れるか、chatSendMessage 時に archetypes から組み立てる。

---

## 20. Feedback への接続

Archetype の検証設問。

```text
このタイプ説明は自分に近いですか？ 1〜5
4軸スコアのうち、最も納得するものはどれですか？
4軸スコアのうち、最も違和感があるものはどれですか？
```

保存先。

```text
feedback/{feedbackId}
targetType: 'archetype'
targetId: typeCode or userId
```

---

## 21. v0.1 実装順序

1. `TYPE_DEFINITIONS` を作る。
2. `mockCompiler` を作る。
3. `buildTypeCode(scores)` を作る。
4. `calculateConfidence(scores)` を作る。
5. `compileArchetype(input)` を作る。
6. Firestore へ保存する `archetypeCompile` Function を作る。
7. Flutter の My Core 画面で表示する。
8. Feedback と AI Chat に接続する。

---

## 22. v0.1 受け入れ条件

```text
mock分析から archetypeCompile が実行できる
archetypes/{userId} に保存される
typeCode が4文字で生成される
typeName と description が表示される
4軸スコアが0〜100で表示される
confidenceScore が生成される
AI Chat で type情報が参照される
Feedback で archetype評価を保存できる
```

---

## 23. 将来拡張メモ

v0.1 では実装しない。

- 64タイプ化
- ダシャー / トランジットとの接続
- ナクシャトラ分類の表示
- タイプ別集合統計
- フィードバックによる重み自動調整
- AIによるタイプ説明文の個別生成
- タイプ相性
- 月次タイプ変動

この文書では、v0.1 の実装に必要な最小核だけを固定する。
