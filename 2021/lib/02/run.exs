{
  horizontal,
  depth,
  _bearing
} = Advent2021.GridNavigator.final_position("lib/02/input.txt")

IO.puts("Grid: #{horizontal * depth}")

{
  horizontal,
  depth,
  _bearing
} = Advent2021.DirectionalNavigator.final_position("lib/02/input.txt")

IO.puts("Directional: #{horizontal * depth}")
