defmodule Advent2021.Pathfinding do
  @moduledoc """
  Documentation for `Advent2021.Pathfinding`.
  """

  import Advent2021.Reader

  @spec count_paths(String.t(), non_neg_integer) :: non_neg_integer
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

      iex> Advent2021.Pathfinding.count_paths("lib/12/example-1.txt", 2)
      36

      iex> Advent2021.Pathfinding.count_paths("lib/12/example-2.txt", 2)
      103

      iex> Advent2021.Pathfinding.count_paths("lib/12/example-3.txt", 2)
      3509

  """
  def count_paths(input_path, max_small_visits \\ 1) do
    input_path
    |> parse_input(&parse_connection/1)
    |> List.flatten()
    |> find_paths(max_small_visits)
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

  @spec find_paths([{atom, atom}], non_neg_integer, [[atom]]) :: [[atom]]
  @doc """
  Find all possible paths from start to end.

  ## Examples

      iex> Advent2021.Pathfinding.find_paths(
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
      ...>   1
      ...> )
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

      iex> Advent2021.Pathfinding.find_paths(
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
      ...>   2
      ...> )
      [
        [:start, :A, :b, :A, :b, :A, :c, :A, :end],
        [:start, :A, :b, :A, :b, :A, :end],
        [:start, :A, :b, :A, :b, :end],
        [:start, :A, :b, :A, :c, :A, :b, :A, :end],
        [:start, :A, :b, :A, :c, :A, :b, :end],
        [:start, :A, :b, :A, :c, :A, :c, :A, :end],
        [:start, :A, :b, :A, :c, :A, :end],
        [:start, :A, :b, :A, :end],
        [:start, :A, :b, :d, :b, :A, :c, :A, :end],
        [:start, :A, :b, :d, :b, :A, :end],
        [:start, :A, :b, :d, :b, :end],
        [:start, :A, :b, :end],
        [:start, :A, :c, :A, :b, :A, :b, :A, :end],
        [:start, :A, :c, :A, :b, :A, :b, :end],
        [:start, :A, :c, :A, :b, :A, :c, :A, :end],
        [:start, :A, :c, :A, :b, :A, :end],
        [:start, :A, :c, :A, :b, :d, :b, :A, :end],
        [:start, :A, :c, :A, :b, :d, :b, :end],
        [:start, :A, :c, :A, :b, :end],
        [:start, :A, :c, :A, :c, :A, :b, :A, :end],
        [:start, :A, :c, :A, :c, :A, :b, :end],
        [:start, :A, :c, :A, :c, :A, :end],
        [:start, :A, :c, :A, :end],
        [:start, :A, :end],
        [:start, :b, :A, :b, :A, :c, :A, :end],
        [:start, :b, :A, :b, :A, :end],
        [:start, :b, :A, :b, :end],
        [:start, :b, :A, :c, :A, :b, :A, :end],
        [:start, :b, :A, :c, :A, :b, :end],
        [:start, :b, :A, :c, :A, :c, :A, :end],
        [:start, :b, :A, :c, :A, :end],
        [:start, :b, :A, :end],
        [:start, :b, :d, :b, :A, :c, :A, :end],
        [:start, :b, :d, :b, :A, :end],
        [:start, :b, :d, :b, :end],
        [:start, :b, :end]
      ]

  """
  def find_paths(connections, max_small_visits, paths \\ [[:start]]) do
    finished? = Enum.all?(paths, &(List.last(&1) == :end))

    if finished? do
      Enum.sort(paths)
    else
      paths
      |> Enum.flat_map(&continue_path(connections, &1, max_small_visits))
      |> then(&find_paths(connections, max_small_visits, &1))
    end
  end

  @spec continue_path([{atom, atom}], [atom], non_neg_integer) :: [[atom]]
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
      ...>   [:start, :A, :b, :A],
      ...>   1
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
      ...>   [:start, :A, :b, :A, :end],
      ...>   1
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
      ...>   [:start, :A, :b, :d],
      ...>   1
      ...> )
      []

  """
  def continue_path(connections, path, max_small_visits) do
    last = List.last(path)

    if last == :end do
      [path]
    else
      connections
      |> Enum.filter(&traversable?(&1, path, max_small_visits))
      |> Enum.map(fn {_, destination} -> path ++ [destination] end)
    end
  end

  @spec traversable?({atom, atom}, [atom], non_neg_integer) :: boolean
  @doc """
  Check if a destination cave is traversable.

  ## Examples

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :b},
      ...>   [:start, :A, :b, :A],
      ...>   1
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :c},
      ...>   [:start, :A, :b, :A],
      ...>   1
      ...> )
      true

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :start},
      ...>   [:start, :A, :b, :A],
      ...>   1
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :end},
      ...>   [:start, :A, :b, :A],
      ...>   1
      ...> )
      true

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:b, :start},
      ...>   [:start, :A, :b, :A],
      ...>   1
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:b, :end},
      ...>   [:start, :A, :b, :A],
      ...>   1
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :b},
      ...>   [:start, :A, :b, :A],
      ...>   3
      ...> )
      true

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :b},
      ...>   [:start, :A, :b, :A, :b, :A],
      ...>   3
      ...> )
      true

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :b},
      ...>   [:start, :A, :b, :A, :b, :A, :b, :A],
      ...>   3
      ...> )
      false

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :c},
      ...>   [:start, :A, :b, :A, :c, :A],
      ...>   3
      ...> )
      true

      iex> Advent2021.Pathfinding.traversable?(
      ...>   {:A, :c},
      ...>   [:start, :A, :b, :A, :b, :A, :c, :A],
      ...>   3
      ...> )
      false

  """
  def traversable?(connection, path, max_small_visits) do
    last = List.last(path)

    case connection do
      {origin, :start} when origin == last ->
        false

      {origin, :end} when origin == last ->
        true

      {origin, destination} when origin == last ->
        revisiting? = Enum.any?(path, &(&1 == destination))

        previous_visit_counts = Enum.frequencies(path)

        visited_another_small_cave_twice? =
          previous_visit_counts
          |> Map.filter(fn {cave, _} ->
            cave != destination && small_cave?(cave)
          end)
          |> Map.values()
          |> Enum.any?(&(&1 > 1))

        cond do
          not small_cave?(destination) -> true
          not revisiting? -> true
          visited_another_small_cave_twice? -> false
          previous_visit_counts[destination] >= max_small_visits -> false
          true -> true
        end

      _ ->
        false
    end
  end

  @spec small_cave?(atom) :: boolean
  @doc """
  Check if a cave is small.

  ## Examples

      iex> Advent2021.Pathfinding.small_cave?(:start)
      false

      iex> Advent2021.Pathfinding.small_cave?(:end)
      false

      iex> Advent2021.Pathfinding.small_cave?(:ab)
      true

      iex> Advent2021.Pathfinding.small_cave?(:b)
      true

      iex> Advent2021.Pathfinding.small_cave?(:A)
      false

      iex> Advent2021.Pathfinding.small_cave?(:AB)
      false

  """
  def small_cave?(cave) do
    case cave do
      :start ->
        false

      :end ->
        false

      _ ->
        cave
        |> Atom.to_string()
        |> then(&(String.downcase(&1) == &1))
    end
  end
end
