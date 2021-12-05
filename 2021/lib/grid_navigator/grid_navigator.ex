defmodule Advent2021.GridNavigator do
  @moduledoc """
  Documentation for `Advent2021.GridNavigator`.
  """

  import Advent2021.Reader

  @spec final_position(binary) :: {integer, integer}
  @doc """
  Find the final position after following the commands in the input file.

  ## Examples

      iex> Advent2021.GridNavigator.final_position("lib/02/example.txt")
      {15, 10}

  """
  def final_position(input_path) do
    input_path
    |> parse_input(&parse_command/1)
    |> position_after()
  end

  @spec parse_command(String.t()) :: {:forward | :down | :up, integer}
  @doc """
  Parse a raw command.

  ## Examples

      iex> Advent2021.GridNavigator.parse_command("forward 1")
      {:forward, 1}

  """
  def parse_command(raw_command) do
    [direction, distance] = String.split(raw_command)
    {String.to_atom(direction), String.to_integer(distance)}
  end

  @spec position_after(
          [{:forward | :down | :up, integer}],
          false | nil | non_neg_integer
        ) :: {integer, integer}
  @doc """
  Find the coordinates after following a series of commands.

  ## Examples

      iex> Advent2021.GridNavigator.position_after(
      ...>   [{:forward, 1}, {:down, 2}, {:up, 3}]
      ...> )
      {1, -1}

      iex> Advent2021.GridNavigator.position_after(
      ...>   [{:forward, 1}, {:down, 2}, {:up, 3}],
      ...>   2
      ...> )
      {1, 2}

  """
  def position_after(commands, count \\ nil) do
    included_commands =
      if count,
        do: Enum.slice(commands, 0, count),
        else: commands

    Enum.reduce(included_commands, {0, 0}, fn command, acc ->
      {horizontal, depth} = acc

      case command do
        {:forward, distance} -> {horizontal + distance, depth}
        {:down, distance} -> {horizontal, depth + distance}
        {:up, distance} -> {horizontal, depth - distance}
      end
    end)
  end
end
