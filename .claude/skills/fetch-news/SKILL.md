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

1. **AWS / クラウド設計** — ネットワーク、セキュリティ、可用性、コスト最適化、運用
   - 検索例: `AWS new features 2026`, `cloud architecture best practices 2026`
2. **アーキテクチャパターン** — DDD、Hexagonal Architecture、CQRS、Event Sourcing、マイクロサービス、モノリス分割
   - 検索例: `DDD domain driven design architecture 2026`, `microservices patterns 2026`
3. **分散システム基礎** — CAP定理、整合性、キュー/ストリーム、リトライ戦略、冪等性、SLO/SLI
   - 検索例: `distributed systems reliability 2026`, `SLO SLI observability 2026`
4. **インフラ / IaC** — Terraform、CDK、CloudFormation、Kubernetes
   - 検索例: `Terraform CDK infrastructure as code 2026`, `Kubernetes updates 2026`
5. **観測性** — ログ、メトリクス、トレース、OpenTelemetry
   - 検索例: `OpenTelemetry observability 2026`, `distributed tracing best practices`
6. **セキュリティ** — ゼロトラスト、IAM設計、脅威モデリング、OWASP
   - 検索例: `zero trust architecture 2026`, `cloud security IAM 2026`
7. **データ基盤** — RDB設計、NoSQL選定、キャッシュ戦略、検索、ETL/ELT
   - 検索例: `database architecture 2026`, `data engineering ETL 2026`
8. **重要なリリース/アップデート** — AWS公式ブログ、主要OSSリリースノート
   - 検索例: `AWS blog announcements 2026`, `open source releases 2026`

**検索のコツ:**
- 現在の年月を検索クエリに含める
- 英語と日本語の両方で検索する
- 公式ブログ、技術ブログ、カンファレンス発表を優先する

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

### Step 4: mkdocs.yml のナビゲーション更新

新しいニュースファイルを `mkdocs.yml` の `nav` セクションに追加する。
既存のナビゲーション構造を壊さないよう注意する。

### Step 5: コミットとプッシュ

1. 変更内容を確認する（`git status`, `git diff`）
2. ニュースファイルと更新したmkdocs.ymlをステージングする
3. コミットメッセージは `docs: add tech news for YYYY-MM-DD` とする
4. **ユーザーに確認してからプッシュする**

```bash
git add docs/news/YYYY-MM-DD.md mkdocs.yml
git commit -m "docs: add tech news for YYYY-MM-DD"
```

プッシュ後、GitHub Actionsがセキュリティ検査を実行し、パスした場合のみGitHub Pagesにデプロイされる。

## 注意事項

- 秘密情報（APIキー、トークン、パスワード等）を絶対に含めない
- 個人情報を含めない
- 内部URL・IPアドレスを含めない
- 著作権に配慮し、転載ではなく要約にする
