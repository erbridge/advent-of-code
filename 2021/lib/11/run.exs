"lib/11/input.txt"
|> Advent2021.Octopuses.count_flashes(100)
|> then(&IO.puts("Flash count: #{&1}"))

"lib/11/input.txt"
|> Advent2021.Octopuses.steps_to_synchronize()
|> then(&IO.puts("Steps to synchronize: #{&1}"))
