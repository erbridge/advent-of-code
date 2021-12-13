Advent2021.FoldingTransparency.count_dots_after_folding_once(
  "lib/13/input_dots.txt",
  "lib/13/input_folds.txt"
)
|> then(&IO.puts("Number of visible dots after folding once: #{&1}"))

Advent2021.FoldingTransparency.draw_dots_after_folding(
  "lib/13/input_dots.txt",
  "lib/13/input_folds.txt"
)
|> then(&IO.puts("Paper after folding:\n#{&1}"))
