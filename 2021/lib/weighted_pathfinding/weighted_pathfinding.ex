defmodule Advent2021.WeightedPathfinding do
  @moduledoc """
  Documentation for `Advent2021.WeightedPathfinding`.
  """

  import Advent2021.Reader

  @spec lowest_risk(
          String.t(),
          tile: {pos_integer, pos_integer}
        ) :: non_neg_integer
  @doc """
  Find the risk of the lowest risk path.

  ## Examples

      iex> Advent2021.WeightedPathfinding.lowest_risk("lib/15/example.txt")
      40

      iex> Advent2021.WeightedPathfinding.lowest_risk(
      ...>   "lib/15/example.txt",
      ...>   tile: {5, 5}
      ...> )
      315

  """
  def lowest_risk(input_path, [tile: tile] \\ [tile: {1, 1}]) do
    risk_levels = parse_risk_levels(input_path, tile)

    width = risk_levels |> List.first() |> length()
    height = length(risk_levels)

    lowest_cost_path(
      risk_levels,
      {width, height},
      {width - 1, height - 1},
      [{0, 0, {0, 0}}],
      MapSet.new()
    )
  end

  @spec parse_risk_levels(
          String.t(),
          {pos_integer, pos_integer}
        ) :: [non_neg_integer]
  @doc """
  Parse risk levels as tiles.
  """
  def parse_risk_levels(input_path, {tile_x, tile_y}) do
    wrap_risk = fn risk, index -> rem(risk + index - 1, 9) + 1 end

    input_path
    |> parse_input(&parse_row/1)
    |> Enum.map(fn row ->
      row
      |> List.duplicate(tile_x)
      |> Enum.with_index()
      |> Enum.reduce([], fn {row_section, index}, acc ->
        row_section
        |> Enum.map(fn risk -> wrap_risk.(risk, index) end)
        |> then(&(acc ++ &1))
      end)
    end)
    |> List.duplicate(tile_y)
    |> Enum.with_index()
    |> Enum.reduce([], fn {grid_section, index}, acc ->
      grid_section
      |> Enum.map(&Enum.map(&1, fn risk -> wrap_risk.(risk, index) end))
      |> then(&(acc ++ &1))
    end)
  end

  @spec parse_row(String.t()) :: [non_neg_integer]
  @doc """
  Parse a row.

  ## Examples

      iex> Advent2021.WeightedPathfinding.parse_row("1163751742")
      [1, 1, 6, 3, 7, 5, 1, 7, 4, 2]

  """
  def parse_row(input) do
    input
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec lowest_cost_path(
          [[non_neg_integer]],
          {non_neg_integer, non_neg_integer},
          {non_neg_integer, non_neg_integer},
          [
            {
              non_neg_integer,
              non_neg_integer,
              {non_neg_integer, non_neg_integer}
            }
          ],
          MapSet.t({non_neg_integer, non_neg_integer})
        ) :: non_neg_integer
  @doc """
  Find the cost of the lowest cost path using an A* search.

  ## Examples

      iex> Advent2021.WeightedPathfinding.lowest_cost_path(
      ...>   [
      ...>     [1, 1, 6, 3],
      ...>     [1, 3, 8, 1],
      ...>     [2, 1, 3, 6],
      ...>     [3, 6, 9, 4]
      ...>   ],
      ...>   {4, 4},
      ...>   {3, 3},
      ...>   [{0, 0, {0, 0}}],
      ...>   MapSet.new()
      ...> )
      17

  """
  def lowest_cost_path(costs, dimensions, goal, fringe, visited) do
    expanded_fringe =
      expand_fringe(
        costs,
        dimensions,
        goal,
        fringe,
        visited
      )

    case expanded_fringe do
      {:cont, new_fringe, new_visited} ->
        lowest_cost_path(costs, dimensions, goal, new_fringe, new_visited)

      {:halt, goal_cost} ->
        goal_cost
    end
  end

  @spec expand_fringe(
          [[non_neg_integer]],
          {non_neg_integer, non_neg_integer},
          {non_neg_integer, non_neg_integer},
          [
            {
              non_neg_integer,
              non_neg_integer,
              {non_neg_integer, non_neg_integer}
            }
          ],
          MapSet.t({non_neg_integer, non_neg_integer})
        ) ::
          {
            :cont,
            [
              {
                non_neg_integer,
                non_neg_integer,
                {non_neg_integer, non_neg_integer}
              }
            ],
            MapSet.t({non_neg_integer, non_neg_integer})
          }
          | {:halt, non_neg_integer}
  @doc """
  Expand the fringe by one step.

  ## Examples

      iex> Advent2021.WeightedPathfinding.expand_fringe(
      ...>   [
      ...>     [1, 1, 6, 3],
      ...>     [1, 3, 8, 1],
      ...>     [2, 1, 3, 6],
      ...>     [3, 6, 9, 4]
      ...>   ],
      ...>   {4, 4},
      ...>   {3, 3},
      ...>   [{0, 0, {0, 0}}],
      ...>   MapSet.new()
      ...> )
      {
        :cont,
        [
          {6, 1, {0, 1}},
          {6, 1, {1, 0}}
        ],
        MapSet.new([{0, 0}])
      }

      iex> Advent2021.WeightedPathfinding.expand_fringe(
      ...>   [
      ...>     [1, 1, 6, 3],
      ...>     [1, 3, 8, 1],
      ...>     [2, 1, 3, 6],
      ...>     [3, 6, 9, 4]
      ...>   ],
      ...>   {4, 4},
      ...>   {3, 3},
      ...>   [
      ...>     {6, 1, {0, 1}},
      ...>     {6, 1, {1, 0}}
      ...>   ],
      ...>   MapSet.new([{0, 0}])
      ...> )
      {
        :cont,
        [
          {7, 3, {0, 2}},
          {8, 4, {1, 1}},
          {6, 1, {1, 0}}
        ],
        MapSet.new([{0, 1}, {0, 0}])
      }

  """
  def expand_fringe(costs, {width, height}, goal, fringe, visited) do
    edge = Enum.min_by(fringe, &elem(&1, 0))

    {_, edge_cost, edge_node} = edge
    {edge_node_x, edge_node_y} = edge_node

    new_fringe =
      [
        {edge_node_x, edge_node_y + 1},
        {edge_node_x + 1, edge_node_y},
        {edge_node_x, edge_node_y - 1},
        {edge_node_x - 1, edge_node_y}
      ]
      |> Enum.reject(fn node ->
        {x, y} = node

        x < 0 or
          y < 0 or
          x >= width or
          y >= height or
          MapSet.member?(visited, node)
      end)
      |> Enum.map(fn node ->
        {x, y} = node

        cost =
          costs
          |> Enum.at(y)
          |> Enum.at(x)
          |> Kernel.+(edge_cost)

        weight = cost + heuristic_cost(node, goal)

        {weight, cost, node}
      end)

    {_, goal_cost, _} =
      Enum.find(
        new_fringe,
        {nil, nil, nil},
        fn {_, _, node} -> node == goal end
      )

    if goal_cost do
      {:halt, goal_cost}
    else
      {
        :cont,
        new_fringe ++ (fringe -- [edge]),
        MapSet.put(visited, edge_node)
      }
    end
  end

  @spec heuristic_cost(
          {non_neg_integer, non_neg_integer},
          {non_neg_integer, non_neg_integer}
        ) :: non_neg_integer
  @doc """
  Find a heuristic cost for getting from the position to the goal.

  ## Examples

      iex> Advent2021.WeightedPathfinding.heuristic_cost({1, 1}, {3, 3})
      4

  """
  def heuristic_cost(position, goal) do
    {position_x, position_y} = position
    {goal_x, goal_y} = goal

    abs(goal_x - position_x) + abs(goal_y - position_y)
  end
end
