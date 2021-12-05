[1, 3]
|> Enum.map(fn width ->
  {width, Advent2021.Sonar.count_depth_increases("lib/01/input.txt", width)}
end)
|> Enum.map(fn {width, count} -> IO.puts("Width #{width}: #{count}") end)
