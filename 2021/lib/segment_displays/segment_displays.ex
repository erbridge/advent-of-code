defmodule Advent2021.SegmentDisplays do
  @moduledoc """
  Documentation for `Advent2021.SegmentDisplays`.
  """

  import Advent2021.Reader

  @spec count_unique_outputs(String.t()) :: non_neg_integer
  @doc """
  Count the number of 1, 4, 7, and 8 digits in the output displays.

  ## Examples

      iex> Advent2021.SegmentDisplays.count_unique_outputs("lib/08/example.txt")
      26

  """
  def count_unique_outputs(input_path) do
    input_path
    |> parse_input(&parse_display/1)
    |> Enum.map(&Map.fetch!(&1, :output))
    |> Enum.map(fn output ->
      Enum.count(output, &unique?/1)
    end)
    |> Enum.sum()
  end

  @spec parse_display(String.t()) :: %{
          patterns: [[String.t()]],
          output: [[String.t()]]
        }
  @doc """
  Parse the input display.

  ## Examples

      iex> Advent2021.SegmentDisplays.parse_display(
      ...>   "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | " <>
      ...>     "fdgacbe cefdb cefbgd gcbe"
      ...> )
      %{
        output: [
          ["a", "b", "c", "d", "e", "f", "g"],
          ["b", "c", "d", "e", "f"],
          ["b", "c", "d", "e", "f", "g"],
          ["b", "c", "e", "g"],
        ],
        patterns: [
          ["b", "e"],
          ["a", "b", "c", "d", "e", "f", "g"],
          ["b", "c", "d", "e", "f", "g"],
          ["a", "c", "d", "e", "f", "g"],
          ["b", "c", "e", "g"],
          ["c", "d", "e", "f", "g"],
          ["a", "b", "d", "e", "f", "g"],
          ["b", "c", "d", "e", "f"],
          ["a", "b", "c", "d", "f"],
          ["b", "d", "e"]
        ]
      }

  """
  def parse_display(input) do
    input
    |> String.split("|")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn pattern ->
      Enum.map(pattern, &String.split(&1, "", trim: true))
    end)
    |> Enum.map(fn pattern -> Enum.map(pattern, &Enum.sort/1) end)
    |> then(&%{patterns: List.first(&1), output: List.last(&1)})
  end

  @spec unique?([String.t()]) :: boolean
  @doc """
  Check if the pattern matches one of the digits 1, 4, 7, or 8.

  ## Examples

      iex> Advent2021.SegmentDisplays.unique?(["b", "e"])
      true

      iex> Advent2021.SegmentDisplays.unique?(["b", "c", "e", "g"])
      true

      iex> Advent2021.SegmentDisplays.unique?(["b", "d", "e"])
      true

      iex> Advent2021.SegmentDisplays.unique?(
      ...>   ["a", "b", "c", "d", "e", "f", "g"]
      ...> )
      true

      iex> Advent2021.SegmentDisplays.unique?(["b", "c", "d", "e", "f", "g"])
      false

  """
  def unique?(pattern) do
    one?(pattern) or four?(pattern) or seven?(pattern) or eight?(pattern)
  end

  @spec one?([String.t()]) :: boolean
  @doc """
  Check if the pattern matches the digit 1.

  ## Examples

      iex> Advent2021.SegmentDisplays.one?(["b", "e"])
      true

      iex> Advent2021.SegmentDisplays.one?(["a", "b", "c", "d", "e", "f", "g"])
      false

  """
  def one?(pattern) do
    length(pattern) == 2
  end

  @spec four?([String.t()]) :: boolean
  @doc """
  Check if the pattern matches the digit 4.

  ## Examples

      iex> Advent2021.SegmentDisplays.four?(["b", "c", "e", "g"])
      true

      iex> Advent2021.SegmentDisplays.four?(["a", "b", "c", "d", "e", "f", "g"])
      false

  """
  def four?(pattern) do
    length(pattern) == 4
  end

  @spec seven?([String.t()]) :: boolean
  @doc """
  Check if the pattern matches the digit 7.

  ## Examples

      iex> Advent2021.SegmentDisplays.seven?(["b", "d", "e"])
      true

      iex> Advent2021.SegmentDisplays.seven?(
      ...>   ["a", "b", "c", "d", "e", "f", "g"]
      ...> )
      false

  """
  def seven?(pattern) do
    length(pattern) == 3
  end

  @spec eight?([String.t()]) :: boolean
  @doc """
  Check if the pattern matches the digit 8.

  ## Examples

      iex> Advent2021.SegmentDisplays.eight?(
      ...>   ["a", "b", "c", "d", "e", "f", "g"]
      ...> )
      true

      iex> Advent2021.SegmentDisplays.eight?(["b", "c", "e", "g"])
      false

  """
  def eight?(pattern) do
    length(pattern) == 7
  end
end
