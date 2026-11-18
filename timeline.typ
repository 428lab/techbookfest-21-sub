// 年表。本誌の年表から要点だけを抜き出した timeline-digest.yaml を使う
#import "theme.typ": *

#let tl = yaml("timeline-digest.yaml")

// 4 色。Misskey は ActivityPub の色、「日本」は色でなく JP のラベルで示す
#let tag-color(t) = (
  central: palette.central,
  ap: palette.ap,
  bsky: palette.bluesky,
  nostr: palette.nostr,
).at(t, default: luma(120))
#let jp = box(inset: (x: 0.6mm, y: 0.2mm), stroke: 0.4pt + luma(90), text(font: mono, size: 4.8pt, weight: 700, fill: luma(60), "JP"))

#let event(ev) = block(width: 100%, above: 0pt, below: 1.5mm, breakable: false, {
  set par(first-line-indent: 0pt, justify: false, leading: 0.4em, hanging-indent: 13mm)
  let col = tag-color(ev.tags.first())
  box(baseline: -0.1em, circle(radius: 1mm, fill: col, stroke: none))
  h(1mm)
  box(width: 10.5mm, text(font: mono, size: 6pt, weight: 700, fill: col.darken(15%), ev.date))
  text(size: 6.7pt, weight: 700, ev.title)
  if "japan" in ev.tags { h(1mm); jp }
})

#let era-head(e) = block(width: 100%, above: 1.5mm, below: 1.6mm, sticky: true, {
  set par(first-line-indent: 0pt, justify: false, leading: 0.3em)
  text(font: disp, size: 15pt, fill: luma(185), e.span)
  h(1.5mm)
  text(size: 7.2pt, weight: 900, features: ("palt",), e.title)
})

#let legend = {
  let items = (("central", "中央集権SNS"), ("ap", "ActivityPub・Misskey"), ("bsky", "Bluesky"), ("nostr", "Nostr"))
  set text(size: 6pt, weight: 500)
  items.map(((k, l)) => box(baseline: -0.1em, circle(radius: 1mm, fill: tag-color(k), stroke: none)) + h(0.8mm) + l).join(h(2.5mm))
  h(2.5mm)
  jp
  h(0.8mm)
  [日本]
}

// n 段・高さ h で組む
#let timeline(n, h) = block(width: 100%, height: h, columns(n, gutter: 4.5mm, {
  for e in tl.eras {
    era-head(e)
    for ev in e.events { event(ev) }
  }
}))

// 横軸の年表。22 項目を等間隔に並べ、ラベルを軸の上下に交互に出す。時代の始まりの軸の上に西暦
#let timeline-axis(w, hh) = block(width: w, height: hh, {
  let items = tl.eras.enumerate().map(((k, e)) => e.events.enumerate().map(((i, ev)) => (era: k, first: i == 0, ev: ev))).flatten()
  let n = items.len()
  let ox = 12mm
  let step = (w - ox - 24mm) / n  // 右端のラベルが面に収まるよう、右に 24mm 残す
  let ay = hh / 2
  place(top + left, dy: ay, line(length: w, stroke: 1.2pt + luma(190)))
  for (i, it) in items.enumerate() {
    let x = ox + step * (i + 0.5)
    let col = tag-color(it.ev.tags.first())
    let up = calc.rem(i, 2) == 0
    if it.first {
      let e = tl.eras.at(it.era)
      let bx = if i == 0 { 0mm } else { x - step / 2 - 6mm }
      place(top + left, dx: bx, dy: ay - 3.2mm, box(width: 12mm, height: 6.4mm, fill: white, align(center + horizon, text(font: disp, size: 13pt, fill: luma(150), e.span))))
    }
    place(top + left, dx: x - 1.2mm, dy: ay - 1.2mm, circle(radius: 1.2mm, fill: col, stroke: 0.8pt + white))
    let tick = 3.5mm
    place(top + left, dx: x, dy: if up { ay - tick - 1.2mm } else { ay + 1.2mm }, line(length: tick, angle: 90deg, stroke: 0.5pt + col.lighten(30%)))
    let lw = step * 2 - 2mm
    let label = {
      set par(first-line-indent: 0pt, justify: false, leading: 0.38em)
      if "big" in it.ev {
        text(font: disp, size: 15pt, fill: col, it.ev.big)
        h(1mm)
        text(size: 5.6pt, weight: 700, fill: col, it.ev.big-note)
        linebreak()
      }
      text(font: mono, size: 6.2pt, weight: 700, fill: col.darken(15%), it.ev.date)
      if "japan" in it.ev.tags { h(0.8mm); jp }
      linebreak()
      text(size: 6.8pt, weight: 700, it.ev.title)
    }
    let lx = x - 1mm
    if up {
      place(bottom + left, dx: lx, dy: -(hh - ay + tick + 2mm), box(width: lw, label))
    } else {
      place(top + left, dx: lx, dy: ay + tick + 2mm, box(width: lw, label))
    }
  }
})
