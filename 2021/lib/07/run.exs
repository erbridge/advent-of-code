[0, 1]
|> Enum.map(&{&1, Advent2021.Crabs.minimal_fuel("lib/07/input.txt", &1)})
|> Enum.map(&IO.puts("Minimal fuel cost with fuel steps of #{elem(&1, 0)}: #{elem(&1, 1)}"))
