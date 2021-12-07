defmodule Advent2021.Vents do
  @moduledoc """
  Documentation for `Advent2021.Vents`.
  """

  defmodule Vent do
    @moduledoc """
    Documentation for `Advent2021.Vents.Vent`.
    """

    @type point :: {integer, integer}
    @type t :: %Vent{first: point, last: point}

    @enforce_keys [:first, :last]
    defstruct [:first, :last]

    @spec parse(String.t()) :: t()
    @doc """
    Create a vent from an input string.

    ## Examples

        iex> Advent2021.Vents.Vent.parse("1,1 -> 1,5")
        %Advent2021.Vents.Vent{first: {1, 1}, last: {1, 5}}

    """
    def parse(input) do
      [first, last] =
        input
        |> String.split(" -> ")
        |> Enum.map(fn point ->
          point
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
        end)
        |> Enum.map(&List.to_tuple/1)

      %Vent{first: first, last: last}
    end

    @spec points(t(), exclude_diagonals: boolean) :: [point]
    @doc """
    Count the number of measurements larger than the previous one in the input
    file.

    ## Examples

        iex> Advent2021.Vents.Vent.points(
        ...>   %Advent2021.Vents.Vent{first: {1, 2}, last: {1, 5}},
        ...>   exclude_diagonals: true
        ...> )
        [{1, 2}, {1, 3}, {1, 4}, {1, 5}]

        iex> Advent2021.Vents.Vent.points(
        ...>   %Advent2021.Vents.Vent{first: {1, 5}, last: {1, 2}},
        ...>   exclude_diagonals: true
        ...> )
        [{1, 5}, {1, 4}, {1, 3}, {1, 2}]

        iex> Advent2021.Vents.Vent.points(
        ...>   %Advent2021.Vents.Vent{first: {2, 1}, last: {5, 1}},
        ...>   exclude_diagonals: true
        ...> )
        [{2, 1}, {3, 1}, {4, 1}, {5, 1}]

        iex> Advent2021.Vents.Vent.points(
        ...>   %Advent2021.Vents.Vent{first: {5, 1}, last: {2, 1}},
        ...>   exclude_diagonals: true
        ...> )
        [{5, 1}, {4, 1}, {3, 1}, {2, 1}]

        iex> Advent2021.Vents.Vent.points(
        ...>   %Advent2021.Vents.Vent{first: {1, 1}, last: {5, 5}},
        ...>   exclude_diagonals: true
        ...> )
        []

        iex> Advent2021.Vents.Vent.points(
        ...>   %Advent2021.Vents.Vent{first: {1, 1}, last: {5, 5}},
        ...>   exclude_diagonals: false
        ...> )
        [{1, 1}, {2, 2}, {3, 3}, {4, 4}, {5, 5}]

    """
    def points(vent, exclude_diagonals: exclude_diagonals) do
      {x1, y1} = vent.first
      {x2, y2} = vent.last

      cond do
        x1 == x2 ->
          Enum.map(y1..y2, &{x1, &1})

        y1 == y2 ->
          Enum.map(x1..x2, &{&1, y1})

        abs(x2 - x1) == abs(y2 - y1) ->
          if exclude_diagonals do
            []
          else
            Enum.zip(x1..x2, y1..y2)
          end
      end
    end
  end

  import Advent2021.Reader

  @spec count_intersections(
          String.t(),
          exclude_diagonals: boolean
        ) :: non_neg_integer
  @doc """
  Count the number of points where at least the threshold vents intersect.

  ## Examples

      iex> Advent2021.Vents.count_intersections(
      ...>   "lib/05/example.txt",
      ...>   exclude_diagonals: true
      ...> )
      5

      iex> Advent2021.Vents.count_intersections("lib/05/example.txt")
      12

  """
  def count_intersections(
        input_path,
        [exclude_diagonals: exclude_diagonals] \\ [exclude_diagonals: false]
      ) do
    input_path
    |> parse_input(&Vent.parse/1)
    |> all_intersections(exclude_diagonals: exclude_diagonals)
    |> Enum.count()
  end

  @spec all_intersections(
          [Vent.t()],
          exclude_diagonals: boolean
        ) :: [Vent.point()]
  @doc """
  Find all intersections of a set of vents.

  ## Examples

      iex> Advent2021.Vents.all_intersections(
      ...>   [
      ...>     %Advent2021.Vents.Vent{first: {1, 0}, last: {1, 5}},
      ...>     %Advent2021.Vents.Vent{first: {1, 2}, last: {1, 3}},
      ...>     %Advent2021.Vents.Vent{first: {0, 3}, last: {5, 3}},
      ...>     %Advent2021.Vents.Vent{first: {1, 1}, last: {5, 5}},
      ...>   ],
      ...>   exclude_diagonals: true
      ...> )
      [{1, 2}, {1, 3}]

      iex> Advent2021.Vents.all_intersections(
      ...>   [
      ...>     %Advent2021.Vents.Vent{first: {1, 0}, last: {1, 5}},
      ...>     %Advent2021.Vents.Vent{first: {1, 2}, last: {1, 3}},
      ...>     %Advent2021.Vents.Vent{first: {0, 3}, last: {5, 3}},
      ...>     %Advent2021.Vents.Vent{first: {1, 1}, last: {5, 5}}
      ...>   ],
      ...>   exclude_diagonals: false
      ...> )
      [{1, 1}, {1, 2}, {1, 3}, {3, 3}]

  """
  def all_intersections(vents, exclude_diagonals: exclude_diagonals) do
    vents
    |> all_points(exclude_diagonals: exclude_diagonals)
    |> Enum.frequencies()
    |> Map.filter(fn {_key, value} -> value >= 2 end)
    |> Map.keys()
  end

  @spec all_points([Vent.t()], exclude_diagonals: boolean) :: [Vent.point()]
  @doc """
  Break all the vents down into a set of points.

  ## Examples

      iex> Advent2021.Vents.all_points(
      ...>   [
      ...>     %Advent2021.Vents.Vent{first: {1, 2}, last: {1, 5}},
      ...>     %Advent2021.Vents.Vent{first: {2, 1}, last: {5, 1}}
      ...>   ],
      ...>   exclude_diagonals: true
      ...> )
      [{1, 2}, {1, 3}, {1, 4}, {1, 5}, {2, 1}, {3, 1}, {4, 1}, {5, 1}]

  """
  def all_points(vents, exclude_diagonals: exclude_diagonals) do
    vents
    |> Enum.map(&Vent.points(&1, exclude_diagonals: exclude_diagonals))
    |> List.flatten()
  end
end
