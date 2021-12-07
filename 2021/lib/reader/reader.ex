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
    |> trim_input_stream()
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
    |> trim_input_stream()
    |> Enum.map(parser)
  end

  @spec read_input_chunks(String.t(), String.t()) :: [String.t()]
  @doc """
  Read the input from the input path split by the divider.

  ## Examples

      iex> Advent2021.Reader.read_input_chunks("lib/04/example_boards.txt")
      [
        "22 13 17 11  0\\n" <>
          " 8  2 23  4 24\\n" <>
          "21  9 14 16  7\\n" <>
          " 6 10  3 18  5\\n" <>
          " 1 12 20 15 19\\n",
        " 3 15  0  2 22\\n" <>
          " 9 18 13 17  5\\n" <>
          "19  8  7 25 23\\n" <>
          "20 11 10 24  4\\n" <>
          "14 21 16 12  6\\n",
        "14 21 17 24  4\\n" <>
          "10 16 15  9 19\\n" <>
          "18  8 23 26 20\\n" <>
          "22 11 13  6  5\\n" <>
          " 2  0 12  3  7\\n"
      ]

  """
  def read_input_chunks(path, divider \\ "\n") do
    path
    |> read_input_stream()
    |> Enum.chunk_while(
      "",
      fn line, chunk ->
        if line == divider do
          {:cont, chunk, ""}
        else
          {:cont, chunk <> line}
        end
      end,
      fn chunk -> {:cont, chunk, nil} end
    )
  end

  @spec parse_input_chunks(
          String.t(),
          (String.t() -> term),
          String.t()
        ) :: [term]
  @doc """
  Read the input from the input path and parse each section with the parser.

  ## Examples

      iex> Advent2021.Reader.parse_input_chunks(
      ...>   "lib/04/example_boards.txt",
      ...>   &String.split(&1, "\\n")
      ...> )
      [
        [
          "22 13 17 11  0",
          " 8  2 23  4 24",
          "21  9 14 16  7",
          " 6 10  3 18  5",
          " 1 12 20 15 19",
          ""
        ],
        [
          " 3 15  0  2 22",
          " 9 18 13 17  5",
          "19  8  7 25 23",
          "20 11 10 24  4",
          "14 21 16 12  6",
          ""
        ],
        [
          "14 21 17 24  4",
          "10 16 15  9 19",
          "18  8 23 26 20",
          "22 11 13  6  5",
          " 2  0 12  3  7",
          ""
        ]
      ]

  """
  def parse_input_chunks(path, parser, divider \\ "\n") do
    path
    |> read_input_chunks(divider)
    |> Enum.map(parser)
  end

  defp trim_input_stream(path) do
    path
    |> read_input_stream()
    |> Stream.map(&String.trim/1)
  end

  defp read_input_stream(path) do
    File.stream!(path)
  end
end
