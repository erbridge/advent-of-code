"lib/06/input.txt"
|> Advent2021.Fish.simulate_growth(80)
|> then(&IO.puts("After 80 days: #{&1}"))
