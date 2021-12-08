defmodule Advent2021.SegmentDisplays do
  @moduledoc """
  Documentation for `Advent2021.SegmentDisplays`.
  """

  import Advent2021.Reader

  @spec sum_outputs(String.t()) :: non_neg_integer
  @doc """
  Return the sum of the output displays.

  ## Examples

      iex> Advent2021.SegmentDisplays.sum_outputs("lib/08/example.txt")
      61229

  """
  def sum_outputs(input_path) do
    input_path
    |> parse_input(&parse_display/1)
    |> Enum.map(fn %{patterns: patterns, output: output} ->
      decode(patterns, output)
    end)
    |> Enum.sum()
  end

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

  @spec decode([String.t()], [String.t()]) :: non_neg_integer
  @doc """
  Decode the display from the pattern list.

  ## Examples

      iex> Advent2021.SegmentDisplays.decode(
      ...>   [
      ...>     ["b", "e"],
      ...>     ["a", "b", "c", "d", "e", "f", "g"],
      ...>     ["b", "c", "d", "e", "f", "g"],
      ...>     ["a", "c", "d", "e", "f", "g"],
      ...>     ["b", "c", "e", "g"],
      ...>     ["c", "d", "e", "f", "g"],
      ...>     ["a", "b", "d", "e", "f", "g"],
      ...>     ["b", "c", "d", "e", "f"],
      ...>     ["a", "b", "c", "d", "f"],
      ...>     ["b", "d", "e"]
      ...>   ],
      ...>   [
      ...>     ["a", "b", "c", "d", "e", "f", "g"],
      ...>     ["b", "c", "d", "e", "f"],
      ...>     ["b", "c", "d", "e", "f", "g"],
      ...>     ["b", "c", "e", "g"],
      ...>   ]
      ...> )
      8394

  """
  def decode(patterns, display) do
    pattern_codex = codex(patterns)

    display
    |> Enum.map(fn digit -> Enum.find_index(pattern_codex, &(&1 == digit)) end)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join()
    |> String.to_integer()
  end

  @spec codex([String.t()]) :: [[String.t()]]
  @doc """
  Create a codex to map patterns to the digits they represent.

  ## Examples

      iex> Advent2021.SegmentDisplays.codex([
      ...>   ["b", "e"],
      ...>   ["a", "b", "c", "d", "e", "f", "g"],
      ...>   ["b", "c", "d", "e", "f", "g"],
      ...>   ["a", "c", "d", "e", "f", "g"],
      ...>   ["b", "c", "e", "g"],
      ...>   ["c", "d", "e", "f", "g"],
      ...>   ["a", "b", "d", "e", "f", "g"],
      ...>   ["b", "c", "d", "e", "f"],
      ...>   ["a", "b", "c", "d", "f"],
      ...>   ["b", "d", "e"]
      ...> ])
      [
        ["a", "b", "d", "e", "f", "g"],
        ["b", "e"],
        ["a", "b", "c", "d", "f"],
        ["b", "c", "d", "e", "f"],
        ["b", "c", "e", "g"],
        ["c", "d", "e", "f", "g"],
        ["a", "c", "d", "e", "f", "g"],
        ["b", "d", "e"],
        ["a", "b", "c", "d", "e", "f", "g"],
        ["b", "c", "d", "e", "f", "g"]
      ]

  """
  def codex(patterns) do
    %{
      one: one,
      four: four,
      seven: seven,
      eight: eight,
      two_three_five: two_three_five,
      zero_six_nine: zero_six_nine
    } =
      %{
        one: &one?/1,
        four: &four?/1,
        seven: &seven?/1,
        eight: &eight?/1,
        two_three_five: &two_three_five?/1,
        zero_six_nine: &zero_six_nine?/1
      }
      |> Map.map(fn {_, fun} -> Enum.filter(patterns, fun) end)
      |> Map.map(fn {_, matches} ->
        if length(matches) == 1 do
          Enum.at(matches, 0)
        else
          matches
        end
      end)

    bd = four -- one

    three =
      Enum.find(
        two_three_five,
        fn candidate -> length(candidate -- one) == 3 end
      )

    two_five = two_three_five -- [three]

    five =
      Enum.find(
        two_five,
        fn candidate -> length(candidate -- bd) == 3 end
      )

    two = List.first(two_five -- [five])

    six =
      Enum.find(
        zero_six_nine,
        fn candidate -> length(candidate -- one) == 5 end
      )

    zero_nine = zero_six_nine -- [six]

    nine =
      Enum.find(
        zero_nine,
        fn candidate -> length(candidate -- four) == 2 end
      )

    zero = List.first(zero_nine -- [nine])

    [zero, one, two, three, four, five, six, seven, eight, nine]
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

  @spec two_three_five?([String.t()]) :: boolean
  @doc """
  Check if the pattern matches one of the digits 2, 3, or 5.

  ## Examples

      iex> Advent2021.SegmentDisplays.two_three_five?(["c", "d", "e", "f", "g"])
      true

      iex> Advent2021.SegmentDisplays.two_three_five?(
      ...>   ["a", "b", "c", "d", "e", "f", "g"]
      ...> )
      false

  """
  def two_three_five?(pattern) do
    length(pattern) == 5
  end

  @spec zero_six_nine?([String.t()]) :: boolean
  @doc """
  Check if the pattern matches one of the digits 0, 6, or 9.

  ## Examples

      iex> Advent2021.SegmentDisplays.zero_six_nine?(
      ...>   ["b", "c", "d", "e", "f", "g"]
      ...> )
      true

      iex> Advent2021.SegmentDisplays.zero_six_nine?(
      ...>   ["a", "b", "c", "d", "e", "f", "g"]
      ...> )
      false

  """
  def zero_six_nine?(pattern) do
    length(pattern) == 6
  end
end
