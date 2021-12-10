defmodule Advent2021.Syntax do
  @moduledoc """
  Documentation for `Advent2021.Syntax`.
  """

  import Advent2021.Reader

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
    open_brackets = ["(", "[", "{", "<"]

    line
    |> Enum.reduce_while({:ok, [], nil}, fn char, {_, stack, last} ->
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
          {:cont, {:ok, stack ++ [char], char}}

        :close ->
          new_stack = Enum.drop(stack, -1)
          new_last = List.last(new_stack)

          {:cont, {:ok, new_stack, new_last}}

        :invalid ->
          {:halt, {:error, stack, char}}
      end
    end)
    |> then(fn {status, _, char} -> if status == :ok, do: nil, else: char end)
  end
end
