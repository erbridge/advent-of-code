defmodule Advent2021.Pathfinding do
  @moduledoc """
  Documentation for `Advent2021.Pathfinding`.
  """

  import Advent2021.Reader

  @spec count_paths(String.t()) :: non_neg_integer
  @doc """
  Count the number of paths from start to end that don't visit any small caves
  more than once.

  ## Examples

      iex> Advent2021.Pathfinding.count_paths("lib/12/example-1.txt")
      10

      iex> Advent2021.Pathfinding.count_paths("lib/12/example-2.txt")
      19

      iex> Advent2021.Pathfinding.count_paths("lib/12/example-3.txt")
      226

  """
  def count_paths(input_path) do
    input_path
    |> parse_input(&parse_connection/1)
    |> List.flatten()
    |> find_paths()
    |> Enum.count()
  end

  @spec parse_connection(String.t()) :: [{atom, atom}]
  @doc """
  Parse a connection.

  ## Examples

      iex> Advent2021.Pathfinding.parse_connection("start-AB")
      [start: :AB, AB: :start]

      iex> Advent2021.Pathfinding.parse_connection("HN-end")
      [HN: :end, end: :HN]

      iex> Advent2021.Pathfinding.parse_connection("QR-kk")
      [QR: :kk, kk: :QR]

  """
  def parse_connection(input) do
    input
    |> String.split("-")
    |> Enum.map(&String.to_atom/1)
    |> then(&[&1, Enum.reverse(&1)])
    |> Enum.map(&List.to_tuple/1)
  end

  @spec find_paths([{atom, atom}], [[atom]]) :: [[atom]]
  @doc """
  Find all possible paths from start to end.

  ## Examples

      iex> Advent2021.Pathfinding.find_paths([
      ...>   start: :A,
      ...>   A: :start,
      ...>   start: :b,
      ...>   b: :start,
      ...>   A: :c,
      ...>   c: :A,
      ...>   A: :b,
      ...>   b: :A,
      ...>   b: :d,
      ...>   d: :b,
      ...>   A: :end,
      ...>   end: :A,
      ...>   b: :end,
      ...>   end: :b
      ...> ])
      [
        [:start, :A, :b, :A, :c, :A, :end],
        [:start, :A, :b, :A, :end],
        [:start, :A, :b, :end],
        [:start, :A, :c, :A, :b, :A, :end],
        [:start, :A, :c, :A, :b, :end],
        [:start, :A, :c, :A, :end],
        [:start, :A, :end],
        [:start, :b, :A, :c, :A, :end],
        [:start, :b, :A, :end],
        [:start, :b, :end]
      ]

  """
  def find_paths(connections, paths \\ [[:start]]) do
    if Enum.all?(paths, &(List.last(&1) == :end)) do
      Enum.sort(paths)
    else
      paths
      |> Enum.flat_map(&continue_path(connections, &1))
      |> then(&find_paths(connections, &1))
    end
  end

  @spec continue_path([{atom, atom}], [atom]) :: [[atom]]
  @doc """
  Find the set of possible path continuations.

  ## Examples

      iex> Advent2021.Pathfinding.continue_path(
      ...>   [
      ...>     start: :A,
      ...>     A: :start,
      ...>     start: :b,
      ...>     b: :start,
      ...>     A: :c,
      ...>     c: :A,
      ...>     A: :b,
      ...>     b: :A,
      ...>     b: :d,
      ...>     d: :b,
      ...>     A: :end,
      ...>     end: :A,
      ...>     b: :end,
      ...>     end: :b
      ...>   ],
      ...>   [:start, :A, :b, :A]
      ...> )
      [
        [:start, :A, :b, :A, :c],
        [:start, :A, :b, :A, :end]
      ]

      iex> Advent2021.Pathfinding.continue_path(
      ...>   [
      ...>     start: :A,
      ...>     A: :start,
      ...>     start: :b,
      ...>     b: :start,
      ...>     A: :c,
      ...>     c: :A,
      ...>     A: :b,
      ...>     b: :A,
      ...>     b: :d,
      ...>     d: :b,
      ...>     A: :end,
      ...>     end: :A,
      ...>     b: :end,
      ...>     end: :b
      ...>   ],
      ...>   [:start, :A, :b, :A, :end]
      ...> )
      [
        [:start, :A, :b, :A, :end]
      ]

      iex> Advent2021.Pathfinding.continue_path(
      ...>   [
      ...>     start: :A,
      ...>     A: :start,
      ...>     start: :b,
      ...>     b: :start,
      ...>     A: :c,
      ...>     c: :A,
      ...>     A: :b,
      ...>     b: :A,
      ...>     b: :d,
      ...>     d: :b,
      ...>     A: :end,
      ...>     end: :A,
      ...>     b: :end,
      ...>     end: :b
      ...>   ],
      ...>   [:start, :A, :b, :d]
      ...> )
      []

  """
  def continue_path(connections, path) do
    last = List.last(path)

    if last == :end do
      [path]
    else
      connections
      |> Enum.filter(&traversable?(&1, path))
      |> Enum.map(fn {_, destination} -> path ++ [destination] end)
    end
  end

  @spec traversable?({atom, atom}, [atom]) :: boolean
  @doc """
  Check if a destination cave is traversable.

  ## Examples

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :b},
      ...>   [:start, :A, :b, :A]
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :c},
      ...>   [:start, :A, :b, :A]
      ...> )
      true

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :start},
      ...>   [:start, :A, :b, :A]
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :end},
      ...>   [:start, :A, :b, :A]
      ...> )
      true

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:b, :start},
      ...>   [:start, :A, :b, :A]
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:b, :end},
      ...>   [:start, :A, :b, :A]
      ...> )
      false

  """
  def traversable?(connection, path) do
    last = List.last(path)

    case connection do
      {origin, :start} when origin == last ->
        false

      {origin, :end} when origin == last ->
        true

      {origin, destination} when origin == last ->
        small? =
          destination
          |> Atom.to_string()
          |> then(&(String.downcase(&1) == &1))

        not (small? and Enum.any?(path, &(&1 == destination)))

      _ ->
        false
    end
  end
end
