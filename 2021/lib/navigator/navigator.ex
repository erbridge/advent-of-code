defmodule Advent2021.Navigator do
  @moduledoc """
  Documentation for `Advent2021.Navigator`.
  """

  @type command :: {:forward | :down | :up, integer}
  @type position :: {integer, integer, integer}

  @spec parse_command(String.t()) :: command
  @doc """
  Parse a raw command.

  ## Examples

      iex> Advent2021.Navigator.parse_command("forward 1")
      {:forward, 1}

  """
  def parse_command(raw_command) do
    [direction, distance] = String.split(raw_command)
    {String.to_atom(direction), String.to_integer(distance)}
  end

  @spec follow_commands([command], (command, position -> position)) :: position
  @doc """
  Find the position after executing the commands.

  ## Examples

      iex> Advent2021.Navigator.follow_commands(
      ...>   [{:forward, 1}, {:down, 2}, {:up, 3}],
      ...>   fn command, acc ->
      ...>     {horizontal, depth, bearing} = acc
      ...>
      ...>     case command do
      ...>       {:forward, distance} -> {horizontal + distance, depth, bearing}
      ...>       {:down, distance} -> {horizontal, depth + distance, bearing}
      ...>       {:up, distance} -> {horizontal, depth - distance, bearing}
      ...>     end
      ...>   end
      ...> )
      {1, -1, 0}

  """
  def follow_commands(commands, reducer) do
    Enum.reduce(commands, {0, 0, 0}, &reducer.(&1, &2))
  end
end
