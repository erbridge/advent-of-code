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
end
