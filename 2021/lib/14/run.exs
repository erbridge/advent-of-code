Advent2021.Polymerization.min_max_elements_after_polymerization(
  "lib/14/input_template.txt",
  "lib/14/input_rules.txt",
  10
)
|> then(
  &IO.puts(
    "Most common element - least common element after 10 steps: #{elem(&1, 1) - elem(&1, 0)}"
  )
)
