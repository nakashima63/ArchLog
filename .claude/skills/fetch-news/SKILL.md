---
name: fetch-news
description: システムアーキテクト向けの最新技術ニュースをインターネットから収集し、Markdownファイルを生成してGitHub Pagesにデプロイする。
disable-model-invocation: true
allowed-tools: WebSearch, WebFetch, Write, Read, Glob, Grep, Bash(bash *), Bash(git *), Bash(gh *)
---

# fetch-news: 技術ニュース収集スキル

システムアーキテクト向けの最新技術記事を収集し、ArchLogサイトに追加する。

## 手順

### Step 1: ニュース収集

以下の領域について、**直近14日以内**の新しい記事をWebSearchで検索する。
各領域につき少なくとも1〜2回検索を行い、合計で多様なソースから記事を集める。

**検索領域（優先順）:**

各領域について **日本語クエリを先に実行** し、日本語記事を優先的に収集する。
日本語で十分な記事が見つからない領域のみ英語クエリで補完する。
最終的な記事の **日本語:英語 の比率は 6:4〜7:3** を目安にする。

1. **AWS / クラウド設計** — ネットワーク、セキュリティ、可用性、コスト最適化、運用
   - 日本語: `AWS 新機能 アップデート 2026`, `クラウド アーキテクチャ 設計 2026`
   - 英語: `AWS new features 2026`
2. **アーキテクチャパターン** — DDD、Hexagonal Architecture、CQRS、Event Sourcing、マイクロサービス、モノリス分割
   - 日本語: `DDD ドメイン駆動設計 2026`, `マイクロサービス アーキテクチャ 設計 2026`
   - 英語: `microservices CQRS event sourcing 2026`
3. **分散システム基礎** — CAP定理、整合性、キュー/ストリーム、リトライ戦略、冪等性、SLO/SLI
   - 日本語: `分散システム 信頼性 SRE 2026`, `SLO SLI 可観測性 2026`
   - 英語: `distributed systems reliability 2026`
4. **インフラ / IaC** — Terraform、CDK、CloudFormation、Kubernetes
   - 日本語: `Terraform CDK インフラ 構成管理 2026`, `Kubernetes 最新 2026`
   - 英語: `infrastructure as code updates 2026`
5. **観測性** — ログ、メトリクス、トレース、OpenTelemetry
   - 日本語: `OpenTelemetry 可観測性 オブザーバビリティ 2026`, `分散トレーシング 2026`
   - 英語: `OpenTelemetry observability 2026`
6. **セキュリティ** — ゼロトラスト、IAM設計、脅威モデリング、OWASP
   - 日本語: `ゼロトラスト クラウドセキュリティ 2026`, `IAM 設計 セキュリティ 2026`
   - 英語: `zero trust cloud security 2026`
7. **データ基盤** — RDB設計、NoSQL選定、キャッシュ戦略、検索、ETL/ELT
   - 日本語: `データベース設計 データ基盤 2026`, `データエンジニアリング ETL 2026`
   - 英語: `database architecture data engineering 2026`
8. **重要なリリース/アップデート** — AWS公式ブログ、主要OSSリリースノート
   - 日本語: `AWS 公式ブログ アップデート 2026`, `OSS リリース 新機能 2026`
   - 英語: `AWS blog announcements 2026`

**検索のコツ:**
- 現在の年月を検索クエリに含める
- **日本語クエリを各領域で必ず1回以上実行する**（日本語記事の割合を確保するため）
- 英語記事は日本語で見つからない領域の補完に使う
- 日本語ソースの優先順: AWS公式日本語ブログ、Zenn、Qiita、DevelopersIO(クラスメソッド)、技術評論社、はてなブログ(技術系)、Publickey、ThinkIT

### Step 1.5: connpassイベント収集

connpassで**直近1ヶ月以内に開催予定**のアーキテクト・AI関連イベントをWebSearchで検索する。
以下のクエリを実行し、合計5〜10件程度のイベントを収集する。

**検索クエリ:**
- `connpass アーキテクチャ 設計 イベント YYYY年M月`
- `connpass AI LLM エージェント イベント YYYY年M月`
- `connpass AWS クラウド インフラ イベント YYYY年M月`
- `connpass SRE 可観測性 マイクロサービス イベント YYYY年M月`
- `connpass セキュリティ ゼロトラスト DevSecOps イベント YYYY年M月`
- `connpass GenAI 生成AI YYYY年M月`

**収集対象のイベントカテゴリ:**
- クラウド / AWS（JAWS-UGなど）
- アーキテクチャ / 設計
- SRE / 信頼性
- インフラ / IaC（HashiCorp、Kubernetes関連など）
- セキュリティ / ゼロトラスト
- AI / LLM / エージェント
- データエンジニアリング

**選定基準:**
- connpass上のイベントページURLが確認できるもの
- 開催日が収集日から1ヶ月以内のもの
- システムアーキテクトやエンジニアに関連性が高いもの

### Step 2: Markdownファイルの生成

収集した記事を以下の形式でMarkdownファイルに書き出す。

**ファイル名:** `docs/news/YYYY-MM-DD.md`（収集日）

**ファイル形式:**

```markdown
# Tech News - YYYY-MM-DD

## AWS / クラウド設計

- **[記事タイトル](URL)** — 1〜2行の要約（自分の言葉で書く。転載禁止） — *ソース名* — 公開日

## アーキテクチャパターン

- **[記事タイトル](URL)** — 要約 — *ソース名* — 公開日

## 分散システム

（以下同様、該当カテゴリのみ）

## 注目イベント（connpass）

直近開催予定のアーキテクト・AI関連イベントをピックアップ。

| 日付 | イベント名 | カテゴリ |
|------|-----------|----------|
| MM/DD (曜) | [イベント名](connpass URL) | カテゴリ |

---

## メタ情報

- 収集日: YYYY-MM-DD
- 収集ツール: Claude Code `/fetch-news`
- 検索クエリ: （使用したクエリをリスト）
- フィルタ条件: 直近14日以内の記事
- 対象言語: 英語・日本語
```

**重要ルール:**
- 各記事の要約は **自分の言葉による短いサマリ** にする（原文のコピー禁止）
- 引用は必要な場合のみ、短いフレーズにとどめる
- 同一URLは重複排除する
- カテゴリごとにグループ化する
- 該当記事がないカテゴリは省略する

### Step 3: セキュリティチェック

生成したMarkdownファイルに対してセキュリティ検査を実行する。

```bash
bash .claude/skills/fetch-news/scripts/security_check.sh docs
```

**検査が失敗した場合:**
1. 問題のある箇所を特定して修正する
2. 再度検査を実行する
3. すべてパスするまで繰り返す

### Step 4: ニュース一覧ページの更新

`docs/news/index.md` のテーブルに新しいニュースエントリを追加する。
日付の降順（新しい日付が上）で行を追加し、カテゴリ列には該当カテゴリをカンマ区切りで記載する。

```markdown
| 日付 | カテゴリ |
|------|----------|
| [YYYY-MM-DD](YYYY-MM-DD.md) | カテゴリ1、カテゴリ2、... |
```

### Step 5: mkdocs.yml のナビゲーション更新

新しいニュースファイルを `mkdocs.yml` の `nav` セクションに追加する。
既存のナビゲーション構造を壊さないよう注意する。

### Step 6: コミットとプッシュ

1. 変更内容を確認する（`git status`, `git diff`）
2. ニュースファイル、index.md、更新したmkdocs.ymlをステージングする
3. コミットメッセージは `docs: add tech news for YYYY-MM-DD` とする
4. **ユーザーに確認してからプッシュする**

```bash
git add docs/news/YYYY-MM-DD.md docs/news/index.md mkdocs.yml
git commit -m "docs: add tech news for YYYY-MM-DD"
```

プッシュ後、GitHub Actionsがセキュリティ検査を実行し、パスした場合のみGitHub Pagesにデプロイされる。

## 注意事項

- 秘密情報（APIキー、トークン、パスワード等）を絶対に含めない
- 個人情報を含めない
- 内部URL・IPアドレスを含めない
- 著作権に配慮し、転載ではなく要約にする
