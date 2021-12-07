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

      iex> Advent2021.Fish.simulate_growth("lib/06/example.txt", 256)
      26984457539

  """
  def simulate_growth(
        input_path,
        days_to_simulate,
        options \\ [days_to_spawn: 7, initial_days_to_spawn: 9]
      ) do
    initial_timers(input_path, options)
    |> step_for(days_to_simulate, options)
    |> Map.values()
    |> Enum.sum()
  end

  @spec initial_timers(
          String.t(),
          days_to_spawn: pos_integer,
          initial_days_to_spawn: pos_integer
        ) :: %{non_neg_integer => non_neg_integer}
  @doc """
  Create timers with the initial state.

  ## Examples

      iex> Advent2021.Fish.initial_timers(
      ...>   "lib/06/example.txt",
      ...>   days_to_spawn: 7,
      ...>   initial_days_to_spawn: 9
      ...> )
      %{0 => 0, 1 => 1, 2 => 1, 3 => 2, 4 => 1, 5 => 0, 6 => 0, 7 => 0, 8 => 0}

  """
  def initial_timers(
        input_path,
        days_to_spawn: days_to_spawn,
        initial_days_to_spawn: initial_days_to_spawn
      ) do
    max_timer =
      [days_to_spawn, initial_days_to_spawn]
      |> Enum.max()
      |> Kernel.-(1)

    initial_timers =
      input_path
      |> parse_input(&parse_state/1)
      |> List.flatten()
      |> Enum.frequencies()

    0..max_timer
    |> Map.new(&{&1, 0})
    |> Map.merge(initial_timers)
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
          %{non_neg_integer => non_neg_integer},
          pos_integer,
          days_to_spawn: pos_integer,
          initial_days_to_spawn: pos_integer
        ) :: %{non_neg_integer => non_neg_integer}
  @doc """
  Run the simulation for the given number of steps.

  ## Examples

      iex> Advent2021.Fish.step_for(
      ...>   %{
      ...>     0 => 0,
      ...>     1 => 1,
      ...>     2 => 1,
      ...>     3 => 2,
      ...>     4 => 1,
      ...>     5 => 0,
      ...>     6 => 0,
      ...>     7 => 0,
      ...>     8 => 0
      ...>   },
      ...>   3,
      ...>   days_to_spawn: 7,
      ...>   initial_days_to_spawn: 9
      ...> )
      %{0 => 2, 1 => 1, 2 => 0, 3 => 0, 4 => 0, 5 => 1, 6 => 1, 7 => 1, 8 => 1}

  """
  def step_for(fish_timers, 0, _options) do
    fish_timers
  end

  def step_for(fish_timers, days_to_simulate, options) do
    fish_timers
    |> step(options)
    |> step_for(days_to_simulate - 1, options)
  end

  @spec step(
          %{non_neg_integer => non_neg_integer},
          days_to_spawn: pos_integer,
          initial_days_to_spawn: pos_integer
        ) :: %{non_neg_integer => non_neg_integer}
  @doc """
  Run the simulation for a step.

  ## Examples

      iex> Advent2021.Fish.step(
      ...>   %{
      ...>     0 => 0,
      ...>     1 => 1,
      ...>     2 => 1,
      ...>     3 => 2,
      ...>     4 => 1,
      ...>     5 => 0,
      ...>     6 => 0,
      ...>     7 => 0,
      ...>     8 => 0
      ...>   },
      ...>   days_to_spawn: 7,
      ...>   initial_days_to_spawn: 9
      ...> )
      %{0 => 1, 1 => 1, 2 => 2, 3 => 1, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0}

      iex> Advent2021.Fish.step(
      ...>   %{
      ...>     0 => 2,
      ...>     1 => 1,
      ...>     2 => 0,
      ...>     3 => 0,
      ...>     4 => 0,
      ...>     5 => 1,
      ...>     6 => 1,
      ...>     7 => 1,
      ...>     8 => 1
      ...>   },
      ...>   days_to_spawn: 7,
      ...>   initial_days_to_spawn: 9
      ...> )
      %{0 => 1, 1 => 0, 2 => 0, 3 => 0, 4 => 1, 5 => 1, 6 => 3, 7 => 1, 8 => 2}

  """
  def step(
        fish_timers,
        days_to_spawn: days_to_spawn,
        initial_days_to_spawn: initial_days_to_spawn
      ) do
    max_timer =
      [days_to_spawn, initial_days_to_spawn]
      |> Enum.max()
      |> Kernel.-(1)

    reproducers_count = fish_timers[0]

    fish_timers
    |> Map.values()
    |> Enum.drop(1)
    |> Kernel.++([0])
    |> then(&Enum.zip(0..max_timer, &1))
    |> Map.new()
    |> Map.update!(days_to_spawn - 1, &Kernel.+(&1, reproducers_count))
    |> Map.update!(initial_days_to_spawn - 1, &Kernel.+(&1, reproducers_count))
  end
end
