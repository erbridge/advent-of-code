"lib/05/input.txt"
|> Advent2021.Vents.count_intersections(exclude_diagonals: true)
|> then(&IO.puts("Axial intersections: #{&1}"))

"lib/05/input.txt"
|> Advent2021.Vents.count_intersections(exclude_diagonals: false)
|> then(&IO.puts("All intersections: #{&1}"))
