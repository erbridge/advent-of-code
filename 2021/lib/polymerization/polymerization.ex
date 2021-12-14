defmodule Advent2021.Polymerization do
  @moduledoc """
  Documentation for `Advent2021.Polymerization`.
  """

  import Advent2021.Reader

  @spec min_max_elements_after_polymerization(
          String.t(),
          String.t(),
          pos_integer
        ) :: {non_neg_integer, non_neg_integer}
  @doc """
  Count the least and most often occuring elements after executing the given
  number of steps.

  ## Examples

      iex> Advent2021.Polymerization.min_max_elements_after_polymerization(
      ...>   "lib/14/example_template.txt",
      ...>   "lib/14/example_rules.txt",
      ...>   4
      ...> )
      {5, 23}

      iex> Advent2021.Polymerization.min_max_elements_after_polymerization(
      ...>   "lib/14/example_template.txt",
      ...>   "lib/14/example_rules.txt",
      ...>   10
      ...> )
      {161, 1749}

      iex> Advent2021.Polymerization.min_max_elements_after_polymerization(
      ...>   "lib/14/example_template.txt",
      ...>   "lib/14/example_rules.txt",
      ...>   40
      ...> )
      {3849876073, 2192039569602}

  """
  def min_max_elements_after_polymerization(
        input_template_path,
        input_rules_path,
        steps
      ) do
    template =
      input_template_path
      |> parse_input(&parse_template/1)
      |> List.first()

    pairs =
      template
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&Enum.join/1)
      |> Enum.sort()
      |> Enum.frequencies()

    rules =
      input_rules_path
      |> parse_input(&parse_rule/1)
      |> Enum.sort()
      |> Map.new()

    polymerize(pairs, rules, steps)
    |> Map.to_list()
    |> Enum.reduce(
      %{List.last(template) => 1},
      fn {pair, count}, acc ->
        pair
        |> String.first()
        |> then(&Map.update(acc, &1, count, fn value -> value + count end))
      end
    )
    |> Map.values()
    |> Enum.sort()
    |> then(&{List.first(&1), List.last(&1)})
  end

  @spec parse_template(String.t()) :: [String.t()]
  @doc """
  Parse a connection.

  ## Examples

      iex> Advent2021.Polymerization.parse_template("NNCB")
      ["N", "N", "C", "B"]

  """
  def parse_template(input) do
    input
    |> String.split("", trim: true)
  end

  @spec parse_rule(String.t()) :: {String.t(), String.t()}
  @doc """
  Parse a connection.

  ## Examples

      iex> Advent2021.Polymerization.parse_rule("CH -> B")
      {"CH", "B"}

  """
  def parse_rule(input) do
    input
    |> String.split(" -> ")
    |> List.to_tuple()
  end

  @spec polymerize(
          %{String.t() => non_neg_integer},
          %{String.t() => String.t()},
          non_neg_integer
        ) :: %{String.t() => non_neg_integer}
  @doc """
  Parse a connection.

  ## Examples

      iex> Advent2021.Polymerization.polymerize(
      ...>   %{
      ...>     "CB" => 1,
      ...>     "NC" => 1,
      ...>     "NN" => 1
      ...>   },
      ...>   %{
      ...>     "BB" => "N",
      ...>     "BC" => "B",
      ...>     "BH" => "H",
      ...>     "BN" => "B",
      ...>     "CB" => "H",
      ...>     "CC" => "N",
      ...>     "CH" => "B",
      ...>     "CN" => "C",
      ...>     "HB" => "C",
      ...>     "HC" => "B",
      ...>     "HH" => "N",
      ...>     "HN" => "C",
      ...>     "NB" => "B",
      ...>     "NC" => "B",
      ...>     "NH" => "C",
      ...>     "NN" => "C"
      ...>   },
      ...>   1
      ...> )
      %{
        "BC" => 1,
        "CH" => 1,
        "CN" => 1,
        "HB" => 1,
        "NB" => 1,
        "NC" => 1
      }

      iex> Advent2021.Polymerization.polymerize(
      ...>   %{
      ...>     "CB" => 1,
      ...>     "NC" => 1,
      ...>     "NN" => 1
      ...>   },
      ...>   %{
      ...>     "BB" => "N",
      ...>     "BC" => "B",
      ...>     "BH" => "H",
      ...>     "BN" => "B",
      ...>     "CB" => "H",
      ...>     "CC" => "N",
      ...>     "CH" => "B",
      ...>     "CN" => "C",
      ...>     "HB" => "C",
      ...>     "HC" => "B",
      ...>     "HH" => "N",
      ...>     "HN" => "C",
      ...>     "NB" => "B",
      ...>     "NC" => "B",
      ...>     "NH" => "C",
      ...>     "NN" => "C"
      ...>   },
      ...>   2
      ...> )
      %{
        "BB" => 2,
        "BC" => 2,
        "BH" => 1,
        "CB" => 2,
        "CC" => 1,
        "CN" => 1,
        "HC" => 1,
        "NB" => 2
      }

  """
  def polymerize(pairs, _, 0) do
    pairs
    |> Map.to_list()
    |> Enum.sort()
    |> Map.new()
  end

  def polymerize(pairs, rules, steps) do
    pairs
    |> Map.to_list()
    |> Enum.reduce(
      %{},
      fn {pair, count}, acc ->
        insertion = Map.get(rules, pair)

        acc
        |> Map.update(
          String.first(pair) <> insertion,
          count,
          fn value -> value + count end
        )
        |> Map.update(
          insertion <> String.last(pair),
          count,
          fn value -> value + count end
        )
      end
    )
    |> polymerize(rules, steps - 1)
  end
end
