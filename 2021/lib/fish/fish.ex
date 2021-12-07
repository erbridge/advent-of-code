defmodule Advent2021.Fish do
  @moduledoc """
  Documentation for `Advent2021.Fish`.
  """

  import Advent2021.Reader

  @spec simulate_growth(
          String.t(),
          pos_integer,
          days_to_spawn: pos_integer,
          initial_days_to_spawn: pos_integer
        ) :: non_neg_integer
  @doc """
  Count the fish after being left to grow for a number of days.

  ## Examples

      iex> Advent2021.Fish.simulate_growth("lib/06/example.txt", 80)
      5934

  """
  def simulate_growth(
        input_path,
        days_to_simulate,
        options \\ [days_to_spawn: 7, initial_days_to_spawn: 9]
      ) do
    input_path
    |> parse_input(&parse_state/1)
    |> List.flatten()
    |> step_for(days_to_simulate, options)
    |> Enum.count()
  end

  @spec parse_state(String.t()) :: [non_neg_integer]
  @doc """
  Parse the input state.

  ## Examples

      iex> Advent2021.Fish.parse_state("3,4,3,1,2")
      [3, 4, 3, 1, 2]

  """
  def parse_state(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec step_for(
          [non_neg_integer],
          pos_integer,
          days_to_spawn: pos_integer,
          initial_days_to_spawn: pos_integer
        ) :: [non_neg_integer]
  @doc """
  Run the simulation for the given number of steps.

  ## Examples

      iex> Advent2021.Fish.step_for(
      ...>   [3, 4, 3, 1, 2],
      ...>   3,
      ...>   days_to_spawn: 7,
      ...>   initial_days_to_spawn: 9
      ...> )
      [0, 1, 0, 5, 6, 7, 8]

  """
  def step_for(fish, 0, _options) do
    fish
  end

  def step_for(fish, days_to_simulate, options) do
    fish
    |> step(options)
    |> step_for(days_to_simulate - 1, options)
  end

  @spec step(
          [non_neg_integer],
          days_to_spawn: pos_integer,
          initial_days_to_spawn: pos_integer
        ) :: [non_neg_integer]
  @doc """
  Run the simulation for a step.

  ## Examples

      iex> Advent2021.Fish.step(
      ...>   [3, 4, 3, 1, 2],
      ...>   days_to_spawn: 7,
      ...>   initial_days_to_spawn: 9
      ...> )
      [2, 3, 2, 0, 1]

      iex> Advent2021.Fish.step(
      ...>   [0, 1, 0, 5, 6, 7, 8],
      ...>   days_to_spawn: 7,
      ...>   initial_days_to_spawn: 9
      ...> )
      [6, 0, 6, 4, 5, 6, 7, 8, 8]

  """
  def step(
        fish,
        days_to_spawn: days_to_spawn,
        initial_days_to_spawn: initial_days_to_spawn
      ) do
    newborn_fish =
      fish
      |> Enum.count(&(&1 == 0))
      |> then(&List.duplicate(initial_days_to_spawn - 1, &1))

    current_fish =
      fish
      |> Enum.map(fn f ->
        f
        |> case do
          x when x <= 0 -> x + days_to_spawn
          x -> x
        end
        |> Kernel.-(1)
      end)

    current_fish ++ newborn_fish
  end
end
