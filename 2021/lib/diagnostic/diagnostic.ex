defmodule Advent2021.Diagnostic do
  @moduledoc """
  Documentation for `Advent2021.Diagnostic`.
  """

  import Advent2021.Reader

  @spec power_consumption(String.t()) :: integer
  @doc """
  Find the power consumption from the diagnostic report.

  ## Examples

      iex> Advent2021.Diagnostic.power_consumption("lib/03/example.txt")
      198

  """
  def power_consumption(input_path) do
    lines = parse_input(input_path, &parse_line/1)
    gamma = gamma_rate(lines)
    epsilon = epsilon_rate(lines)

    gamma * epsilon
  end

  @spec life_support_rating(String.t()) :: integer
  @doc """
  Find the life support rating from the diagnostic report.

  ## Examples

      iex> Advent2021.Diagnostic.life_support_rating("lib/03/example.txt")
      230

  """
  def life_support_rating(input_path) do
    lines = parse_input(input_path, &parse_line/1)
    oxygen = oxygen_generator_rating(lines)
    co2 = co2_scrubber_rating(lines)

    oxygen * co2
  end

  @spec parse_line(String.t()) :: [String.t()]
  @doc """
  Break a diagnostic line into its component bits.

  ## Examples

      iex> Advent2021.Diagnostic.parse_line("00100")
      ["0", "0", "1", "0", "0"]

  """
  def parse_line(input) do
    input
    |> String.split("", trim: true)
  end

  @spec gamma_rate([[String.t()]]) :: non_neg_integer
  @doc """
  Find the gamma rate.

  ## Examples

      iex> Advent2021.Diagnostic.gamma_rate(
      ...>   [
      ...>     [0, 0, 1, 0, 0],
      ...>     [1, 1, 1, 1, 0],
      ...>     [1, 0, 1, 1, 0],
      ...>     [0, 0, 0, 0, 0],
      ...>     [1, 1, 1, 1, 1]
      ...>   ]
      ...> )
      0b10110

  """
  def gamma_rate(lines) do
    rate(lines, &Enum.max_by/2)
  end

  @spec epsilon_rate([[String.t()]]) :: non_neg_integer
  @doc """
  Find the epsilon rate.

  ## Examples

      iex> Advent2021.Diagnostic.epsilon_rate(
      ...>   [
      ...>     [0, 0, 1, 0, 0],
      ...>     [1, 1, 1, 1, 0],
      ...>     [1, 0, 1, 1, 0],
      ...>     [0, 0, 0, 0, 0],
      ...>     [1, 1, 1, 1, 1]
      ...>   ]
      ...> )
      0b01001

  """
  def epsilon_rate(lines) do
    rate(lines, &Enum.min_by/2)
  end

  @spec oxygen_generator_rating([[String.t()]]) :: non_neg_integer
  @doc """
  Find the oxygen generator rating.

  ## Examples

      # iex> Advent2021.Diagnostic.oxygen_generator_rating(
      # ...>   [
      # ...>     [0, 0, 1, 0, 0],
      # ...>     [1, 1, 1, 1, 0],
      # ...>     [1, 0, 1, 1, 0],
      # ...>     [0, 0, 0, 0, 0],
      # ...>     [1, 1, 1, 1, 1]
      # ...>   ]
      # ...> )
      # 0b11111

  """
  def oxygen_generator_rating(lines) do
    select(lines, 1, &Enum.max_by/2)
  end

  @spec co2_scrubber_rating([[String.t()]]) :: non_neg_integer
  @doc """
  Find the CO2 srubber rating.

  ## Examples

      # iex> Advent2021.Diagnostic.co2_scrubber_rating(
      # ...>   [
      # ...>     [0, 0, 1, 0, 0],
      # ...>     [1, 1, 1, 1, 0],
      # ...>     [1, 0, 1, 1, 0],
      # ...>     [0, 0, 0, 0, 0],
      # ...>     [1, 1, 1, 1, 1]
      # ...>   ]
      # ...> )
      # 0b00000

  """
  def co2_scrubber_rating(lines) do
    select(lines, 0, &Enum.min_by/2)
  end

  defp rate(lines, minmaxer) do
    lines
    |> Stream.zip_with(fn bits ->
      bits
      |> Enum.frequencies()
      |> minmaxer.(fn {_bit, frequency} -> frequency end)
      |> elem(0)
    end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp select(lines, tiebreaker, minmaxer, index \\ 0)

  defp select(lines, tiebreaker, minmaxer, index) when length(lines) > 1 do
    indexed_bits =
      lines
      |> Enum.map(
        &(&1
          |> List.pop_at(index)
          |> elem(0))
      )
      |> Enum.with_index()

    bit_frequencies = Enum.frequencies_by(indexed_bits, &elem(&1, 0))

    tie? =
      bit_frequencies
      |> Map.values()
      |> then(
        &if length(&1) > 1 do
          &1
          |> Enum.uniq()
          |> length == 1
        end
      )

    selected_bit =
      if tie? do
        tiebreaker
        |> Integer.to_string()
      else
        bit_frequencies
        |> minmaxer.(fn {_bit, frequency} -> frequency end)
        |> elem(0)
      end

    selected_indices =
      indexed_bits
      |> Enum.filter(fn {bit, _i} -> bit == selected_bit end)
      |> Enum.map(&elem(&1, 1))
      |> tap(&if length(&1) < 1, do: raise("No index: #{Enum.join(lines, ",")}"))

    lines
    |> Enum.with_index()
    |> Enum.filter(fn {_line, i} -> Enum.member?(selected_indices, i) end)
    |> Enum.map(&elem(&1, 0))
    |> select(tiebreaker, minmaxer, index + 1)
  end

  defp select(lines, _tiebreaker, _minmaxer, _index) do
    lines
    |> List.pop_at(0)
    |> elem(0)
    |> Enum.join()
    |> String.to_integer(2)
  end
end
