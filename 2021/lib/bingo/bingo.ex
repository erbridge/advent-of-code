defmodule Advent2021.Bingo do
  @moduledoc """
  Documentation for `Advent2021.Bingo`.
  """

  import Advent2021.Reader

  @type entry :: non_neg_integer
  @type row :: [entry]
  @type board :: [row]
  @type board_collection :: [board]
  @type numbers :: [entry]

  @spec winning_score(String.t(), String.t()) :: non_neg_integer
  @doc """
  Find the winning score!

  ## Examples

      iex> Advent2021.Bingo.winning_score(
      ...>   "lib/04/example_boards.txt",
      ...>   "lib/04/example_numbers.txt"
      ...> )
      4512

  """
  def winning_score(input_boards_path, input_numbers_path) do
    score(input_boards_path, input_numbers_path, &play_to_win/2)
  end

  @spec losing_score(String.t(), String.t()) :: non_neg_integer
  @doc """
  Find the losing score!

  ## Examples

      iex> Advent2021.Bingo.losing_score(
      ...>   "lib/04/example_boards.txt",
      ...>   "lib/04/example_numbers.txt"
      ...> )
      1924

  """
  def losing_score(input_boards_path, input_numbers_path) do
    score(input_boards_path, input_numbers_path, &play_to_lose/2)
  end

  @spec score(
          String.t(),
          String.t(),
          (board_collection, numbers -> %{number: entry, board: board})
        ) :: non_neg_integer
  @doc """
  Find the score after playing with the player.

  ## Examples

      iex> Advent2021.Bingo.score(
      ...>   "lib/04/example_boards.txt",
      ...>   "lib/04/example_numbers.txt",
      ...>   &Advent2021.Bingo.play_to_win/2
      ...> )
      4512

  """
  def score(input_boards_path, input_numbers_path, player) do
    boards =
      input_boards_path
      |> parse_input_chunks(&parse_board/1)

    numbers =
      input_numbers_path
      |> parse_input(&parse_numbers/1)
      |> List.flatten()

    %{number: number, board: board} = player.(boards, numbers)

    board
    |> List.flatten()
    |> Enum.filter(& &1)
    |> Enum.sum()
    |> Kernel.*(number)
  end

  @spec parse_board(String.t()) :: board
  @doc """
  Parse the board input.

  ## Examples

      iex> Advent2021.Bingo.parse_board(
      ...>   "22 13 17 11  0\\n" <>
      ...>     " 8  2 23  4 24\\n" <>
      ...>     "21  9 14 16  7\\n" <>
      ...>     " 6 10  3 18  5\\n" <>
      ...>     " 1 12 20 15 19\\n"
      ...> )
      [
        [22, 13, 17, 11, 0],
        [8, 2, 23, 4, 24],
        [21, 9, 14, 16, 7],
        [6, 10, 3, 18, 5],
        [1, 12, 20, 15, 19]
      ]

  """
  def parse_board(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  @spec parse_numbers(String.t()) :: numbers
  @doc """
  Parse the numbers input.

  ## Examples

      iex> Advent2021.Bingo.parse_numbers("7,4,9,5,11,17,23,2,0,14,21,24")
      [7, 4, 9, 5, 11, 17, 23, 2, 0, 14, 21, 24]

  """
  def parse_numbers(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec play_to_win(board_collection, numbers) ::
          %{number: entry, board: board}
  @doc """
  Play until there's a winning board.

  ## Examples

      iex> Advent2021.Bingo.play_to_win(
      ...>   [
      ...>     [
      ...>       [22, 13, 17, 11, 0],
      ...>       [8, 2, 23, 4, 24],
      ...>       [21, 9, 14, 16, 7],
      ...>       [6, 10, 3, 18, 5],
      ...>       [1, 12, 20, 15, 19]
      ...>     ]
      ...>   ],
      ...>   [23, 100, 14, 20, 2, 3, 17, 5, 21]
      ...> )
      %{
        number: 17,
        board: [
          [22, 13, nil, 11, 0],
          [8, nil, nil, 4, 24],
          [21, 9, nil, 16, 7],
          [6, 10, nil, 18, 5],
          [1, 12, nil, 15, 19]
        ]
      }

  """
  def play_to_win(boards, numbers) do
    {number, remaining_numbers} = List.pop_at(numbers, 0)

    updated_boards = take_turn_for_all(boards, number)

    {winning_boards, _} = winners(updated_boards)

    if Enum.any?(winning_boards) do
      %{number: number, board: List.first(winning_boards)}
    else
      play_to_win(updated_boards, remaining_numbers)
    end
  end

  @spec play_to_lose(board_collection, numbers) ::
          %{number: entry, board: board}
  @doc """
  Play until there's a winning board.

  ## Examples

      iex> Advent2021.Bingo.play_to_lose(
      ...>   [
      ...>     [
      ...>       [23, 100, 14, 20, 2],
      ...>       [8, 2, 23, 4, 24],
      ...>       [21, 9, 14, 16, 7],
      ...>       [6, 10, 3, 18, 5],
      ...>       [1, 12, 20, 15, 19]
      ...>     ],
      ...>     [
      ...>       [22, 13, 17, 11, 0],
      ...>       [8, 2, 23, 4, 24],
      ...>       [21, 9, 14, 16, 7],
      ...>       [6, 10, 3, 18, 5],
      ...>       [1, 12, 20, 15, 19]
      ...>     ]
      ...>   ],
      ...>   [23, 100, 14, 20, 2, 3, 17, 5, 21]
      ...> )
      %{
        number: 17,
        board: [
          [22, 13, nil, 11, 0],
          [8, nil, nil, 4, 24],
          [21, 9, nil, 16, 7],
          [6, 10, nil, 18, 5],
          [1, 12, nil, 15, 19]
        ]
      }

  """
  def play_to_lose(boards, numbers) do
    {number, remaining_numbers} = List.pop_at(numbers, 0)

    updated_boards = take_turn_for_all(boards, number)

    {winning_boards, remaining_boards} = winners(updated_boards)

    if length(remaining_boards) == 0 do
      %{number: number, board: List.first(winning_boards)}
    else
      play_to_lose(remaining_boards, remaining_numbers)
    end
  end

  @spec take_turn_for_all(board_collection, entry) :: board_collection
  @doc """
  Take the turn for all boards.

  ## Examples

      iex> Advent2021.Bingo.take_turn_for_all(
      ...>   [
      ...>     [
      ...>       [22, 13, 17, 11, 0],
      ...>       [8, 2, 23, 4, 24],
      ...>       [21, 9, 14, 16, 7],
      ...>       [6, 10, 3, 18, 5],
      ...>       [1, 12, 20, 15, 19]
      ...>     ]
      ...>   ],
      ...>   23
      ...> )
      [
        [
          [22, 13, 17, 11, 0],
          [8, 2, nil, 4, 24],
          [21, 9, 14, 16, 7],
          [6, 10, 3, 18, 5],
          [1, 12, 20, 15, 19]
        ]
      ]

      iex> Advent2021.Bingo.take_turn_for_all(
      ...>   [
      ...>     [
      ...>       [22, 13, 17, 11, 0],
      ...>       [8, 2, 23, 4, 24],
      ...>       [21, 9, 14, 16, 7],
      ...>       [6, 10, 3, 18, 5],
      ...>       [1, 12, 20, 15, 19]
      ...>     ]
      ...>   ],
      ...>   100
      ...> )
      [
        [
          [22, 13, 17, 11, 0],
          [8, 2, 23, 4, 24],
          [21, 9, 14, 16, 7],
          [6, 10, 3, 18, 5],
          [1, 12, 20, 15, 19]
        ]
      ]

  """
  def take_turn_for_all(boards, number) do
    Enum.map(boards, &take_turn(&1, number))
  end

  @spec take_turn(board, entry) :: board
  @doc """
  Update the board after clearing matches.

  ## Examples

      iex> Advent2021.Bingo.take_turn(
      ...>   [
      ...>     [22, 13, 17, 11, 0],
      ...>     [8, 2, 23, 4, 24],
      ...>     [21, 9, 14, 16, 7],
      ...>     [6, 10, 3, 18, 5],
      ...>     [1, 12, 20, 15, 19]
      ...>   ],
      ...>   23
      ...> )
      [
        [22, 13, 17, 11, 0],
        [8, 2, nil, 4, 24],
        [21, 9, 14, 16, 7],
        [6, 10, 3, 18, 5],
        [1, 12, 20, 15, 19]
      ]

      iex> Advent2021.Bingo.take_turn(
      ...>   [
      ...>     [22, 13, 17, 11, 0],
      ...>     [8, 2, 23, 4, 24],
      ...>     [21, 9, 14, 16, 7],
      ...>     [6, 10, 3, 18, 5],
      ...>     [1, 12, 20, 15, 19]
      ...>   ],
      ...>   100
      ...> )
      [
        [22, 13, 17, 11, 0],
        [8, 2, 23, 4, 24],
        [21, 9, 14, 16, 7],
        [6, 10, 3, 18, 5],
        [1, 12, 20, 15, 19]
      ]

  """
  def take_turn(board, number) do
    Enum.map(board, fn row ->
      index = Enum.find_index(row, &(&1 == number))

      if index do
        List.replace_at(row, index, nil)
      else
        row
      end
    end)
  end

  @spec winners(board_collection) :: {board_collection, board_collection}
  @doc """
  Return the first winning board if there is one and the remaining boards
  without the winners.

  ## Examples

      iex> Advent2021.Bingo.winners([
      ...>   [
      ...>     [22, 13, 17, 11, 0],
      ...>     [8, 2, 23, 4, 24],
      ...>     [21, 9, 14, 16, 7],
      ...>     [nil, nil, nil, nil, nil],
      ...>     [1, 12, 20, 15, 19]
      ...>   ]
      ...> ])
      {
        [
          [
            [22, 13, 17, 11, 0],
            [8, 2, 23, 4, 24],
            [21, 9, 14, 16, 7],
            [nil, nil, nil, nil, nil],
            [1, 12, 20, 15, 19]
          ]
        ],
        []
      }

      iex> Advent2021.Bingo.winners([
      ...>   [
      ...>     [22, 13, nil, 11, 0],
      ...>     [8, 2, nil, 4, 24],
      ...>     [21, 9, nil, 16, 7],
      ...>     [6, 10, nil, 18, 5],
      ...>     [1, 12, nil, 15, 19]
      ...>   ]
      ...> ])
      {
        [
          [
            [22, 13, nil, 11, 0],
            [8, 2, nil, 4, 24],
            [21, 9, nil, 16, 7],
            [6, 10, nil, 18, 5],
            [1, 12, nil, 15, 19]
          ]
        ],
        []
      }

      iex> Advent2021.Bingo.winners([
      ...>   [
      ...>     [nil, 13, 17, 11, 0],
      ...>     [8, nil, 23, 4, 24],
      ...>     [21, 9, nil, 16, 7],
      ...>     [6, 10, 3, nil, 5],
      ...>     [1, 12, 20, 15, nil]
      ...>   ]
      ...> ])
      {
        [],
        [
          [
            [nil, 13, 17, 11, 0],
            [8, nil, 23, 4, 24],
            [21, 9, nil, 16, 7],
            [6, 10, 3, nil, 5],
            [1, 12, 20, 15, nil]
          ]
        ]
      }

      iex> Advent2021.Bingo.winners([
      ...>   [
      ...>     [22, 13, 17, 11, 0],
      ...>     [8, 2, 23, 4, 24],
      ...>     [21, 9, 14, 16, 7],
      ...>     [6, 10, 3, 18, 5],
      ...>     [1, 12, 20, 15, 19]
      ...>   ]
      ...> ])
      {
        [],
        [
          [
            [22, 13, 17, 11, 0],
            [8, 2, 23, 4, 24],
            [21, 9, 14, 16, 7],
            [6, 10, 3, 18, 5],
            [1, 12, 20, 15, 19]
          ]
        ]
      }

  """
  def winners(boards) do
    boards
    |> Enum.filter(&winner?/1)
    |> then(&{&1, boards -- &1})
  end

  @spec winner?(board) :: boolean
  @doc """
  Return true if the board is in a win state.

  ## Examples

      iex> Advent2021.Bingo.winner?([
      ...>   [22, 13, 17, 11, 0],
      ...>   [8, 2, 23, 4, 24],
      ...>   [21, 9, 14, 16, 7],
      ...>   [nil, nil, nil, nil, nil],
      ...>   [1, 12, 20, 15, 19]
      ...> ])
      true

      iex> Advent2021.Bingo.winner?([
      ...>   [22, 13, nil, 11, 0],
      ...>   [8, 2, nil, 4, 24],
      ...>   [21, 9, nil, 16, 7],
      ...>   [6, 10, nil, 18, 5],
      ...>   [1, 12, nil, 15, 19]
      ...> ])
      true

      iex> Advent2021.Bingo.winner?([
      ...>   [nil, 13, 17, 11, 0],
      ...>   [8, nil, 23, 4, 24],
      ...>   [21, 9, nil, 16, 7],
      ...>   [6, 10, 3, nil, 5],
      ...>   [1, 12, 20, 15, nil]
      ...> ])
      false

      iex> Advent2021.Bingo.winner?([
      ...>   [22, 13, 17, 11, 0],
      ...>   [8, 2, 23, 4, 24],
      ...>   [21, 9, 14, 16, 7],
      ...>   [6, 10, 3, 18, 5],
      ...>   [1, 12, 20, 15, 19]
      ...> ])
      false

  """
  def winner?(board) do
    board
    |> Enum.any?(&fully_matched?/1) or
      board
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.any?(&fully_matched?/1)
  end

  @spec fully_matched?(row) :: boolean
  @doc """
  Return true if a row has been full matched.

  ## Examples

      iex> Advent2021.Bingo.fully_matched?([nil, nil, nil, nil, nil])
      true

      iex> Advent2021.Bingo.fully_matched?([22, nil, nil, nil, nil])
      false

  """
  def fully_matched?(row) do
    not Enum.any?(row)
  end
end
