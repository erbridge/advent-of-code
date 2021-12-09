defmodule Advent2021.LavaTubes do
  @moduledoc """
  Documentation for `Advent2021.LavaTubes`.
  """

  import Advent2021.Reader

  @spec total_low_point_risk_level(String.t()) :: non_neg_integer
  @doc """
  Find the sum of the risk levels of all low points.

  ## Examples

      iex> Advent2021.LavaTubes.total_low_point_risk_level("lib/09/example.txt")
      15

  """
  def total_low_point_risk_level(input_path) do
    heightmap =
      input_path
      |> parse_input(&parse_heightmap_row/1)

    heightmap
    |> local_minima()
    |> Enum.map(&risk_level(heightmap, &1))
    |> Enum.sum()
  end

  @spec parse_heightmap_row(String.t()) :: [non_neg_integer]
  @doc """
  Parse a row of the heightmap.

  ## Examples

      iex> Advent2021.LavaTubes.parse_heightmap_row("34312")
      [3, 4, 3, 1, 2]

  """
  def parse_heightmap_row(input) do
    input
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec local_minima([[non_neg_integer]]) ::
          [{non_neg_integer, non_neg_integer}]
  @doc """
  Find the row and column indices representing local minima.

  ## Examples

      iex> Advent2021.LavaTubes.local_minima([
      ...>   [2, 1, 9, 9, 9],
      ...>   [3, 9, 8, 7, 8],
      ...>   [9, 8, 5, 6, 7],
      ...>   [8, 7, 6, 7, 8]
      ...> ])
      [{0, 1}, {2, 2}]

  """
  def local_minima(heightmap) do
    local_extrema(heightmap, &local_minimum?/1)
  end

  @spec local_maxima([[non_neg_integer]]) ::
          [{non_neg_integer, non_neg_integer}]
  @doc """
  Find the row and column indices representing local maxima.

  ## Examples

      iex> Advent2021.LavaTubes.local_maxima([
      ...>   [2, 1, 9, 9, 9],
      ...>   [3, 9, 8, 7, 8],
      ...>   [9, 8, 5, 6, 7],
      ...>   [8, 7, 6, 7, 8]
      ...> ])
      [{0, 2}, {0, 3}, {0, 4}, {1, 1}, {2, 0}]

  """
  def local_maxima(heightmap) do
    local_extrema(heightmap, &local_maximum?/1)
  end

  @spec local_extrema(
          [[non_neg_integer]],
          ([non_neg_integer] -> [non_neg_integer])
        ) :: [{non_neg_integer, non_neg_integer}]
  @doc """
  Find the row and column indices representing local extrema.

  ## Examples

      iex> Advent2021.LavaTubes.local_extrema(
      ...>   [
      ...>     [2, 1, 9, 9, 9],
      ...>     [3, 9, 8, 7, 8],
      ...>     [9, 8, 5, 6, 7],
      ...>     [8, 7, 6, 7, 8]
      ...>   ],
      ...>   &Advent2021.LavaTubes.local_minimum?/1
      ...> )
      [{0, 1}, {2, 2}]

  """
  def local_extrema(heightmap, tester) do
    row_extrema =
      heightmap
      |> Enum.map(&row_local_extrema(&1, tester))
      |> Enum.with_index()
      |> Enum.map(fn {indices, row_index} ->
        Enum.map(indices, &{row_index, &1})
      end)
      |> List.flatten()
      |> MapSet.new()

    column_extrema =
      heightmap
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&row_local_extrema(&1, tester))
      |> Enum.with_index()
      |> Enum.map(fn {indices, column_index} ->
        Enum.map(indices, &{&1, column_index})
      end)
      |> List.flatten()
      |> MapSet.new()

    MapSet.intersection(row_extrema, column_extrema)
    |> MapSet.to_list()
  end

  @spec row_local_extrema(
          [non_neg_integer],
          ([non_neg_integer] -> boolean)
        ) :: [non_neg_integer]
  @doc """
  Find the indices representing local extrema in the row, ignoring column
  effects.

  ## Examples

      iex> Advent2021.LavaTubes.row_local_extrema(
      ...>   [3, 4, 3, 1, 2],
      ...>   &Advent2021.LavaTubes.local_minimum?/1
      ...> )
      [0, 3]

  """
  def row_local_extrema(row, tester) do
    ([9] ++ row ++ [9])
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.with_index()
    |> Enum.filter(fn {points, _} ->
      tester.(points)
    end)
    |> Enum.map(&elem(&1, 1))
  end

  @spec local_minimum?([non_neg_integer]) :: boolean
  @doc """
  Check if the midpoint is a local minimum.

  ## Examples

      iex> Advent2021.LavaTubes.local_minimum?([3, 4, 3])
      false

      iex> Advent2021.LavaTubes.local_minimum?([4, 3, 4])
      true

      iex> Advent2021.LavaTubes.local_minimum?([4, 3, 2])
      false

      iex> Advent2021.LavaTubes.local_minimum?([9, 9, 9])
      false

  """
  def local_minimum?([left, mid, right]) do
    left > mid and mid < right
  end

  @spec local_maximum?([non_neg_integer]) :: boolean
  @doc """
  Check if the midpoint is a local maximum.

  ## Examples

      iex> Advent2021.LavaTubes.local_maximum?([3, 4, 3])
      true

      iex> Advent2021.LavaTubes.local_maximum?([4, 3, 4])
      false

      iex> Advent2021.LavaTubes.local_maximum?([4, 3, 2])
      false

      iex> Advent2021.LavaTubes.local_maximum?([9, 9, 9])
      true

  """
  def local_maximum?([left, mid, right]) do
    mid == 9 or (left < mid and mid > right)
  end

  @spec risk_level(
          [[non_neg_integer]],
          {non_neg_integer, non_neg_integer}
        ) :: non_neg_integer
  @doc """
  Find the risk level for a given point in the heightmap.

  ## Examples

      iex> Advent2021.LavaTubes.risk_level(
      ...>   [
      ...>     [2, 1, 9, 9, 9],
      ...>     [3, 9, 8, 7, 8],
      ...>     [9, 8, 5, 6, 7],
      ...>     [8, 7, 6, 7, 8]
      ...>   ],
      ...>   {0, 1}
      ...> )
      2

  """
  def risk_level(heightmap, {row, column}) do
    heightmap
    |> Enum.at(row)
    |> Enum.at(column)
    |> Kernel.+(1)
  end
end
