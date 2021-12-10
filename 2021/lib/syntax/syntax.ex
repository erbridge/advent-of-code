defmodule Advent2021.Syntax do
  @moduledoc """
  Documentation for `Advent2021.Syntax`.
  """

  import Advent2021.Reader

  @spec autocomplete_score(String.t()) :: [String.t()]
  @doc """
  Find autocomplete suggestions for each incomplete line.

  ## Examples

      iex> Advent2021.Syntax.autocomplete_score("lib/10/example.txt")
      288957

  """
  def autocomplete_score(input_path) do
    input_path
    |> parse_input(&parse_line/1)
    |> Enum.reject(&error_char/1)
    |> Enum.map(&autocomplete/1)
    |> Enum.map(fn {state, result} ->
      if state == :error do
        0
      else
        result
        |> Enum.reduce(0, fn char, acc ->
          acc * 5 +
            case char do
              ")" -> 1
              "]" -> 2
              "}" -> 3
              ">" -> 4
            end
        end)
      end
    end)
    |> Enum.sort()
    |> then(&Enum.at(&1, div(length(&1), 2)))
  end

  @spec error_score(String.t()) :: non_neg_integer
  @doc """
  Find the syntax error score.

  ## Examples

      iex> Advent2021.Syntax.error_score("lib/10/example.txt")
      26397

  """
  def error_score(input_path) do
    input_path
    |> parse_input(&parse_line/1)
    |> Enum.map(&error_char/1)
    |> Enum.frequencies()
    |> Map.map(fn {char, count} ->
      score =
        case char do
          nil -> 0
          ")" -> 3
          "]" -> 57
          "}" -> 1197
          ">" -> 25137
        end

      count * score
    end)
    |> Map.values()
    |> Enum.sum()
  end

  @spec parse_line(String.t()) :: [String.t()]
  @doc """
  Parse a line of the input.

  ## Examples

      iex> Advent2021.Syntax.parse_line("[({(<(())[]>[[{[]{<()<>>")
      [
        "[",
        "(",
        "{",
        "(",
        "<",
        "(",
        "(",
        ")",
        ")",
        "[",
        "]",
        ">",
        "[",
        "[",
        "{",
        "[",
        "]",
        "{",
        "<",
        "(",
        ")",
        "<",
        ">",
        ">"
      ]

  """
  def parse_line(input) do
    input
    |> String.split("", trim: true)
  end

  @spec error_char([String.t()]) :: String.t() | nil
  @doc """
  Check is a line is corrupted.

  ## Examples

      iex> Advent2021.Syntax.error_char([
      ...>   "{",
      ...>   "(",
      ...>   "[",
      ...>   "(",
      ...>   "<",
      ...>   "{",
      ...>   "}",
      ...>   "[",
      ...>   "<",
      ...>   ">",
      ...>   "[",
      ...>   "]",
      ...>   "}",
      ...>   ">",
      ...>   "{",
      ...>   "[",
      ...>   "]",
      ...>   "{",
      ...>   "[",
      ...>   "(",
      ...>   "<",
      ...>   "(",
      ...>   ")",
      ...>   ">"
      ...> ])
      "}"

      iex> Advent2021.Syntax.error_char([
      ...>   "[",
      ...>   "(",
      ...>   "{",
      ...>   "(",
      ...>   "<",
      ...>   "(",
      ...>   "(",
      ...>   ")",
      ...>   ")",
      ...>   "[",
      ...>   "]",
      ...>   ">",
      ...>   "[",
      ...>   "[",
      ...>   "{",
      ...>   "[",
      ...>   "]",
      ...>   "{",
      ...>   "<",
      ...>   "(",
      ...>   ")",
      ...>   "<",
      ...>   ">",
      ...>   ">"
      ...> ])
      nil

  """
  def error_char(line) do
    {status, result} = autocomplete(line)

    if status == :error do
      result
    end
  end

  @spec autocomplete([String.t()]) :: {:ok, [String.t()]} | {:error, String.t()}
  @doc """
  Find the set of characters to complete the line.

  ## Examples

      iex> Advent2021.Syntax.autocomplete([
      ...>   "[",
      ...>   "(",
      ...>   "{",
      ...>   "(",
      ...>   "<",
      ...>   "(",
      ...>   "(",
      ...>   ")",
      ...>   ")",
      ...>   "[",
      ...>   "]",
      ...>   ">",
      ...>   "[",
      ...>   "[",
      ...>   "{",
      ...>   "[",
      ...>   "]",
      ...>   "{",
      ...>   "<",
      ...>   "(",
      ...>   ")",
      ...>   "<",
      ...>   ">",
      ...>   ">"
      ...> ])
      {:ok, ["}", "}", "]", "]", ")", "}", ")", "]"]}

  """
  def autocomplete(line) do
    open_brackets = ["(", "[", "{", "<"]

    {state, result} =
      line
      |> Enum.reduce_while({nil, []}, fn char, {_, stack} ->
        last = List.last(stack)

        state =
          cond do
            Enum.any?(open_brackets, &(&1 == char)) -> :open
            last == "(" and char != ")" -> :invalid
            last == "[" and char != "]" -> :invalid
            last == "{" and char != "}" -> :invalid
            last == "<" and char != ">" -> :invalid
            true -> :close
          end

        case state do
          :open ->
            {:cont, {state, stack ++ [char]}}

          :close ->
            new_stack = Enum.drop(stack, -1)

            {:cont, {state, new_stack}}

          :invalid ->
            {:halt, {state, char}}
        end
      end)

    if state == :invalid do
      {:error, result}
    else
      result
      |> Enum.reverse()
      |> Enum.reduce([], fn char, acc ->
        acc ++
          [
            case char do
              "(" -> ")"
              "[" -> "]"
              "{" -> "}"
              "<" -> ">"
            end
          ]
      end)
      |> then(&{:ok, &1})
    end
  end
end
