// ============================================================
//  頒布ページの見本画像(A4 縦 2 ページ)
//  1 ページ目 = 書籍にしたときの表紙の想定、2 ページ目 = 最終ページ(既刊と奥付)。
//  画像として載せるだけで、配布する main.pdf には含めない
//  画像: typst compile --font-path fonts sample.typ sample-{p}.png --ppi 150
// ============================================================
#import "theme.typ": *
#import "deco.typ": dot-field, survey-frame, scale-bar, lbl

#let pw = 210mm
#let ph = 297mm
#let mx = 16mm

#set page(
  width: pw,
  height: ph,
  margin: (x: mx, top: 18mm, bottom: 24mm),
  background: context {
    let p = here().page()
    dot-field(if p == 1 { "cover" } else { "last" }, w: 210, h: 297)
    survey-frame(if p == 1 { "SHEET 428 · 分散型SNSってなんですか？ · 表紙" } else { "SHEET 428 · 既刊と奥付" }, W: pw, H: ph, right-gap: mx + 38mm)
    scale-bar(mx, ph - 9mm)
    place(dx: pw - mx - 34mm, dy: ph - 15.6mm, image("images/yotsuyalab.svg", width: 34mm))
  },
)
#set text(lang: "ja", font: body-font, size: fs.m, fill: ink)
#set par(justify: false, leading: 0.6em, spacing: 0.9em, first-line-indent: 0pt)

// 上に罫と、罫の起点の太い印(本体の見出しと同じ形)
#let ruled(label, body) = block(width: 100%, stroke: (top: rule), inset: (top: 2.5mm), {
  place(std.top + left, dy: -2.5mm - 0.6mm, rect(width: 12mm, height: 1.2mm, fill: ink, stroke: none))
  place(std.top + right, dy: -2.5mm + 0.8mm, lbl(label))
  body
})

// しくみの名前: 色の線と白抜きの丸、名前(裏面の列の頭と同じ形)
#let scheme(key, name) = block(width: 100%, {
  let col = palette.at(key)
  box(width: 100%, height: 3mm, {
    place(left + horizon, line(length: 100%, stroke: 1.6pt + col))
    place(left + horizon, circle(radius: 1.5mm, fill: white, stroke: 1.6pt + col))
  })
  v(0.5mm)
  text(size: fs.l, weight: 700, fill: col, name)
})

// ============================================================
//  表紙
// ============================================================

#text(font: mono, size: fs.xs, fill: luma(90))[四谷ラボ / 技術書典21 無料配布 / 2026.11.23]
#v(1fr)
#block({
  set par(leading: 0.5em)
  set text(cjk-latin-spacing: none)
  text(size: 64pt, weight: 700, features: ("palt",), tracking: -0.03em)[分散型SNS]
  linebreak()
  text(size: 42pt, weight: 700, features: ("palt",), tracking: -0.02em)[ってなんですか？]
})
#v(6mm)
#text(size: fs.l, weight: 700)[中央集権型との違い、SNS の歴史、\ そして Nostr・Bluesky・ActivityPub のしくみ]
#v(1fr)
#block(width: 120mm, text(size: fs.m, fill: luma(50))[
  X（旧 Twitter）や Instagram のほかにも、1 つの会社に頼らずに動く SNS がいくつもあります。表面では、中央集権型の SNS と分散型の SNS の違いと、SNS がどう移り変わってきたかを紹介します。裏面では、いま広く使われている 3 つのしくみを、同じ 4 つの問いで比べます。
])
#v(1fr)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 6mm,
  scheme("nostr", "Nostr"),
  scheme("bluesky", "Bluesky"),
  scheme("ap", "ActivityPub"),
)
#v(6mm)
#text(font: mono, size: fs.xs, fill: luma(90))[FREE PAPER · 無料配布]

// ============================================================
//  最終ページ: 既刊と奥付
// ============================================================
#pagebreak()

#ruled("BOOKS", {
  text(size: fs.xl, weight: 700, cjk-latin-spacing: none)[四谷ラボの分散型SNS本]
  v(4mm)
  let books = (
    ("技術書典14", [Hello Nostr! 先住民が教えるNostrの歩き方]),
    ("技術書典15", [Hello Nostr! Yo Bluesky! 分散SNSの最前線]),
    ("技術書典16", [Hello Nostr, Yo Bluesky 2 最先端分散型SNSの愉快な仲間たち]),
    ("技術書典17", [Hello Nostr, Yo Bluesky 3 未来を担う分散型SNS]),
    ("技術書典18", [Enjoy！ 分散型SNS メタクソ化の特効薬は分散型だけ！]),
    ("技術書典20", [More 分散型SNS！Architectureのもっと深いトコロ]),
    ("技術書典21 新刊", [未来を掴め！AIと分散型と楽しい仲間たち]),
  )
  grid(
    columns: (24mm, 1fr),
    row-gutter: 3.2mm,
    ..books.map(((ev, t)) => (text(font: mono, size: fs.s, fill: luma(90), ev), text(size: fs.m, weight: 500, t))).flatten(),
  )
  v(3mm)
  text(size: fs.s, fill: luma(70))[このシートは、技術書典21 の新刊『未来を掴め！AIと分散型と楽しい仲間たち』の副読本です。\ 既刊の紹介と頒布先は「四谷ラボ BOOKS」（https://books.428lab.net）にまとめています。]
})

#v(12mm)

#ruled("ABOUT", {
  text(size: fs.xl, weight: 700)[四谷ラボについて]
  v(3mm)
  block(width: 120mm)[
    四谷ラボは、みんなで楽しくわいわいやっていこうというコミュニティです。拠点は東京都新宿区四谷にあります。分散型SNSの Meetup を開いたり、技術書典で本を出したりしています。ふだんは Discord のサーバーで活動しています。
  ]
  v(2mm)
  text(font: mono, size: fs.s)[Discord　https://discord.gg/keeb3NjPYY]
})

#v(1fr)

#ruled("COLOPHON", {
  block({
    set par(leading: 0.3em)
    text(size: fs.xl, weight: 700, features: ("palt",), cjk-latin-spacing: none)[分散型SNSってなんですか？]
  })
  v(1mm)
  text(size: fs.s)[2026年11月23日 発行（電子版、技術書典21 で無料配布）]
  v(4mm)
  line(length: 100%, stroke: hair)
  v(3mm)
  let role(r, who) = (text(size: fs.s, weight: 700, r), text(size: fs.s, who))
  grid(
    columns: (24mm, 1fr),
    row-gutter: 3mm,
    ..role([ライター], [Shino3（しのさん）、Claude、Codex]),
    ..role([デザイン], [Claude]),
    ..role([発行], [四谷ラボ　https://428lab.net]),
  )
  v(4mm)
  text(size: fs.s)[© 2026 四谷ラボ]
})
