defmodule Advent2021.Sonar do
  @moduledoc """
  Documentation for `Advent2021.Sonar`.
  """

  @spec count_depth_increases(binary) :: non_neg_integer
  @doc """
  Count the number of measurements larger than the previous one in the input
  file.

  ## Examples

      iex> Advent2021.Sonar.count_depth_increases("01/example.txt")
      7

  """
  def count_depth_increases(input_path) do
    input = read_input(input_path)
    measurements = parse_depths(input)
    changes = depth_changes(measurements)
    Enum.count(changes, fn change -> change == :increase end)
  end

  @spec read_input(binary) :: :eof | binary | [binary | char] | {:error, any}
  @doc """
  Read the input from the input path.

  ## Examples

      iex> Advent2021.Sonar.read_input("01/example.txt")
      "199\\n200\\n208\\n210\\n200\\n207\\n240\\n269\\n260\\n263\\n"

  """
  def read_input(path) do
    {:ok, file} = File.open(path, [:read])
    IO.read(file, :eof)
  end

  @spec parse_depths(binary) :: [integer]
  @doc """
  Parse the raw input into a list.

  ## Examples

      iex> Advent2021.Sonar.parse_depths("100\\n200\\n300\\n")
      [100, 200, 300]

  """
  def parse_depths(input) do
    lines = String.split(input)
    Enum.map(lines, fn line -> String.to_integer(line) end)
  end

  @spec depth_changes([integer]) :: [:increase | :decrease | :equal]
  @doc """
  Convert the list of measurements into a list of :increase, :decrease, and
  :equal based on the change between values.

  ## Examples

      iex> Advent2021.Sonar.depth_changes([100, 101, 99])
      [:increase, :decrease]

  """
  def depth_changes(measurements) do
    Enum.zip_with(
      measurements,
      Enum.slice(measurements, 1, length(measurements)),
      fn a, b ->
        depth_change(a, b)
      end
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
