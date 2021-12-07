[80, 256]
|> Enum.map(fn days ->
  days
  |> then(&Advent2021.Fish.simulate_growth("lib/06/input.txt", &1))
  |> then(&IO.puts("After #{days} days: #{&1}"))
end)
