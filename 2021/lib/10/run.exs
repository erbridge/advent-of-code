"lib/10/input.txt"
|> Advent2021.Syntax.error_score()
|> then(&IO.puts("Syntax error score: #{&1}"))
