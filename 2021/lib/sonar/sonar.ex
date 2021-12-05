defmodule Advent2021.Sonar do
  @moduledoc """
  Documentation for `Advent2021.Sonar`.
  """

  import Advent2021.Reader

  @spec count_depth_increases(binary, non_neg_integer) :: non_neg_integer
  @doc """
  Count the number of measurements larger than the previous one in the input
  file.

  ## Examples

      iex> Advent2021.Sonar.count_depth_increases("lib/01/example.txt")
      7

      iex> Advent2021.Sonar.count_depth_increases("lib/01/example.txt", 3)
      5

  """
  def count_depth_increases(input_path, width \\ 1) do
    input_path
    |> parse_input(&String.to_integer/1)
    |> depth_changes(width)
    |> Enum.count(&(&1 == :increase))
  end

  @spec depth_changes([integer], non_neg_integer) :: [:increase | :decrease | :equal]
  @doc """
  Convert the list of measurements into a list of :increase, :decrease, and
  :equal based on the change between values.

  ## Examples

      iex> Advent2021.Sonar.depth_changes([100, 101, 99])
      [:increase, :decrease]

      iex> Advent2021.Sonar.depth_changes([100, 101, 99, 100, 99, 200, 300], 3)
      [:equal, :decrease, :increase, :increase]

  """
  def depth_changes(measurements, width \\ 1) do
    moving_sum_depths =
      0..(width - 1)
      |> Enum.map(fn w ->
        if w > 0,
          do: Enum.slice(measurements, w, length(measurements)),
          else: measurements
      end)
      |> Enum.zip_with(&Enum.sum/1)

    Enum.zip_with(
      moving_sum_depths,
      Enum.slice(moving_sum_depths, 1, length(moving_sum_depths)),
      &depth_change/2
    )
  end

  @spec depth_change(integer, integer) :: :decrease | :increase | :equal
  @doc """
  Compares two measurements, returning an atom describing their relative values.

  ## Examples

      iex> Advent2021.Sonar.depth_change(100, 101)
      :increase

      iex> Advent2021.Sonar.depth_change(101, 100)
      :decrease

      iex> Advent2021.Sonar.depth_change(100, 100)
      :equal

  """
  def depth_change(a, b) do
    case {a, b} do
      {a, b} when a < b -> :increase
      {a, b} when b < a -> :decrease
      {a, b} when a == b -> :equal
    end
  end
end
