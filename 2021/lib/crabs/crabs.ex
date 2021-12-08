defmodule Advent2021.Crabs do
  @moduledoc """
  Documentation for `Advent2021.Crabs`.
  """

  import Advent2021.Reader

  @spec minimal_fuel(String.t()) :: non_neg_integer
  @doc """
  Find the least possible fuel required to align the crabs.

  ## Examples

      iex> Advent2021.Crabs.minimal_fuel("lib/07/example.txt")
      37

  """
  def minimal_fuel(input_path) do
    input_path
    |> parse_input(&parse_state/1)
    |> List.flatten()
    |> then(&{&1, optimal_target(&1)})
    |> then(&fuel_cost(elem(&1, 0), elem(&1, 1)))
  end

  @spec parse_state(String.t()) :: [non_neg_integer]
  @doc """
  Parse the input state.

  ## Examples

      iex> Advent2021.Crabs.parse_state("3,4,3,1,2")
      [3, 4, 3, 1, 2]

  """
  def parse_state(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec optimal_target(
          [non_neg_integer],
          non_neg_integer | nil,
          non_neg_integer | nil
        ) :: non_neg_integer
  @doc """
  Find the cheapest position to move to.

  ## Examples

      iex> Advent2021.Crabs.optimal_target([3, 4, 3, 1, 2])
      3

  """
  def optimal_target(positions, target \\ nil, cost_to_beat \\ nil)

  def optimal_target(positions, nil, nil) do
    initial_target =
      positions
      |> then(&round(Enum.sum(&1) / length(&1)))

    cost = fuel_cost(positions, initial_target)

    optimal_target(positions, initial_target, cost)
  end

  def optimal_target(positions, target, cost_to_beat) do
    trial_targets = [target - 1, target + 1]

    better_targets =
      trial_targets
      |> Enum.map(&{&1, fuel_cost(positions, &1)})
      |> Enum.filter(&(elem(&1, 1) < cost_to_beat))

    if Enum.any?(better_targets) do
      better_targets
      |> Enum.min_by(&elem(&1, 1))
      |> then(&optimal_target(positions, elem(&1, 0), elem(&1, 1)))
    else
      target
    end
  end

  @spec fuel_cost([non_neg_integer], non_neg_integer) :: non_neg_integer
  @doc """
  Find the fuel cost of a position change.

  ## Examples

      iex> Advent2021.Crabs.fuel_cost([3, 4, 3, 1, 2], 3)
      4

  """
  def fuel_cost(positions, target) do
    Enum.reduce(
      positions,
      0,
      fn pos, total ->
        total + abs(pos - target)
      end
    )
  end
end
