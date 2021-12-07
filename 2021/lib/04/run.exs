Advent2021.Bingo.winning_score(
  "lib/04/input_boards.txt",
  "lib/04/input_numbers.txt"
)
|> then(&IO.puts("Winning score: #{&1}"))

Advent2021.Bingo.losing_score(
  "lib/04/input_boards.txt",
  "lib/04/input_numbers.txt"
)
|> then(&IO.puts("Losing score: #{&1}"))
