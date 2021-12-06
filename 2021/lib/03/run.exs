"lib/03/input.txt"
|> Advent2021.Diagnostic.power_consumption()
|> then(&IO.puts("Power consumption: #{&1}"))

"lib/03/input.txt"
|> Advent2021.Diagnostic.life_support_rating()
|> then(&IO.puts("Life support rating: #{&1}"))
