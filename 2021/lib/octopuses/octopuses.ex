defmodule Advent2021.Octopuses do
  @moduledoc """
  Documentation for `Advent2021.Octopuses`.
  """

  import Advent2021.Reader

  @spec steps_to_synchronize(String.t()) :: non_neg_integer
  @doc """
  Count the number of octopus flashes after a number of steps

  ## Examples

      iex> Advent2021.Octopuses.steps_to_synchronize("lib/11/example.txt")
      195

  """
  def steps_to_synchronize(input_path) do
    input_path
    |> parse_input(&parse_row/1)
    |> step_until(&synchronized?/1)
    |> elem(2)
  end

  @spec count_flashes(String.t(), pos_integer) :: non_neg_integer
  @doc """
  Count the number of octopus flashes after a number of steps

  ## Examples

      iex> Advent2021.Octopuses.count_flashes("lib/11/example.txt", 100)
      1656

  """
  def count_flashes(input_path, steps) do
    input_path
    |> parse_input(&parse_row/1)
    |> step(steps)
    |> elem(1)
  end

  @spec parse_row(String.t()) :: [non_neg_integer]
  @doc """
  Parse a row of octopuses.

  ## Examples

      iex> Advent2021.Octopuses.parse_row("34312")
      [3, 4, 3, 1, 2]

  """
  def parse_row(input) do
    input
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec step(
          [[non_neg_integer]],
          non_neg_integer,
          non_neg_integer
        ) :: {[[non_neg_integer]], non_neg_integer}
  @doc """
  Step through octopus flashes.

  ## Examples

      iex> Advent2021.Octopuses.step(
      ...>   [
      ...>     [1, 1, 1, 1, 1],
      ...>     [1, 9, 9, 9, 1],
      ...>     [1, 9, 1, 9, 1],
      ...>     [1, 9, 9, 9, 1],
      ...>     [1, 1, 1, 1, 1]
      ...>   ],
      ...>   2
      ...>)
      {
        [
          [4, 5, 6, 5, 4],
          [5, 1, 1, 1, 5],
          [6, 1, 1, 1, 6],
          [5, 1, 1, 1, 5],
          [4, 5, 6, 5, 4]
        ],
        9
      }

  """
  def step(grid, steps, flash_count \\ 0)

  def step(grid, 0, flash_count) do
    {grid, flash_count}
  end

  def step(grid, steps, flash_count) do
    {new_grid, new_flash_count} =
      grid
      |> Enum.map(fn row -> Enum.map(row, &(&1 + 1)) end)
      |> cascade_flash()

    step(new_grid, steps - 1, flash_count + new_flash_count)
  end

  @spec step_until(
          [[non_neg_integer]],
          ([[non_neg_integer]] -> boolean),
          non_neg_integer
        ) :: {[[non_neg_integer]], non_neg_integer, pos_integer}
  @doc """
  Step through octopus flashes until the condition is met.

  ## Examples

      iex> Advent2021.Octopuses.step_until(
      ...>   [
      ...>     [1, 1, 1, 1, 1],
      ...>     [1, 9, 9, 9, 1],
      ...>     [1, 9, 1, 9, 1],
      ...>     [1, 9, 9, 9, 1],
      ...>     [1, 1, 1, 1, 1]
      ...>   ],
      ...>   &Advent2021.Octopuses.synchronized?/1
      ...>)
      {
        [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0]
        ],
        25,
        6
      }

  """
  def step_until(grid, ender, flash_count \\ 0, steps \\ 0) do
    {new_grid, new_flash_count} =
      grid
      |> Enum.map(fn row -> Enum.map(row, &(&1 + 1)) end)
      |> cascade_flash()

    if ender.(new_grid) do
      {new_grid, new_flash_count, steps + 1}
    else
      step_until(new_grid, ender, flash_count + new_flash_count, steps + 1)
    end
  end

  @spec cascade_flash(
          [[non_neg_integer]],
          [{non_neg_integer, non_neg_integer}],
          non_neg_integer
        ) :: {[[non_neg_integer]], non_neg_integer}
  @doc """
  Find the state of the octopuses after a flash cascade.

  ## Examples

  iex> Advent2021.Octopuses.cascade_flash([
  ...>   [2, 2, 2, 2, 2],
  ...>   [2, 10, 10, 10, 2],
  ...>   [2, 10, 2, 10, 2],
  ...>   [2, 10, 10, 10, 2],
  ...>   [2, 2, 2, 2, 2]
  ...> ])
  {
    [
      [3, 4, 5, 4, 3],
      [4, 0, 0, 0, 4],
      [5, 0, 0, 0, 5],
      [4, 0, 0, 0, 4],
      [3, 4, 5, 4, 3]
    ],
    9
  }

  """
  def cascade_flash(grid, past_flashers \\ [], flash_count \\ 0) do
    new_flashers = flashers(grid, past_flashers)
    new_flash_count = length(new_flashers)
    new_grid = flash_grid(grid, new_flashers)

    if new_flash_count == 0 do
      new_grid
      |> Enum.map(
        &Enum.map(
          &1,
          fn level -> if level > 9, do: 0, else: level end
        )
      )
      |> then(&{&1, flash_count})
    else
      cascade_flash(
        new_grid,
        past_flashers ++ new_flashers,
        flash_count + new_flash_count
      )
    end
  end

  @spec flashers(
          [[non_neg_integer]],
          [{non_neg_integer, non_neg_integer}]
        ) :: [{non_neg_integer, non_neg_integer}]
  @doc """
  Find coordinates of new flashing octopuses on this step of the cascade.

  ## Examples

  iex> Advent2021.Octopuses.flashers(
  ...>   [
  ...>     [2, 2, 2, 2, 2],
  ...>     [2, 10, 10, 10, 2],
  ...>     [2, 10, 2, 10, 2],
  ...>     [2, 10, 10, 10, 2],
  ...>     [2, 2, 2, 2, 2]
  ...>   ],
  ...>   []
  ...> )
  [{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 3}, {3, 1}, {3, 2}, {3, 3}]

  iex> Advent2021.Octopuses.flashers(
  ...>   [
  ...>     [3, 4, 5, 4, 3],
  ...>     [4, 12, 14, 12, 4],
  ...>     [5, 14, 10, 14, 5],
  ...>     [4, 12, 14, 12, 4],
  ...>     [3, 4, 5, 4, 3]
  ...>   ],
  ...>   [{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 3}, {3, 1}, {3, 2}, {3, 3}]
  ...> )
  [{2, 2}]

  """
  def flashers(grid, past_flashers) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.filter(&(elem(&1, 0) > 9))
      |> Enum.map(&{row_index, elem(&1, 1)})
    end)
    |> List.flatten()
    |> Kernel.--(past_flashers)
  end

  @spec flash_grid(
          [[non_neg_integer]],
          [{non_neg_integer, non_neg_integer}]
        ) :: [[non_neg_integer]]
  @doc """
  Find the state of the octopuses after a step in the flash cascade.

  ## Examples

  iex> Advent2021.Octopuses.flash_grid(
  ...>   [
  ...>     [2, 2, 2, 2, 2],
  ...>     [2, 10, 10, 10, 2],
  ...>     [2, 10, 2, 10, 2],
  ...>     [2, 10, 10, 10, 2],
  ...>     [2, 2, 2, 2, 2]
  ...>   ],
  ...>   [{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 3}, {3, 1}, {3, 2}, {3, 3}]
  ...> )
  [
    [3, 4, 5, 4, 3],
    [4, 12, 14, 12, 4],
    [5, 14, 10, 14, 5],
    [4, 12, 14, 12, 4],
    [3, 4, 5, 4, 3]
  ]

  iex> Advent2021.Octopuses.flash_grid(
  ...>   [
  ...>     [3, 4, 5, 4, 3],
  ...>     [4, 12, 14, 12, 4],
  ...>     [5, 14, 10, 14, 5],
  ...>     [4, 12, 14, 12, 4],
  ...>     [3, 4, 5, 4, 3]
  ...>   ],
  ...>   [{2, 2}]
  ...> )
  [
    [3, 4, 5, 4, 3],
    [4, 13, 15, 13, 4],
    [5, 15, 10, 15, 5],
    [4, 13, 15, 13, 4],
    [3, 4, 5, 4, 3]
  ]

  """
  def flash_grid(grid, new_flashers) do
    row_count = length(grid)
    col_count = length(List.first(grid))

    new_flashers
    |> Enum.flat_map(fn {r, c} ->
      [
        {r - 1, c - 1},
        {r - 1, c},
        {r - 1, c + 1},
        {r, c - 1},
        {r, c + 1},
        {r + 1, c - 1},
        {r + 1, c},
        {r + 1, c + 1}
      ]
      |> Enum.reject(fn {n_r, n_c} ->
        n_r < 0 or n_r >= row_count or n_c < 0 or n_c >= col_count
      end)
    end)
    |> Enum.reduce(
      grid,
      fn {r, c}, grid_acc ->
        new_row =
          grid_acc
          |> Enum.at(r)
          |> then(&List.replace_at(&1, c, Enum.at(&1, c) + 1))

        List.replace_at(grid_acc, r, new_row)
      end
    )
  end

  @spec synchronized?([[non_neg_integer]]) :: boolean
  @doc """
  Check if all octopuses just flashed in sync.

  ## Examples

  iex> Advent2021.Octopuses.synchronized?([
  ...>   [1, 1, 1, 1, 1],
  ...>   [1, 9, 9, 9, 1],
  ...>   [1, 9, 1, 9, 1],
  ...>   [1, 9, 9, 9, 1],
  ...>   [1, 1, 1, 1, 1]
  ...> ])
  false

  iex> Advent2021.Octopuses.synchronized?([
  ...>   [0, 0, 0, 0, 0],
  ...>   [0, 0, 0, 0, 0],
  ...>   [0, 0, 0, 0, 0],
  ...>   [0, 0, 0, 0, 0],
  ...>   [0, 0, 0, 0, 0]
  ...> ])
  true

  """
  def synchronized?(grid) do
    grid
    |> List.flatten()
    |> Enum.all?(&(&1 == 0))
  end
end
