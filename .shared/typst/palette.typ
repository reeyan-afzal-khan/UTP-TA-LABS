// The one UTP palette, the same sixteen colours the LaTeX books defined in
// style/theme.tex. Every book, box, diagram and chart uses these names.
#let navy = rgb("18324A")
#let blue = rgb("246B9E")
#let teal = rgb("138A80")
#let green = rgb("2D7D46")
#let orange = rgb("C86B24")
#let red = rgb("B34843")
#let purple = rgb("6B4FA0")
#let gold = rgb("D4A13E")
#let ink = rgb("263238")
#let muted = rgb("60717C")
#let pale-blue = rgb("EEF6FB")
#let pale-teal = rgb("EEF8F6")
#let pale-orange = rgb("FFF5EA")
#let pale-red = rgb("FFF0EF")
#let pale-purple = rgb("F0ECF9")
#let pale-gray = rgb("F4F6F7")

// xcolor mixing, so `UTPBlue!28` is `mix(blue, 28%)` and
// `UTPOrange!90!black` is `mix(orange, 90%, black)`. xcolor mixes the RGB
// values linearly, which is what `space: rgb` does.
#let mix(c, amount, other: white) = color.mix((c, amount), (other, 100% - amount), space: rgb)
