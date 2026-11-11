// Native CeTZ renderer for preserved vector outlines. No SVG/image embedding.
#import "/.shared/packages/cetz/0.5.3/src/lib.typ" as cetz

#let vector-diagram(path) = {
  let data = json(path)
  let paint(value, opacity) = if value == "none" { none } else { rgb(value).transparentize((1 - opacity) * 100%) }
  let paths(items) = {
    import cetz.draw: *
    for item in items {
      if "items" in item {
        if item.clip.len() > 0 and item.items.len() > 0 {
          clip(paths(item.clip), paths(item.items))
        }
      } else {
        let pen = if item.stroke == "none" { none } else {
          (paint: paint(item.stroke, item.at("stroke-opacity")), thickness: item.width * 1pt,
            cap: item.cap, join: item.join,
            dash: if item.dash.len() == 0 { "solid" } else { item.dash.map(x => x * 1pt) })
        }
        // Coordinates are already resolved by the importer. Use CeTZ's native
        // drawable API to avoid re-resolving thousands of glyph control points.
        (ctx => (ctx: ctx, drawables: (cetz.drawable.path(item.paths,
          fill: paint(item.fill, item.at("fill-opacity")), stroke: pen, fill-rule: item.rule),)),)
      }
    }
  }
  layout(size => {
    let factor = calc.min(1.0, size.width / (data.width * 1pt), 105mm / (data.height * 1pt))
    align(center, scale(x: factor * 100%, y: factor * 100%, reflow: true,
      cetz.canvas(length: 1pt, {
        cetz.draw.rect((0,0), (data.width, data.height), stroke: none, fill: none)
        paths(data.items)
      })
    ))
  })
}
