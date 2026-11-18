// ============================================================
//  背景「惑星の地形測量図」
//  紙全体を、探査機が測った未知の地形の図に見立てる。
//  山が 1 つではなくいくつも並ぶ地形(= 分散)を、ノートのような薄い点の方眼で表す。
//  点は 5mm 間隔で、土地が高い所ほど少し大きく濃くなる(網点で描いた地形)。
//  線は紙の縁の目盛りだけにして、本文の邪魔をしない。色は使わない
// ============================================================
#import "theme.typ": *

#let W = 420mm
#let H = 297mm
#let lbl(body, fill: luma(110), size: 4.6pt) = text(font: mono, size: size, fill: fill, tracking: 0.05em, body)

// 山の位置(x, y は mm、高さ、広がり mm)
#let peaks = (
  front: ((252, 28, 1.0, 40), (92, 118, 0.55, 34), (176, 205, 0.5, 30), (335, 150, 0.7, 38),
          (52, 252, 0.4, 24), (385, 262, 0.5, 28), (262, 112, 0.32, 20), (130, 30, 0.3, 26)),
  back: ((78, 62, 0.7, 36), (212, 74, 0.8, 40), (346, 60, 0.7, 36), (140, 205, 0.5, 40),
         (292, 215, 0.55, 34), (36, 268, 0.3, 24), (404, 176, 0.32, 24)),
  // 頒布ページの見本画像(A4 縦、sample.typ)
  cover: ((150, 40, 0.9, 38), (48, 150, 0.5, 30), (170, 228, 0.6, 34), (70, 272, 0.35, 22)),
  last: ((60, 50, 0.6, 34), (175, 130, 0.5, 30), (40, 250, 0.45, 30), (160, 270, 0.4, 24)),
)

// 高さの場。山(ガウス関数)の和に、ゆるい波を足す
#let height(sheet, x, y) = {
  let v = 0.0
  for (px, py, a, s) in peaks.at(sheet) {
    v += a * calc.exp(-((x - px) * (x - px) + (y - py) * (y - py)) / (2 * s * s))
  }
  v + 0.05 * calc.sin(x / 31 + 1.3) * calc.cos(y / 23 + 0.4) + 0.03 * calc.sin((x + y) / 17)
}

// 原寸で印刷すると紙の外周 5mm は刷れないので、飾りはすべて外周から safe の内側に置く
#let safe = 6mm

// 点の方眼。高さに応じて半径 0.16〜0.5mm、濃さ luma 212〜165。外周 10mm より内側だけに打つ
#let dot-field(sheet, pitch: 5, w: 420, h: 297) = {
  for j in range(2, int(h / pitch) - 1) {
    for i in range(2, int(w / pitch) - 1) {
      let (x, y) = (i * pitch, j * pitch)
      let t = calc.clamp(height(sheet, x, y), 0, 1)
      let r = (0.16 + 0.34 * t) * 1mm
      place(dx: x * 1mm - r, dy: y * 1mm - r, circle(radius: r, fill: luma(int(212 - 47 * t)), stroke: none))
    }
  }
}

// 縁の目盛り。外周 safe の線から内側へ、10mm ごとに短い目盛り、50mm ごとに長い目盛りと座標(横 E、縦 N)
#let survey-frame(sheet-name, W: W, H: H, right-gap: 52mm) = {
  let st = 0.4pt + luma(130)
  let o = safe
  let nx = int(W / 10mm)
  let ny = int(H / 10mm)
  for k in range(1, nx) {
    let x = k * 10mm
    let long = calc.rem(k, 5) == 0
    let l = if long { 3mm } else { 1.5mm }
    place(dx: x, dy: o, line(length: l, angle: 90deg, stroke: st))
    place(dx: x, dy: H - o - l, line(length: l, angle: 90deg, stroke: st))
    if long and k < nx - 2 { place(dx: x + 0.8mm, dy: o + 0.4mm, lbl("E" + str(k * 10))) }
  }
  for k in range(1, ny + 1) {
    let y = k * 10mm
    let long = calc.rem(k, 5) == 0
    let l = if long { 3mm } else { 1.5mm }
    place(dx: o, dy: y, line(length: l, stroke: st))
    place(dx: W - o - l, dy: y, line(length: l, stroke: st))
    // 縦の座標は 90 度回して、本文の左端(12mm)にかからないようにする
    if long { place(dx: o + 0.4mm, dy: y + 1mm, rotate(90deg, origin: top + left, reflow: true, lbl("N" + str(k * 10)))) }
  }
  // 下の縁の注記(右寄せ。ロゴの左に置く)
  place(dx: W - right-gap - 160mm, dy: H - 9.6mm, box(width: 160mm, align(right, lbl(sheet-name))))
}

// 縮尺の棒(下の余白、左)。白と墨を交互に
#let scale-bar(x, y) = {
  for k in range(5) {
    place(dx: x + k * 8mm, dy: y, rect(width: 8mm, height: 1.2mm, fill: if calc.rem(k, 2) == 0 { ink } else { white }, stroke: 0.4pt + ink))
  }
  place(dx: x + 42mm, dy: y - 0.6mm, lbl("DOT SURVEY · NO SINGLE PEAK"))
}
