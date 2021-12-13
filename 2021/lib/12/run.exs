"lib/12/input.txt"
|> Advent2021.Pathfinding.count_paths(1)
|> then(&IO.puts("Possible paths without visting a small cave twice: #{&1}"))

"lib/12/input.txt"
|> Advent2021.Pathfinding.count_paths(2)
|> then(&IO.puts("Possible paths allowing 2 visits to a single small cave: #{&1}"))
