# techbookfest-21-sub

技術書典21(2026-11-23 発行)で四谷ラボが**無償配布**するドキュメントのリポジトリ。
本体の同人誌「未来を掴め！AIと分散型と楽しい仲間たち」(`~/Project/techbookfest-21`、GitHub: 428lab/techbookfest-21)の姉妹プロジェクト。
GitHub: https://github.com/428lab/techbookfest-21-sub(公開)

## 最初の指示(本体のセッションから引き継ぎ)

このリポジトリはまだ空。中身(何を配るか、判型、ページ数、紙か電子か)は Shino3 さんがこのセッションで決めるので、
**先に作り込まず**、次の順で進める。

1. 本体 `~/Project/techbookfest-21` の `template.typ` / `theme.typ` / `emo.typ` / `fonts/` / `scripts/build-book.sh` を読んで、
   同じ見た目(丸ゴシック Rounded Mplus 1c、ネットワーク模様の飾り、E 案の細い罫線)で組める最小構成を把握する
2. Shino3 さんに、配布物の種類・判型・ページ数の目安・締め切りを確認する(選択肢を並べて聞く。決め打ちしない)
3. 決まったら、本体からテンプレートとフォントを**コピー**して(submodule や相対 import で本体に依存させない)、
   仮の本文 1〜2 ページで `typst compile --font-path fonts main.typ` が通る骨組みを作る
4. 骨組みができたら PNG で組み上がりを見せる

## 本体から引き継ぐ約束事

- 返答・コメント・コミットメッセージは日本語
- Typst 0.14.2。ビルドは常に `typst compile --font-path fonts main.typ`(`--font-path` を忘れるとフォントが変わる)。
  Shino3 さんは手元で `typst watch --font-path fonts main.typ` を回すので、ラッパーやガードは作らない
- 確認用の画像はページを PNG に出して送る(`typst compile ... --pages N --ppi 90 out.png`)
- 文章の校正・整合確認は Codex(`codex exec --sandbox read-only --skip-git-repo-check -c 'hooks={}' -C "$PWD" -o out.md "…" < /dev/null`、macOS に `timeout` はない)、
  事実確認は Web を当たる。デザインの相談は Opus
- push・PR・マージは頼まれたときだけ。コミットも頼まれてから。
  頼まれたら ブランチ → PR → マージ の流れで main に入れる
- `inbox/` は素材の置き場で、コミットしない
- 挿絵の原本は 428lab/techbookfest-illusts(Git LFS)にあり、使う分だけ各リポジトリへコピーする
