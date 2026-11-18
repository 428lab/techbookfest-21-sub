// ============================================================
//  技術書典21 無料配布シート「分散型SNSってなんですか？」
//  A3 横(420 × 297 mm)両面・電子版のみ。
//  表面 = 中央集権型と分散型の違い、SNS の歴史。裏面 = 3 つのしくみを同じ 4 つの問いで比べる格子。
//  段組みは文章の長い場所だけで使い、ほかは mm 指定の grid で面を割る
//  ビルド: typst compile --font-path fonts main.typ
// ============================================================
#import "theme.typ": *
#import "figures.typ": fig-relay, fig-pipeline, fig-federation, fig-central, fig-distributed, fig-enshit, fig-cap
#import "timeline.typ": timeline-axis, legend
#import "deco.typ": *

#set document(
  title: "分散型SNSってなんですか？",
  author: "四谷ラボ",
  date: datetime(year: 2026, month: 11, day: 23),
)

// ---- 面の寸法 ----
// 版面は x 12–408mm(396mm)、y 18–283mm(265mm)
// 表面は 61mm の列 6 本(間 6mm)を基準にし、すべての箱をこの列の線にそろえる
#let mx = 12mm
#let c1 = 61mm   // 1 列
#let c2 = 128mm  // 2 列ぶん
#let c4 = 262mm  // 4 列ぶん
#let gut = 6mm
#let top = 18mm
#let body-h = 265mm
#let door-w = 420mm  // 表面の扉。紙の幅いっぱい
#let door-h = top + 44mm
// 扉の見せ方。印刷で塗りが出ない場合に備えて切り替えられるようにしてある
//   ink    : 墨のベタに白抜き(電子版の基本)
//   tint   : ごく薄い灰色の面に墨の文字。塗りが出なくても文字は残る
//   rule   : 塗りなし。背景の地形の点がそのまま見える(基本)
//   stripe : 塗りなし。上に 3 色の帯(Nostr・Bluesky・ActivityPub)
// 比べるときは typst compile --font-path fonts --input door=tint main.typ のように指定する
#let door-style = sys.inputs.at("door", default: "rule")
#let door-dark = door-style == "ink"
#let door-bg = {
  if door-style == "ink" { place(rect(width: door-w, height: door-h, fill: ink)) }
  if door-style == "tint" { place(rect(width: door-w, height: door-h, fill: luma(236))) }
  if door-style == "rule" {
    none
  }
  if door-style == "stripe" {
    for (i, k) in ("nostr", "bluesky", "ap").enumerate() {
      place(dx: i * door-w / 3, dy: 0mm, rect(width: door-w / 3, height: 6mm, fill: palette.at(k)))
    }
  }
}
// 右下のロゴ(両面)
#let logo = {
  // 外周 5mm は刷れないので、ロゴの下端を紙の下から 7mm に置く
  place(dx: 420mm - mx - 36mm, dy: 297mm - 16.5mm, rect(width: 38mm, height: 10.5mm, fill: white, stroke: none))
  place(dx: 420mm - mx - 34mm, dy: 297mm - 15.6mm, image("images/yotsuyalab.svg", width: 34mm))
}

#set page(
  width: 420mm,
  height: 297mm,
  margin: (x: mx, top: top, bottom: 297mm - top - body-h),
  // 背景: 地形を表す点の方眼、山頂の印、縁の目盛り、縮尺
  background: context {
    let p = here().page()
    if p == 1 { door-bg }
    let sheet = if p == 1 { "front" } else { "back" }
    dot-field(sheet)
    survey-frame(if p == 1 { "SHEET 428-A · 分散型SNSってなんですか？ · 表面" } else { "SHEET 428-B · NOSTR / BLUESKY / ACTIVITYPUB · 裏面" })
    scale-bar(mx, 297mm - 9mm)
    logo
  },
)
#set text(lang: "ja", font: body-font, size: 7.3pt, fill: ink)
// 字下げはせず、段落の間を空けて区切る
#set par(justify: true, leading: 0.62em, spacing: 1.05em, first-line-indent: 0pt)
#set list(marker: text(size: 0.7em, "■"), indent: 0.2em, body-indent: 0.5em, spacing: 0.5em)
#show list: set par(first-line-indent: 0pt)
#show link: set text(fill: palette.bluesky.darken(20%))
#set raw(theme: none)
#show raw: set text(font: mono, size: 6.2pt)
#show strong: set text(weight: 700)

// 高さを決めた箱。中身がはみ出すと下に描かれるので、削る合図にする
#let fixed(h, body) = block(width: 100%, height: h, body)
#let cols2(body) = columns(2, gutter: 6mm, body)

// 面の中の大見出し: 小さな英字の札と、太い題
// 面の中の大見出し: 上に罫、灰色の番号、太い題。段の区切りは罫の位置でそろえる
// 罫の起点に置く太い印。定規の起点と同じ形
#let rule-mark = place(std.top + left, dy: -2mm - 0.6mm, rect(width: 12mm, height: 1.2mm, fill: ink, stroke: none))
#let part(no, title, width: 100%, ruled: true) = block(width: width, below: 2mm, stroke: if ruled { (top: rule) } else { none }, inset: (top: if ruled { 2mm } else { 0mm }), {
  set par(first-line-indent: 0pt, justify: false)
  if ruled {
    rule-mark
    place(std.top + right, dy: -2mm + 0.8mm, lbl("SURVEY AREA 0" + no))
  }
  text(font: disp, size: fs.xl, fill: luma(150), no)
  h(2mm)
  text(size: fs.xl, weight: 700, features: ("palt",), title)
})

// 対比の列の頭: 色の正方形、名前、一言
#let side-label(col, name, note) = block(width: 100%, below: 2mm, {
  set par(first-line-indent: 0pt, justify: false)
  text(size: fs.l, weight: 700, name)
  h(2mm)
  text(size: fs.s, weight: 500, fill: luma(80), note)
})

// ============================================================
//  表面: 中央集権型と分散型の違い、SNS の歴史
// ============================================================

// 1 列ぶんの文章。見出しの上端を横にそろえる
#let col-text(key, head, body) = block(width: 100%, {
  sub(key, head)
  body
})

#grid(
  columns: (c4, gut, c2),
  rows: (44mm, 6mm, 100mm, 8mm, 45mm, 8mm, 54mm),

  // ---- 扉(全幅): 左 4 列に題、右 2 列にリード ----
  grid.cell(x: 0, y: 0, colspan: 3, block(width: 100%, height: 100%, inset: (bottom: 6mm), {
    set par(first-line-indent: 0pt, justify: false, spacing: 0.5em)
    set text(fill: if door-dark { white } else { ink })
    grid(
      columns: (c4, c2),
      column-gutter: gut,
      rows: (100%,),
      {
        text(font: mono, size: fs.xs, fill: if door-dark { luma(170) } else { luma(90) })[四谷ラボ / 技術書典21 無料配布 / 2026.11.23]
        v(4mm)
        text(size: fs.xxl, weight: 700, features: ("palt",), tracking: -0.02em)[分散型SNSってなんですか？]
        v(3mm)
        text(size: fs.l, weight: 700)[中央集権型との違い、SNS の歴史、そして Nostr・Bluesky・ActivityPub のしくみ]
      },
      align(bottom, {
        set par(leading: 0.6em, justify: true)
        text(size: fs.m, weight: 400, fill: if door-dark { luma(225) } else { luma(50) })[
          X（旧 Twitter）や Instagram のほかにも、1 つの会社に頼らずに動く SNS がいくつもあります。
          表面では、中央集権型の SNS と分散型の SNS の違いと、SNS がどう移り変わってきたかを紹介します。
          裏面では、いま広く使われている 3 つのしくみを、同じ 4 つの問いで比べます。
        ]
      }),
    )
  })),

  // ---- A: 中央集権型と分散型(4 列) ----
  grid.cell(x: 0, y: 2, fixed(100mm, {
    set text(size: fs.s)
    set par(spacing: 2mm)
    part("1", "中央集権型と分散型は、なにが違う？")
    block(width: 100%, below: 4mm, text(size: fs.s, weight: 500)[
      SNS には、ふだん意識しない 4 つの要素があります。アカウントの *ID*、投稿などの *データ*、タイムラインの *並べ方*、そして何を消して誰を止めるかという *ルール* です。
      中央集権型ではこの 4 つを 1 社がまとめて持ち、*分散型 SNS* ではこれらを 1 社だけに集めず、いくつもの担い手に分けられるようにしています。
    ])
    grid(
      columns: (c2, c2),
      column-gutter: gut,
      row-gutter: 4mm,
      { side-label(palette.central, "中央集権型", [1 社がすべてを持つ。X、Instagram、TikTok など]); fig-central },
      { side-label(palette.nostr, "分散型", [4 つの要素を、別々の担い手に分ける]); fig-distributed },
    )
    v(4mm)
    grid(
      columns: (c1,) * 4,
      column-gutter: gut,
      col-text("central", [中央集権型のよいところ])[
        1 社がすべてを持っているので、登録はすぐに済み、検索やおすすめはネットワーク全体を見渡して働きます。
        迷惑な投稿への対応は 1 つの方針で行われ、新しい機能もいっせいに届きます。
        運営の費用は広告などでまかなわれ、利用者は無料で使えます。
      ],
      col-text("central", [決める会社が 1 つだけ])[
        そのかわり、ルールを変える権限はその会社だけにあります。
        仕様の変更や API の有料化、アカウントの凍結が起きても、利用者にできるのは、従うか、使うのをやめるかのどちらかです。
        やめれば、フォロワーも過去の投稿も置いていくことになります。
      ],
      col-text("nostr", [分けるのは「決める権限」])[
        分散型 SNS が分けようとしているのは、サーバーそのものより、この「決める権限」です。
        利用者がどのサーバーやアプリを使うかを選べて、合わなければ ID やフォロワーとのつながりを保ったまま別のサーバーやアプリへ移れるなら、運営の側も利用者を引き留めるために、よいサービスであり続ける必要があります。
      ],
      col-text("nostr", [分け方と、増える手間])[
        分け方は 3 通りです。サーバーどうしが投稿を送り合う連合型（ActivityPub）、投稿をいくつものリレーに預けるリレー型（Nostr）、データを置くサーバーと表示するアプリを分ける型（AT Protocol）があります（裏面）。

        分けたぶんだけ、どのサーバーに入るか、鍵をどう守るかなど、使う側が選ぶことは増えます。
        その手間と引き換えに、1 社の判断ですべてを失うおそれが減ります。
      ],
    )
  })),

  // ---- B: メタクソ化(図 2 列 + 文章 4 列) ----
  grid.cell(x: 0, y: 4, colspan: 3, fixed(45mm, {
    set text(size: fs.s)
    set par(spacing: 2mm)
    part("2", "メタクソ化はなぜ起きる？")
    grid(
      columns: (c2,) + (c1,) * 4,
      column-gutter: gut,
      fig-cap(fig-enshit)[Cory Doctorow の説明をもとに作図],
      col-text("central", [名前の由来])[
        使い始めたころは便利だったサービスが、だんだん広告だらけになり、見たい投稿も届かなくなっていきます。
        カナダの作家 Cory Doctorow は、こうしたプラットフォームの劣化を *enshittification* と名付けました。
        日本語では「メタクソ化」と訳されることがあり、米国方言学会の 2023 年の言葉にも選ばれました。
      ],
      col-text("central", [離れられないから進む])[
        劣化は左の 3 段階で進みます。どの段階でも劣化が進むのは、利用者も事業者も簡単には離れられないからです。
        利用者には友だちとのつながりが、事業者にはお客さんが、そこにあります。
      ],
      col-text("nostr", [求められる「出ていく自由」])[
        Doctorow が求めるのは *出ていく自由*（freedom of exit）、つまり、つながりとデータを保ったまま、サービスを離れられる権利です。
        分散型 SNS はこの自由をしくみに組み込もうとしています。
      ],
      col-text("nostr", [分散型でも起こりうる])[
        利用者が 1 つの大きなサーバーや AppView に集まれば、そこを運営する人も、利用者が離れにくいことを利用して、自分たちに都合のよい運営をするおそれがあります。
        違いは、そのときに別の場所へ移る道が残っているかどうかです。
      ],
    )
  })),

  // ---- C: SNS の歴史(全幅) ----
  grid.cell(x: 0, y: 6, colspan: 3, {
    block(width: 100%, below: 1mm, stroke: (top: rule), inset: (top: 2mm), {
      set par(first-line-indent: 0pt, justify: false)
      rule-mark
      place(std.top + right, dy: -2mm + 0.8mm, lbl("SURVEY AREA 03"))
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 4mm,
        align: horizon,
        part("3", "SNS はどう移り変わってきたか", width: auto, ruled: false),
        text(size: fs.xs, weight: 500, fill: luma(90))[2022 年の Twitter 買収のあと、利用者は別の SNS へ何度も移りました。本誌の年表（49 項目）から要点だけを抜き出しています。],
        legend,
      )
    })
    timeline-axis(396mm, 48mm)
  }),

  // ---- 右の帯(2 列): 読み方・数字・本誌案内 | 用語 ----
  // 面は塗らず、上の罫で区切る
  grid.cell(x: 2, y: 2, block(width: 100%, height: 100%, stroke: (top: rule), inset: (top: 3mm), {
    place(std.top + left, dy: -3mm - 0.6mm, rect(width: 12mm, height: 1.2mm, fill: ink, stroke: none))
    set text(size: fs.s)
    grid(
      columns: (1fr, 1fr),
      column-gutter: gut,
      {
        block(below: 4mm, {
          set par(first-line-indent: 0pt, justify: false, spacing: 2mm)
          text(size: fs.m, weight: 700)[この紙の読み方]
          parbreak()
          [*表面*：中央集権型と分散型の違い（1）、メタクソ化（2）、SNS の歴史（3）。]
          parbreak()
          [*裏面*：Nostr、Bluesky、ActivityPub を 3 列に並べ、同じ 4 つの問いで比べています。縦に読めば 1 つのしくみの全体を、横に読めば 3 つのしくみを同じ問いで比べられます。よく聞かれる質問も裏面にあります。]
        })
        block(below: 2mm, text(size: fs.m, weight: 700)[数字で見る])
        stat("bluesky", "4,600 万", [Bluesky の登録者数（2026 年 8 月）])
        stat("ap", "2018", [ActivityPub が W3C 勧告になった年（1 月）])
        stat("nostr", "2020", [fiatjaf が Nostr を公開した年（11 月）])
        column-box([もっと知りたい人へ])[
          この紙は四谷ラボの技術書典21 の新刊『未来を掴め！AIと分散型と楽しい仲間たち』の副読本です。
          本誌には詳しい年表のほか、オフラインで動く Nostr、Bluesky チームへの質問と回答、AT Protocol の上で作ったアプリの話などが載っています。
          四谷ラボの活動は https://428lab.net で紹介しています。
        ]
      },
      {
        block(below: 2mm, text(size: fs.m, weight: 700)[用語ミニ辞典])
        term("ap", "Fediverse")[ActivityPub などで連合するサーバー全体のこと。]
        term("ap", "連合")[サーバーどうしが投稿をやり取りすること。連合を切ると、そのサーバーの投稿が届かなくなる。]
        term("nostr", "npub / nsec")[Nostr の公開鍵（npub）と秘密鍵（nsec）を、人が扱いやすい文字列にしたもの。nsec は絶対に人に見せない。]
        term("nostr", "Zap")[Lightning Network を使った、Nostr の投げ銭。]
        term("bluesky", "PDS")[AT Protocol で、利用者のデータを置くサーバー。]
        term("bluesky", "DID")[分散型識別子。AT Protocol でアカウントを識別する ID。]
        term("bluesky", "AppView")[ネットワーク全体の更新の流れ（firehose）を受け取り、タイムラインや検索結果を組み立てるサーバー。]
        term("bluesky", "ATmosphere")[AT Protocol の上のアプリと利用者の集まり全体。]
      },
    )
  })),
)

// ============================================================
//  裏面: 3 つのしくみを 3 列に並べ、同じ 4 つの問いで比べる
// ============================================================

#pagebreak()

#let cw = 128mm  // 1 列の幅

// 列の頭: 名前と一言
// 列の頭: 路線のような色の線と、その起点の丸い点。名前と一言
#let col-head(key, name, tagline) = block(width: 100%, {
  let col = palette.at(key)
  box(width: 100%, height: 3mm, {
    place(left + horizon, line(length: 100%, stroke: 1.6pt + col))
    place(left + horizon, circle(radius: 1.5mm, fill: white, stroke: 1.6pt + col))
  })
  v(1mm)
  set par(first-line-indent: 0pt, justify: false)
  text(size: fs.xl, weight: 700, fill: col, features: ("palt",), name)
  h(2mm)
  text(size: fs.m, weight: 500, fill: luma(70), tagline)
})

// 思想の一文。引用なら引用符を付ける
#let idea(key, body, by, quote: true) = {
  let col = palette.at(key)
  block(width: 100%, height: 12mm, stroke: (left: 1.6pt + col), inset: (left: 3mm, y: 1mm), {
    set par(first-line-indent: 0pt, justify: false, leading: 0.5em)
    if quote { text(font: disp, size: fs.l, fill: col, "“"); h(1mm) }
    text(size: fs.m, weight: 700, body)
    linebreak()
    text(size: fs.xs, fill: luma(90), by)
  })
}

// 問いの行の見出し(3 列をまたぐ)
#let q-row(no, body, note: none) = grid.cell(colspan: 3, block(width: 100%, stroke: (bottom: rule), inset: (bottom: 1mm, top: 1mm), {
  set par(first-line-indent: 0pt, justify: false)
  if note != none { place(right + bottom, text(size: fs.xs, fill: luma(90), note)) }
  text(font: disp, size: fs.xl, fill: luma(150), no)
  h(2mm)
  text(size: fs.l, weight: 700, body)
}))

// 問いのマス: 色の太字の一言と、短い解説
#let cell(key, head, body) = block(width: 100%, {
  set text(size: fs.s)
  set par(first-line-indent: 0pt, justify: false, leading: 0.5em)
  text(size: fs.m, weight: 700, fill: palette.at(key).darken(15%), features: ("palt",), head)
  set par(justify: true, leading: 0.62em, spacing: 2mm)
  body
})

// 小さな図: 箱と矢印を横に並べる。steps は 箱, 矢印の言葉, 箱, … の順
#let mini-box(col, top-text, bottom-text, filled: false) = box(
  fill: if filled { col } else { white }, stroke: 0.8pt + col, radius: 1mm, inset: (x: 2mm, y: 1mm),
  {
    set par(first-line-indent: 0pt, justify: false, leading: 0.35em)
    set align(center)
    text(size: fs.s, weight: 700, fill: if filled { white } else { col.darken(20%) }, top-text)
    if bottom-text != none {
      linebreak()
      text(font: mono, size: fs.xs, fill: if filled { white } else { luma(60) }, bottom-text)
    }
  },
)
#let mini-arrow(label, dashed: false, back: false) = box(width: 100%, {
  set par(first-line-indent: 0pt, justify: false)
  set align(center)
  text(size: fs.xs, weight: 500, fill: luma(80), label)
  linebreak()
  box(width: 100%, height: 2.4mm, {
    let st = (paint: luma(110), thickness: 0.9pt, dash: if dashed { "dashed" } else { none })
    place(left + horizon, line(length: 100%, stroke: st))
    let tip = if back { place(left + horizon, polygon(fill: luma(110), (0mm, 0mm), (2.2mm, -1.1mm), (2.2mm, 1.1mm))) } else { place(right + horizon, polygon(fill: luma(110), (0mm, -1.1mm), (2.2mm, 0mm), (0mm, 1.1mm))) }
    tip
  })
})
// 3 列で高さがそろうよう、小さな図の段は高さを固定して上下中央にそろえる
#let mini-chain(..steps) = {
  let s = steps.pos()
  block(width: 100%, height: 10mm, align(horizon, grid(
    columns: s.enumerate().map(((i, _)) => if calc.rem(i, 2) == 0 { auto } else { 1fr }),
    column-gutter: 2mm,
    align: horizon,
    ..s,
  )))
}
// 図の下の一言。一言がない列も同じ高さを取り、本文の書き出しを 3 列でそろえる
#let mini-note(body) = block(width: 100%, height: 5mm, above: 1mm, below: 1mm, {
  set par(first-line-indent: 0pt, justify: false)
  set align(center)
  text(size: fs.s, weight: 500, fill: luma(80), body)
})

#let N = "nostr"
#let B = "bluesky"
#let A = "ap"
#let cn = palette.nostr
#let cb = palette.bluesky
#let ca = palette.ap

#grid(
  columns: (cw, cw, cw),
  column-gutter: 6mm,
  row-gutter: 2mm,

  // ---- 列の頭 ----
  col-head(N, "Nostr", [鍵と署名だけを信じる]),
  col-head(B, "Bluesky", [AT Protocol。データとアプリを分ける]),
  col-head(A, "ActivityPub", [サーバーどうしが投稿を送り合う]),

  // ---- しくみの図 ----
  align(center + horizon, scale(110%, reflow: true, fig-relay)),
  align(center + horizon, fig-pipeline),
  align(center + horizon, scale(110%, reflow: true, fig-federation)),

  // ---- 思想 ----
  idea(N, [検閲に強いグローバルな“ソーシャル”ネットワークを、今度こそ作れる、いちばん単純なオープンなプロトコル], [Nostr のリポジトリの説明から]),
  idea(B, [運営会社の方針が合わなくなっても、利用者は別の場所へ移れる], [AT Protocol の「信頼できる脱出（credible exit）」の考え方を要約], quote: false),
  idea(A, [メールのように、誰でもサーバーを立てて、ほかのサーバーとつながれる], [2018 年 1 月に W3C 勧告になった標準。3 つの中でいちばん早く広まった], quote: false),

  // ---- 1. しくみと思想 ----
  q-row("1", [どんなしくみか]),
  cell(N, [署名付きのイベントを、リレーが運ぶ])[
    2020 年 11 月に fiatjaf が公開しました。
    投稿もプロフィールも、共通の形式の JSON で書いた署名付きのデータ（*イベント*）です。
    種類は `kind` の番号で区別します（1 が短い投稿）。
    署名を確かめるのはクライアント（アプリ）なので、リレー（投稿を預かって配るサーバー）を信頼する必要はありません。
    「検閲に強い」とは、1 か所の判断で発言の場がまるごと消えない、という意味です。
  ],
  cell(B, [データを置く所と、組み立てる所を分ける])[
    2019 年 12 月に当時 Twitter の CEO だった Jack Dorsey が始めたプロジェクトから生まれ、2024 年 2 月から誰でも登録できます（2026 年 8 月に約 4,600 万人）。
    データの種類と形は *Lexicon* という定義で決め、誰でも新しい種類を作れます。
    ブログの WhiteWind や Leaflet なども同じアカウントで使え、この集まりを *ATmosphere* と呼びます。
  ],
  cell(A, [サーバーどうしが届け合う])[
    Mastodon（2016 年公開、2017 年 9 月に対応）や Misskey、Pixelfed、PeerTube などが ActivityPub に対応し、2023 年からは Meta の Threads も一部で対応を進めています。
    ActivityPub でつながるサーバー全体を *Fediverse*（フェディバース）と呼びます。
    1 つのサーバーで完結するので、小さなコミュニティを立てやすいのが強みです。
  ],

  // ---- 2. ID とデータ ----
  q-row("2", [ID とデータはどこにあるか], note: [塗りつぶした箱と点は、そのしくみで ID がある所（裏面の図も同じ）]),
  cell(N, [ID は公開鍵])[
    #mini-chain(mini-box(cn, [秘密鍵], "nsec1…"), mini-arrow([署名]), mini-box(cn, [イベント], none), mini-arrow([署名を確かめる]), mini-box(cn, [公開鍵 = ID], "npub1…", filled: true))
    #mini-note[パスワードもメールアドレスもいらない]
    アカウントを作ることは、鍵のペアを作ることと同じです。
    どのサーバーにも登録しないので、あるリレーに締め出されても ID は手元に残ります。
    投稿は、利用者が選んだいくつものリレーに置かれます。
  ],
  cell(B, [ID は DID、データは PDS])[
    #mini-chain(mini-box(cb, [ハンドル], "@example.com"), mini-arrow([DNS などで調べる]), mini-box(cb, [DID = ID], "did:plc:…", filled: true), mini-arrow([置き場所]), mini-box(cb, [PDS], none))
    #mini-note[ハンドルは付け替えられる。DID は変わらない]
    投稿やいいねは、利用者ごとの *リポジトリ* に署名付きで記録され、PDS に置かれます。
    `did:plc` の DID を登録するサーバー（PLC Directory）はいまも Bluesky 社が運営し、スイスの独立した団体（PLC Organization）が引き継ぎを準備しています。
  ],
  cell(A, [ID も投稿もサーバーが管理する])[
    #mini-chain(mini-box(ca, [ユーザー名], "@user"), mini-arrow([＋]), mini-box(ca, [サーバー名], "@mstdn.jp", filled: true))
    #mini-note[メールアドレスと同じく、ID にサーバーの名前が入る]
    投稿はそのサーバーのデータベースに入り、フォロワーのいるサーバーにも複製されます。
    ID を管理しているのは、サーバーの管理者です。
  ],

  // ---- 3. 届け方と並べ方 ----
  q-row("3", [どう届き、誰が並べて、誰が止めるか]),
  cell(N, [書く人が置き、読む人が取りに行く])[
    #mini-chain(mini-box(cn, [書く人], none), mini-arrow([置く]), mini-box(cn, [リレー], "×いくつも"), mini-arrow([取りに行く], back: true), mini-box(cn, [読む人], none))
    クライアントとリレーは、投稿を送る `EVENT` や購読する `REQ` などの短い命令だけを WebSocket でやり取りし、リレーどうしは原則として通信しません。
    どこに書き、どこから読み、どう並べるかはクライアントが決めます。
    受け入れる投稿はリレーごとに決め、何を見ないかは利用者が決めます。
    仕様は誰でも *NIP* という文書で提案でき、Zap（NIP-57）のような拡張もあります。
  ],
  cell(B, [リレーが集め、AppView が並べる])[
    #mini-chain(mini-box(cb, [Bluesky 社の\ 基本の方針], none), mini-arrow([＋]), mini-box(cb, [選んだラベラー], none), mini-arrow([判定を加える]), mini-box(cb, [見える投稿], none))
    リレーが PDS から更新を集めて 1 本の流れ（firehose）にし、AppView がタイムラインや検索を組み立てます。
    並べ方は *フィードジェネレーター*、ラベル付けは *ラベラー* が受け持ち、どちらも誰でも作れて利用者が選べます。
    モデレーションは Bluesky 社の基本の方針に、利用者が選んだラベラーの判定を加える形です。
  ],
  cell(A, [サーバーが届け、サーバーが並べる])[
    #mini-chain(mini-box(ca, [書いた人の\ サーバー], none), mini-arrow([送り届ける]), mini-box(ca, [フォロワーの\ サーバー], none), mini-arrow([並べる]), mini-box(ca, [タイムライン], none))
    投稿は書いた人のサーバーから、フォロワーのいるサーバーへ送り届けられます（プッシュ）。
    Mastodon などでは、保存、タイムラインの組み立て、モデレーションをサーバーの管理者が受け持ちます。
    迷惑な投稿が多いサーバーとの連合を切るかどうかも、その管理者が決めます。
  ],

  // ---- 4. 引っ越しと始め方 ----
  q-row("4", [引っ越し、苦手なこと、始め方]),
  cell(N, [鍵があれば、どこでも同じ ID])[
    #mini-chain(mini-box(cn, [リレー A], none), mini-arrow([移る], dashed: true), mini-box(cn, [リレー B], none))
    #mini-note[鍵が同じなら ID も同じ]
    そのかわり、秘密鍵は再発行できません。なくせば二度と投稿できず、漏れれば誰でもなりすませます。
    削除も「消してほしい」と頼むイベント（NIP-09）を送るだけです。

    *始め方*：https://welcome.nostr-jp.org/ に、クライアントの選び方と鍵の作り方があります。
  ],
  cell(B, [DID が同じなら、フォロワーもそのまま])[
    #mini-chain(mini-box(cb, [PDS A], none), mini-arrow([移る], dashed: true), mini-box(cb, [PDS B], none))
    #mini-note[DID が同じなら ID もフォロワーも同じ]
    苦手なのは、ネットワーク全体を扱うリレーと AppView の処理の負担が大きく、そのため多くの利用者が Bluesky 社のものに頼っている点です。
    2026 年 3 月には IETF で中核部分の標準化が始まりました。

    *始め方*：https://bsky.app かアプリストアの公式アプリで登録できます。
  ],
  cell(A, [フォロワーは移せる。ID と過去の投稿は移らない])[
    #mini-chain(mini-box(ca, [サーバー A], "@me@a.example"), mini-arrow([移る（Mastodon）], dashed: true), mini-box(ca, [サーバー B], "@me@b.example"))
    #mini-note[フォロワーは移る。ID は変わり、過去の投稿は移らない]
    管理者がサーバーを閉じれば、そこにあるアカウントもいっしょに消えます。

    *始め方*：まず入るサーバーを選びます。一覧は https://joinmastodon.org と https://misskey-hub.net にあります。
  ],

  // ---- 下段: 同じ「リレー」の注意と、よく聞かれること ----
  grid.cell(colspan: 3, block(width: 100%, above: 2mm, stroke: (top: rule), inset: (top: 3mm), {
    set text(size: fs.s)
    set par(first-line-indent: 0pt, justify: true, leading: 0.55em)
    let faq(qq, aa) = block(width: 100%, height: 22mm, {
      text(size: fs.m, weight: 700, qq)
      v(2mm)
      aa
    })
    grid(
      columns: (1fr,) * 5,
      column-gutter: 4mm,
      block(width: 100%, height: 22mm, {
        text(size: fs.m, weight: 700)[Nostr と AT Protocol の「リレー」の違い]
        v(2mm)
        [Nostr と AT Protocol には、どちらにも *リレー* という部品があります。 Nostr のリレーは、クライアントから投稿を受け取って預かり、求めに応じて返すサーバーです。 AT Protocol のリレーは、たくさんの PDS から更新を集め、1 本の流れにして配るサーバーです。]
      }),
      faq([鍵アカウント（フォロワー限定の公開）はある？], [Mastodon と Misskey には、フォロワーだけに見せる公開範囲があります。Nostr と Bluesky の投稿は基本的に誰でも読めます。Bluesky では、見られる人を限れるしくみ（Atproto Spaces）の試作が始まったところです。]),
      faq([DM は？], [3 つともあります。Nostr の DM は、中身を暗号化して送るしくみ（NIP-17）です。Bluesky の DM は AT Protocol には含まれない、Bluesky 社のサービスです。]),
      faq([消した投稿は消える？], [ActivityPub は、削除をほかのサーバーに知らせます。Nostr は削除の依頼を送るだけで、従うかはリレーしだいです。Bluesky は PDS から消え、AppView にも反映されます。どのしくみでも、誰かが先に保存した写しまでは消せません。]),
      faq([どれから始めればいい？], [知り合いがいるしくみから始めると、最初のタイムラインがさびしくなりません。どのしくみにも、アカウントを無料で作れるサービスが多くあるので、並べて使っている人もいます。]),
    )
  })),
)
