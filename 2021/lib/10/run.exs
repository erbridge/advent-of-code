"lib/10/input.txt"
|> Advent2021.Syntax.error_score()
|> then(&IO.puts("Syntax error score: #{&1}"))

"lib/10/input.txt"
|> Advent2021.Syntax.autocomplete_score()
|> then(&IO.puts("Autocomplete score: #{&1}"))
