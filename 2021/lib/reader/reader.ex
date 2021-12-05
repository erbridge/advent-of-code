defmodule Advent2021.Reader do
  @spec read_input(String.t()) :: [String.t()]
  @doc """
  Read the input from the input path and split by lines.

  ## Examples

      iex> Advent2021.Reader.read_input("lib/01/example.txt")
      ["199", "200", "208", "210", "200", "207", "240", "269", "260", "263"]

  """
  def read_input(path) do
    path
    |> read_input_stream()
    |> Enum.to_list()
  end

  @spec parse_input(String.t(), (String.t() -> term)) :: [term]
  @doc """
  Read the input from the input path and parse each line with the parser.

  ## Examples

      iex> Advent2021.Reader.parse_input(
      ...>   "lib/01/example.txt",
      ...>   &String.to_integer/1
      ...> )
      [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

  """
  def parse_input(path, parser) do
    path
    |> read_input_stream()
    |> Enum.map(parser)
  end

  defp read_input_stream(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
