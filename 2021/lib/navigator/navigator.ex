defmodule Advent2021.Navigator do
  @moduledoc """
  Documentation for `Advent2021.Navigator`.
  """

  @spec final_position(binary) :: {integer, integer}
  @doc """
  Find the final position after following the commands in the input file.

  ## Examples

      iex> Advent2021.Navigator.final_position("02/example.txt")
      {15, 10}

  """
  def final_position(input_path) do
    input = read_input(input_path)
    commands = parse_commands(input)
    position_after(commands)
  end

  @spec read_input(binary) :: :eof | binary | [binary | char] | {:error, any}
  @doc """
  Read the input from the input path.

  ## Examples

      iex> Advent2021.Navigator.read_input("02/example.txt")
      "forward 5\\ndown 5\\nforward 8\\nup 3\\ndown 8\\nforward 2\\n"

  """
  def read_input(path) do
    {:ok, file} = File.open(path, [:read])
    IO.read(file, :eof)
  end

  @spec parse_commands(binary) :: [{:forward | :down | :up, integer}]
  @doc """
  Parse the raw input into a list of commands.

  ## Examples

      iex> Advent2021.Navigator.parse_commands("forward 1\\ndown 2\\nup 3\\n")
      [{:forward, 1}, {:down, 2}, {:up, 3}]

  """
  def parse_commands(input) do
    trimmed_input = String.trim(input)
    command_strings = String.split(trimmed_input, "\n")

    Enum.map(
      command_strings,
      fn command ->
        [direction, distance] = String.split(command)
        {String.to_atom(direction), String.to_integer(distance)}
      end
    )
  end

  @spec position_after(
          [{:forward | :down | :up, integer}],
          false | nil | non_neg_integer
        ) :: {integer, integer}
  @doc """
  Find the coordinates after following a series of commands.

  ## Examples

      iex> Advent2021.Navigator.position_after(
      ...>   [{:forward, 1}, {:down, 2}, {:up, 3}]
      ...> )
      {1, -1}

      iex> Advent2021.Navigator.position_after(
      ...>   [{:forward, 1}, {:down, 2}, {:up, 3}],
      ...>   2
      ...> )
      {1, 2}

  """
  def position_after(commands, count \\ nil) do
    included_commands =
      if count,
        do: Enum.slice(commands, 0, count),
        else: commands

    Enum.reduce(included_commands, {0, 0}, fn command, acc ->
      {horizontal, depth} = acc

      case command do
        {:forward, distance} -> {horizontal + distance, depth}
        {:down, distance} -> {horizontal, depth + distance}
        {:up, distance} -> {horizontal, depth - distance}
      end
    end)
  end
end
