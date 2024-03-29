defmodule Advent2021.GridNavigator do
  @moduledoc """
  Documentation for `Advent2021.GridNavigator`.
  """

  import Advent2021.Navigator
  import Advent2021.Reader

  @spec final_position(String.t()) :: Advent2021.Navigator.position()
  @doc """
  Find the final position after following the commands in the input file.

  ## Examples

      iex> Advent2021.GridNavigator.final_position("lib/02/example.txt")
      {15, 10, 0}

  """
  def final_position(input_path) do
    input_path
    |> parse_input(&parse_command/1)
    |> follow_commands(&follow_command/2)
  end

  @spec follow_command(
          Advent2021.Navigator.command(),
          Advent2021.Navigator.position()
        ) :: Advent2021.Navigator.position()
  @doc """
  Find the coordinates after following a series of commands.

  ## Examples

      iex> Advent2021.GridNavigator.follow_command({:forward, 3}, {10, 10, 0})
      {13, 10, 0}

      iex> Advent2021.GridNavigator.follow_command({:down, 3}, {10, 10, 0})
      {10, 13, 0}

      iex> Advent2021.GridNavigator.follow_command({:up, 3}, {10, 10, 0})
      {10, 7, 0}

  """
  def follow_command({direction, distance}, {horizontal, depth, bearing}) do
    case direction do
      :forward -> {horizontal + distance, depth, bearing}
      :down -> {horizontal, depth + distance, bearing}
      :up -> {horizontal, depth - distance, bearing}
    end
  end
end
