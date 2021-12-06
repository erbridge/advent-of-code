defmodule Advent2021.DirectionalNavigator do
  @moduledoc """
  Documentation for `Advent2021.DirectionalNavigator`.
  """

  import Advent2021.Navigator
  import Advent2021.Reader

  @spec final_position(String.t()) :: Advent2021.Navigator.position()
  @doc """
  Find the final position after following the commands in the input file.

  ## Examples

      iex> Advent2021.DirectionalNavigator.final_position("lib/02/example.txt")
      {15, 60, 10}

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

    iex> Advent2021.DirectionalNavigator.follow_command(
    ...>   {:forward, 3},
    ...>   {10, 10, 10}
    ...> )
    {13, 40, 10}

    iex> Advent2021.DirectionalNavigator.follow_command(
    ...>   {:down, 3},
    ...>   {10, 10, 0}
    ...> )
    {10, 10, 3}

    iex> Advent2021.DirectionalNavigator.follow_command(
    ...>   {:up, 3},
    ...>   {10, 10, 0}
    ...> )
    {10, 10, -3}

  """
  def follow_command({direction, change}, {horizontal, depth, bearing}) do
    case direction do
      :forward -> {horizontal + change, depth + change * bearing, bearing}
      :down -> {horizontal, depth, bearing + change}
      :up -> {horizontal, depth, bearing - change}
    end
  end
end
