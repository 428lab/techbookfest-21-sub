// ============================================================
//  技術書典21 無料配布シートの部品
//
//  顔つきは「技術誌の特集ページ」。ゴシックの見出し、色の面、大きな数字で組む。
//  罫線は表と図のキャプションにだけ残す。
//
//  フォント(すべて OFL。fonts/ に同梱。ビルドは --font-path fonts)
//    本文・見出し : Noto Sans CJK JP(Regular / Medium / Bold / Black)
//    大きな数字   : Anton
//    等幅         : IBM Plex Mono(日付・コード)
// ============================================================

#let body-font = ("Noto Sans CJK JP",)
#let disp = ("Anton", "Noto Sans CJK JP")
#let mono = ("IBM Plex Mono", "Noto Sans CJK JP")

// ---- 色 ----
// 墨と、3 つのしくみの色。Nostr と Bluesky は本誌と同じ色
#let ink = rgb("#1d1d1b")
#let palette = (
  common: ink,
  nostr: rgb("#8e30eb"),
  bluesky: rgb("#0a7aff"),
  ap: rgb("#e8590c"),
  central: luma(115),
)
#let tint(col) = col.lighten(90%)
#let hair = 0.3pt + luma(170)
#let rule = 0.6pt + ink

// ---- 文字の大きさと太さ ----
// 大きさは 6 段だけ使う。太さは 400(本文)、500(リード)、700(見出し)の 3 段
#let fs = (xs: 6.2pt, s: 7.4pt, m: 8.6pt, l: 11pt, xl: 17pt, xxl: 34pt)

// この紙の印: 路線図の駅のような丸い点。色が意味を持つ所(しくみの区別)にだけ付ける
#let dot(col, r: 0.9mm) = box(baseline: -0.15em, circle(radius: r, fill: col, stroke: none))

// ------------------------------------------------------------
//  見出し
// ------------------------------------------------------------

// ページの頭の見出し: 色の正方形、Anton の番号、太い題、1 行のリード
#let sec-head(key, no, title, lead) = {
  let col = palette.at(key)
  block(width: 100%, {
    set par(first-line-indent: 0pt, justify: false, leading: 0.45em)
    grid(
      columns: (auto, auto, 1fr),
      column-gutter: (2.5mm, 3mm),
      align: (horizon, horizon, horizon),
      rect(width: 5mm, height: 5mm, fill: col, stroke: none),
      text(font: disp, size: 24pt, fill: col, no),
      text(size: 19pt, weight: 700, features: ("palt",), tracking: -0.015em, title),
    )
    v(1.2mm)
    text(size: 8.4pt, weight: 700, fill: luma(90), lead)
  })
}

// 段の中に置く見出し
#let sec(key, no, title) = {
  let col = palette.at(key)
  block(width: 100%, above: 1.5em, below: 0.9em, sticky: true, {
    set par(first-line-indent: 0pt, justify: false, leading: 0.4em)
    grid(
      columns: (auto, auto, 1fr),
      column-gutter: (2mm, 2mm),
      align: horizon,
      rect(width: 3.6mm, height: 3.6mm, fill: col, stroke: none),
      text(font: disp, size: 15pt, fill: col, no),
      text(size: 12.5pt, weight: 700, features: ("palt",), title),
    )
  })
}

// 小見出し: 色の小さな四角と太字
// 小見出し: 太字だけ。飾りの印は付けない
#let sub(key, body) = block(above: 3mm, below: 1mm, sticky: true, {
  set par(first-line-indent: 0pt, justify: false, leading: 0.4em)
  text(size: fs.m, weight: 700, body)
})

// 囲み(NOTE・コラム)。薄い色の面だけで、枠線は引かない
#let column-box(title, key: "common", label: "COLUMN", body) = {
  let col = palette.at(key)
  block(width: 100%, breakable: false, above: 4mm, below: 3mm, stroke: (top: rule), inset: (top: 2mm), {
    block(below: 1mm, width: 100%, {
      set par(first-line-indent: 0pt, leading: 0.4em, justify: false)
      text(size: fs.m, weight: 700, title)
    })
    body
  })
}

// 引用。左に色の線、頭に大きな引用符
#let pull(key, body, by) = {
  let col = palette.at(key)
  block(width: 100%, breakable: false, above: 1.3em, below: 1.3em, stroke: (left: 3pt + col), inset: (left: 3.5mm, y: 1mm), {
    set par(first-line-indent: 0pt, justify: false, leading: 0.5em)
    text(font: disp, size: 22pt, fill: col, "“")
    v(-4mm)
    text(size: 9.4pt, weight: 700, body)
    v(1mm)
    text(size: 6.4pt, fill: luma(90), by)
  })
}

// 大きな数字のタイル
#let stat(key, num, body) = {
  let col = palette.at(key)
  block(width: 100%, breakable: false, above: 0mm, below: 0mm, stroke: (top: hair), inset: (y: 2mm), {
    set par(first-line-indent: 0pt, justify: false, leading: 0.45em)
    grid(columns: (24mm, 1fr), column-gutter: 2mm, align: horizon,
      text(font: disp, size: fs.xl, num),
      text(size: fs.xs, body),
    )
  })
}

// 用語やよく聞かれる質問の 1 項目
#let term(key, word, body) = block(above: 2mm, below: 2mm, {
  set par(first-line-indent: 0pt, hanging-indent: 3mm)
  dot(palette.at(key))
  h(1mm)
  text(weight: 700, word)
  h(0.6em)
  body
})

// ------------------------------------------------------------
//  しくみの図
// ------------------------------------------------------------

// ノードとエッジの図。座標は図の左上からの長さ。
// nodes: (x, y, r, fill, stroke, label, label-fill, shape: "circle" | "rect", w, h)
// edges: (from-index, to-index, color, thickness, dash)
#let diagram(w, h, nodes, edges) = box(width: w, height: h, {
  for e in edges {
    let a = nodes.at(e.at(0))
    let b = nodes.at(e.at(1))
    place(line(start: (a.x, a.y), end: (b.x, b.y), stroke: (paint: e.at(2), thickness: e.at(3), dash: e.at(4, default: none))))
  }
  for n in nodes {
    let shape = n.at("shape", default: "circle")
    if shape == "circle" {
      place(dx: n.x - n.r, dy: n.y - n.r, circle(radius: n.r, fill: n.fill, stroke: 0.8pt + n.stroke))
    } else {
      place(dx: n.x - n.w / 2, dy: n.y - n.h / 2, rect(width: n.w, height: n.h, radius: 0.8mm, fill: n.fill, stroke: 0.8pt + n.stroke))
    }
    if n.at("label", default: none) != none {
      place(dx: n.x - 15mm, dy: n.y - 2.5mm, box(width: 30mm, height: 5mm, align(center + horizon,
        text(size: n.at("size", default: 5.6pt), weight: 700, fill: n.at("label-fill", default: black), n.label))))
    }
  }
})

// 図の中に置く注記
#let tag(x, y, body, col: luma(90), size: 5.6pt, w: 30mm, al: left) = place(top + left, dx: x, dy: y, box(width: w, align(al, text(size: size, fill: col, body))))
