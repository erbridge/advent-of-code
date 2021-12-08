"lib/08/input.txt"
|> Advent2021.SegmentDisplays.count_unique_outputs()
|> then(&IO.puts("Unique output patterns: #{&1}"))

"lib/08/input.txt"
|> Advent2021.SegmentDisplays.sum_outputs()
|> then(&IO.puts("Sum of output displays: #{&1}"))
