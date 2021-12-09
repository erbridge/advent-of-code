"lib/09/input.txt"
|> Advent2021.LavaTubes.total_low_point_risk_level()
|> then(&IO.puts("Low point risk level: #{&1}"))

"lib/09/input.txt"
|> Advent2021.LavaTubes.largest_basin_sizes(3)
|> List.to_tuple()
|> Tuple.product()
|> then(&IO.puts("Product of 3 largest basin sizes: #{&1}"))
