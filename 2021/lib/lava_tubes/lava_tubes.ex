defmodule Advent2021.LavaTubes do
  @moduledoc """
  Documentation for `Advent2021.LavaTubes`.
  """

  import Advent2021.Reader

  @spec largest_basin_sizes(String.t(), pos_integer) :: [non_neg_integer]
  @doc """
  Find the sum of the risk levels of all low points.

  ## Examples

      iex> Advent2021.LavaTubes.largest_basin_sizes("lib/09/example.txt")
      [14, 9, 9]

  """
  def largest_basin_sizes(input_path, count \\ 3) do
    input_path
    |> parse_input(&parse_heightmap_row/1)
    |> basins()
    |> Enum.map(&Enum.count/1)
    |> Enum.sort(:desc)
    |> Enum.take(count)
  end

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

  @spec basins([[non_neg_integer]]) :: [[{non_neg_integer, non_neg_integer}]]
  @doc """
  Group the points in the heightmap into basins.

  ## Examples

      iex> Advent2021.LavaTubes.basins([
      ...>   [2, 1, 9, 9, 9],
      ...>   [3, 9, 8, 7, 8],
      ...>   [9, 8, 5, 6, 7],
      ...>   [8, 7, 6, 7, 8]
      ...> ])
      [
        [
          {0, 0},
          {0, 1},
          {1, 0}
        ],
        [
          {1, 2},
          {1, 3},
          {1, 4},
          {2, 1},
          {2, 2},
          {2, 3},
          {2, 4},
          {3, 0},
          {3, 1},
          {3, 2},
          {3, 3},
          {3, 4}
        ]
      ]

  """
  def basins(heightmap) do
    maxima = local_maxima(heightmap)

    [first_row_basin | remaining_row_basins] =
      heightmap
      |> Enum.with_index()
      |> Enum.map(fn {row, row_index} -> row_basins(row, row_index, maxima) end)
      |> Enum.reduce([], &Kernel.++(&2, &1))

    remaining_row_basins
    |> Enum.reduce(
      [first_row_basin],
      fn basin, acc -> combine_basins(acc, basin) end
    )
  end

  @spec row_basins(
          [non_neg_integer],
          non_neg_integer,
          [{non_neg_integer, non_neg_integer}]
        ) :: [[{non_neg_integer, non_neg_integer}]]
  @doc """
  Find the row and column indices representing local minima.

  ## Examples

      iex> Advent2021.LavaTubes.row_basins([3, 9, 9, 7, 8], 1, [{1, 1}, {1, 2}])
      [
        [{1, 0}],
        [{1, 3}, {1, 4}]
      ]

  """
  def row_basins(row, row_index, maxima) do
    row
    |> Enum.with_index()
    |> Enum.chunk_while(
      [],
      fn {_, column_index}, chunk ->
        point = {row_index, column_index}

        if Enum.any?(maxima, &(&1 == point)) do
          {:cont, chunk, []}
        else
          {:cont, chunk ++ [point]}
        end
      end,
      fn chunk -> {:cont, chunk, nil} end
    )
    |> Enum.reject(&(length(&1) == 0))
  end

  @spec combine_basins(
          [[{non_neg_integer, non_neg_integer}]],
          [{non_neg_integer, non_neg_integer}]
        ) :: [[{non_neg_integer, non_neg_integer}]]
  @doc """
  Combine adjacent basins together and return the new set of basins.

  ## Examples

      iex> Advent2021.LavaTubes.combine_basins(
      ...>   [
      ...>     [{1, 0}],
      ...>     [{1, 3}, {1, 4}]
      ...>   ],
      ...>   [{2, 0}, {2, 1}]
      ...> )
      [
        [{1, 0}, {2, 0}, {2, 1}],
        [{1, 3}, {1, 4}]
      ]

      iex> Advent2021.LavaTubes.combine_basins(
      ...>   [
      ...>     [{1, 0}],
      ...>     [{1, 3}, {1, 4}]
      ...>   ],
      ...>   [{3, 0}, {3, 1}]
      ...> )
      [
        [{1, 0}],
        [{1, 3}, {1, 4}],
        [{3, 0}, {3, 1}]
      ]

  """
  def combine_basins(basin_set, basin) do
    index_to_join =
      basin_set
      |> Enum.with_index()
      |> Enum.find_value(fn {basin_set_basin, index} ->
        adjacent? =
          Enum.any?(basin, fn {x, y} ->
            Enum.any?(basin_set_basin, fn {basin_set_x, basin_set_y} ->
              (abs(x - basin_set_x) == 1 and y == basin_set_y) or
                (x == basin_set_x and abs(y - basin_set_y) == 1)
            end)
          end)

        if adjacent?, do: index
      end)

    if index_to_join do
      basin_set
      |> Enum.at(index_to_join)
      |> Kernel.++(basin)
      |> then(&List.replace_at(basin_set, index_to_join, &1))
    else
      basin_set ++ [basin]
    end
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
