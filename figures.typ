// 図。表面の考え方の図と、裏面のしくみの図
#import "theme.typ": *

#let W = 60mm
#let H = 44mm

#let user(x, y, r: 2.2mm, col: luma(120), fill: white, label: none, label-fill: black) = (
  x: x, y: y, r: r, fill: fill, stroke: col, label: label, label-fill: label-fill, size: 5pt,
)
#let boxn(x, y, w, h, label, col, filled: false) = (
  x: x, y: y, w: w, h: h, shape: "rect",
  fill: if filled { col } else { tint(col) }, stroke: col, label: label,
  label-fill: if filled { white } else { col.darken(25%) },
)

#let WW = 124.5mm

// 2. 連合型: サーバーどうしが投稿を送り合う
#let fig-federation = {
  let c = palette.ap
  let servers = ((14mm, 13mm), (46mm, 13mm), (30mm, 35mm))
  let nodes = servers.enumerate().map(((i, p)) => (x: p.at(0), y: p.at(1), r: 5.5mm, fill: c, stroke: c, label: ("A", "B", "C").at(i), label-fill: white, size: 7pt))
  let edges = ((0, 1, c, 1.4pt), (1, 2, c, 1.4pt), (2, 0, c, 1.4pt))
  let offs = (
    ((-9mm, -5mm), (-10mm, 5mm), (-2mm, -10mm)),
    ((9mm, -5mm), (10mm, 5mm), (2mm, -10mm)),
    ((-11mm, 4mm), (11mm, 4mm), (0mm, 10mm)),
  )
  for (i, p) in servers.enumerate() {
    for o in offs.at(i) {
      nodes.push(user(p.at(0) + o.at(0), p.at(1) + o.at(1), col: c.lighten(20%)))
      edges.push((i, nodes.len() - 1, c.lighten(45%), 0.6pt))
    }
  }
  diagram(W, H, nodes, edges)
}

// 3. リレー型: 鍵を持つ利用者が、いくつものリレーに同じ投稿を置く
#let fig-relay = {
  let c = palette.nostr
  let nodes = (10mm, 30mm, 50mm).map(x => boxn(x, 9mm, 15mm, 6.5mm, "リレー", c))
  let xs = (6mm, 18mm, 30mm, 42mm, 54mm)
  for x in xs { nodes.push(user(x, 36mm, r: 3.4mm, col: c, fill: c, label: "鍵", label-fill: white)) }
  let links = ((0, 1), (0, 2), (1, 2), (0, 1, 2), (1, 2))
  let edges = ()
  for (u, rs) in links.enumerate() {
    for r in rs { edges.push((3 + u, r, c.lighten(35%), 0.7pt)) }
  }
  diagram(W, H, nodes, edges)
}

// 図 3: データとアプリの分離。PDS → リレー → AppView など → アプリ、と左から右へ流れる
#let fig-pipeline = {
  let c = palette.bluesky
  let h = 40mm
  let nodes = ()
  let edges = ()
  for (i, y) in (11mm, 21mm, 31mm).enumerate() {
    nodes.push(boxn(17mm, y, 16mm, 6mm, "PDS", c, filled: true))
  }
  nodes.push(boxn(50mm, 21mm, 20mm, 8mm, "リレー", c))  // 3
  for (i, (y, l)) in ((11mm, "AppView"), (21mm, "フィード"), (31mm, "ラベラー")).enumerate() {
    nodes.push(boxn(83mm, y, 20mm, 6mm, l, c))  // 4, 5, 6
  }
  nodes.push(boxn(113mm, 21mm, 19mm, 14mm, "アプリ", c))  // 7
  for i in range(3) { edges.push((i, 3, c, 0.9pt)) }
  for i in range(3) { edges.push((3, 4 + i, c, 0.9pt)) }
  for i in range(3) { edges.push((4 + i, 7, c.lighten(40%), 0.9pt)) }
  for (i, y) in (11mm, 21mm, 31mm).enumerate() {
    nodes.push(user(4mm, y, r: 1.8mm, col: c.lighten(20%)))
    edges.push((nodes.len() - 1, i, c.lighten(45%), 0.6pt))
  }
  box(width: WW, height: h, {
    diagram(WW, h, nodes, edges)
    let lbl(x, w, t) = tag(x, 0mm, text(weight: 700, fill: c.darken(20%), t), w: w, al: center)
    lbl(0mm, 26mm, [利用者のデータ])
    lbl(37mm, 26mm, [集めて流す])
    lbl(70mm, 26mm, [組み立てる])
    lbl(101mm, 24mm, [見せる])
    tag(0mm, 36mm, [利用者ごと。移っても DID は同じ], w: 34mm, al: center, size: 5.2pt)
    tag(33mm, 36mm, [firehose], w: 34mm, al: center, size: 5.2pt)
    tag(66mm, 36mm, [誰でも作れる。利用者が選ぶ], w: 34mm, al: center, size: 5.2pt)
    tag(97mm, 36mm, [Bluesky など], w: 32mm, al: center, size: 5.2pt)
  })
}

// ------------------------------------------------------------
//  表面: 考え方の図。幅は 2 列ぶん(128mm)
// ------------------------------------------------------------

#let FW = 128mm

// 角の丸い箱に中央そろえの文字
#let fbox(x, y, w, h, body, fill: white, stroke: 1.2pt + ink) = place(dx: x, dy: y,
  rect(width: w, height: h, radius: 1mm, inset: 0pt, fill: fill, stroke: stroke,
    align(center + horizon, { set par(justify: false, leading: 0.4em, spacing: 0.4em); body })))
#let user-dot(cx, cy, col) = place(dx: cx - 2.2mm, dy: cy - 2.2mm, circle(radius: 2.2mm, fill: white, stroke: 1.2pt + col))
#let arrow-r(x1, x2, y, col: ink) = {
  place(line(start: (x1, y), end: (x2 - 1.8mm, y), stroke: 1.4pt + col))
  place(polygon(fill: col, (x2 - 2.2mm, y - 1.3mm), (x2, y), (x2 - 2.2mm, y + 1.3mm)))
}

// 中央集権型: 1 社の箱に 4 つの要素が入り、利用者が全員そこにつながる
#let fig-central = box(width: FW, height: 33mm, {
  let g = palette.central
  let ux(i) = 8mm + i * 14mm
  for i in range(9) { place(line(start: (ux(i), 27.8mm), end: (64mm, 21mm), stroke: 0.9pt + luma(90))) }
  fbox(26mm, 1mm, 76mm, 20mm, none, fill: luma(232), stroke: 1.4pt + ink)
  place(dx: 26mm, dy: 2.6mm, box(width: 76mm, align(center, text(size: 7.4pt, weight: 700)[運営会社 1 社])))
  for (i, l) in ("ID", "データ", "並べ方", "ルール").enumerate() {
    fbox(29mm + i * 17.8mm, 9.5mm, 16mm, 8mm, text(size: 7.4pt, weight: 700, l), stroke: 1pt + ink)
  }
  for i in range(9) { user-dot(ux(i), 30mm, ink) }
})

// 分散型: 4 つの要素が別々の担い手に分かれ、利用者が選んでつなぐ
#let fig-distributed = box(width: FW, height: 33mm, {
  let parts = (
    ("ID", [鍵や DID を自分で持つ], ink),
    ("データ", [サーバー、リレー、PDS], ink),
    ("並べ方", [アプリやフィードを選ぶ], ink),
    ("ルール", [管理者、ラベラー、自分], ink),
  )
  let bx(j) = j * 33mm
  // 利用者はそれぞれ、4 つの要素の担い手を別々に選んでつなぐ
  let ux(i) = 8mm + i * 16mm
  for i in range(8) {
    for j in range(4) { place(line(start: (ux(i), 27.8mm), end: (bx(j) + 14.5mm, 15mm), stroke: 0.7pt + luma(110))) }
  }
  for (j, (l, note, c)) in parts.enumerate() {
    fbox(bx(j), 1mm, 29mm, 14mm, {
      text(size: 7.4pt, weight: 700, l)
      parbreak()
      text(size: 6.2pt, note)
    }, fill: white, stroke: 1.4pt + c)
  }
  for i in range(8) { user-dot(ux(i), 30mm, ink) }
})

// メタクソ化の 3 段階
#let fig-enshit = box(width: FW, height: 28.5mm, {
  let steps = (
    ("1", [利用者を優先する], [便利で無料のサービスで\ 人を集める], white),
    ("2", [事業者を優先する], [利用者向けの質を下げ、\ 広告主などを優先する], luma(236)),
    ("3", [自社と株主を優先する], [事業者から得る利益を\ 増やし、株主に回す], luma(214)),
  )
  // 段が進むほど灰色が濃くなる
  for (i, (n, t, b, f)) in steps.enumerate() {
    let x = i * 33mm
    fbox(x, 1mm, 29mm, 27mm, {
      text(font: disp, size: 17pt, n)
      parbreak()
      text(size: 7.4pt, weight: 700, t)
      parbreak()
      text(size: 6.2pt, b)
    }, fill: f, stroke: 1.4pt + ink)
    arrow-r(x + 29.6mm, x + 32.6mm, 14.5mm)
  }
  place(dx: 99.5mm, dy: 2mm, circle(radius: 12.5mm, inset: 0pt, fill: luma(80), stroke: none,
    align(center + horizon, text(size: 7.4pt, weight: 700, fill: white)[誰にとっても\ 使いにくい\ 場所に])))
})

// 図のキャプション。図の下に 1 行
#let fig-cap(body, caption) = block(width: 100%, breakable: false, {
  body
  v(0.5mm)
  text(size: 6.2pt, fill: luma(100), caption)
})
