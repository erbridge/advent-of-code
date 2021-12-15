"lib/15/input.txt"
|> Advent2021.WeightedPathfinding.lowest_risk()
|> then(&IO.puts("Lowest risk: #{&1}"))

"lib/15/input.txt"
|> Advent2021.WeightedPathfinding.lowest_risk(tile: {5, 5})
|> then(&IO.puts("Lowest risk for 5x5: #{&1}"))
