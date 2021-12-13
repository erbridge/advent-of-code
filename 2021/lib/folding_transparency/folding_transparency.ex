defmodule Advent2021.FoldingTransparency do
  @moduledoc """
  Documentation for `Advent2021.FoldingTransparency`.
  """

  import Advent2021.Reader

  @type dot :: {integer, integer}
  @type fold :: {:x | :y, integer}

  @spec count_dots_after_folding_once(String.t(), String.t()) :: non_neg_integer
  @doc """
  Count the number of visible dots after folding once.

  ## Examples

      iex> Advent2021.FoldingTransparency.count_dots_after_folding_once(
      ...>   "lib/13/example_dots.txt",
      ...>   "lib/13/example_folds.txt"
      ...> )
      17

  """
  def count_dots_after_folding_once(input_dots_path, input_folds_path) do
    dots =
      input_dots_path
      |> parse_input(&parse_dot/1)

    folds =
      input_folds_path
      |> parse_input(&parse_fold/1)

    fold(dots, List.first(folds))
    |> Enum.count()
  end

  @spec parse_dot(String.t()) :: dot
  @doc """
  Parse a dot.

  ## Examples

      iex> Advent2021.FoldingTransparency.parse_dot("6,10")
      {6, 10}

  """
  def parse_dot(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  @spec parse_fold(String.t()) :: fold
  @doc """
  Parse a fold.

  ## Examples

      iex> Advent2021.FoldingTransparency.parse_fold("fold along y=7")
      {:y, 7}

      iex> Advent2021.FoldingTransparency.parse_fold("fold along x=5")
      {:x, 5}

  """
  def parse_fold(input) do
    input
    |> String.replace_prefix("fold along ", "")
    |> String.split("=")
    |> then(
      &{
        &1 |> List.first() |> String.to_atom(),
        &1 |> List.last() |> String.to_integer()
      }
    )
  end

  @spec fold([dot], fold) :: [dot]
  @doc """
  Fold the paper according to the given fold.

  ## Examples

      iex> Advent2021.FoldingTransparency.fold(
      ...>   [
      ...>     {6, 10},
      ...>     {0, 14},
      ...>     {9, 10},
      ...>     {0, 3},
      ...>     {10, 4},
      ...>     {4, 11},
      ...>     {6, 0},
      ...>     {6, 12},
      ...>     {4, 1},
      ...>     {0, 13},
      ...>     {10, 12},
      ...>     {3, 4},
      ...>     {3, 0},
      ...>     {8, 4},
      ...>     {1, 10},
      ...>     {2, 14},
      ...>     {8, 10},
      ...>     {9, 0}
      ...>   ],
      ...>   {:y, 7}
      ...> )
      [
        {6, 4},
        {0, 0},
        {9, 4},
        {0, 3},
        {10, 4},
        {4, 3},
        {6, 0},
        {6, 2},
        {4, 1},
        {0, 1},
        {10, 2},
        {3, 4},
        {3, 0},
        {8, 4},
        {1, 4},
        {2, 0},
        {9, 0}
      ]

  """
  def fold(dots, {fold_axis, fold_index}) do
    dots
    |> Enum.map(fn {x, y} ->
      case fold_axis do
        :x -> if x < fold_index, do: {x, y}, else: {2 * fold_index - x, y}
        :y -> if y < fold_index, do: {x, y}, else: {x, 2 * fold_index - y}
      end
    end)
    |> Enum.uniq()
  end
end
