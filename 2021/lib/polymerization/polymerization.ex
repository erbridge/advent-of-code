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
      ...>   10
      ...> )
      {161, 1749}

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

    rules =
      input_rules_path
      |> parse_input(&parse_rule/1)
      |> Map.new()

    polymerize(template, rules, steps)
    |> Enum.frequencies()
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
          [String.t()],
          %{String.t() => String.t()},
          non_neg_integer
        ) :: [String.t()]
  @doc """
  Parse a connection.

  ## Examples

      iex> Advent2021.Polymerization.polymerize(
      ...>   ["N", "N", "C", "B"],
      ...>   %{
      ...>     "CH" => "B",
      ...>     "HH" => "N",
      ...>     "CB" => "H",
      ...>     "NH" => "C",
      ...>     "HB" => "C",
      ...>     "HC" => "B",
      ...>     "HN" => "C",
      ...>     "NN" => "C",
      ...>     "BH" => "H",
      ...>     "NC" => "B",
      ...>     "NB" => "B",
      ...>     "BN" => "B",
      ...>     "BB" => "N",
      ...>     "BC" => "B",
      ...>     "CC" => "N",
      ...>     "CN" => "C"
      ...>   },
      ...>   1
      ...> )
      ["N", "C", "N", "B", "C", "H", "B"]

      iex> Advent2021.Polymerization.polymerize(
      ...>   ["N", "N", "C", "B"],
      ...>   %{
      ...>     "CH" => "B",
      ...>     "HH" => "N",
      ...>     "CB" => "H",
      ...>     "NH" => "C",
      ...>     "HB" => "C",
      ...>     "HC" => "B",
      ...>     "HN" => "C",
      ...>     "NN" => "C",
      ...>     "BH" => "H",
      ...>     "NC" => "B",
      ...>     "NB" => "B",
      ...>     "BN" => "B",
      ...>     "BB" => "N",
      ...>     "BC" => "B",
      ...>     "CC" => "N",
      ...>     "CN" => "C"
      ...>   },
      ...>   2
      ...> )
      ["N", "B", "C", "C", "N", "B", "B", "B", "C", "B", "H", "C", "B"]

  """
  def polymerize(template, _, 0) do
    template
  end

  def polymerize(template, rules, steps) do
    template
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(fn pair ->
      insertion =
        pair
        |> Enum.join()
        |> then(&Map.get(rules, &1))

      if insertion do
        [List.first(pair), insertion]
      else
        [List.first(pair)]
      end
    end)
    |> polymerize(rules, steps - 1)
  end
end
