defmodule Day5 do
  @example_input [
    {{0, 9}, {5, 9}},
    {{8, 0}, {0, 8}},
    {{9, 4}, {3, 4}},
    {{2, 2}, {2, 1}},
    {{7, 0}, {7, 4}},
    {{6, 4}, {2, 0}},
    {{0, 9}, {2, 9}},
    {{3, 4}, {1, 4}},
    {{0, 0}, {8, 8}},
    {{5, 5}, {8, 2}}
  ]

  @spec read_input! :: Enumerable.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_5.txt"))
    |> Stream.map(fn line ->
      [start, finish] = String.split(String.trim(line), " -> ", trim: true)

      {parse_coordinate(start), parse_coordinate(finish)}
    end)
  end

  @spec parse_coordinate(binary()) :: {integer(), integer()}
  defp parse_coordinate(binary) when is_binary(binary) do
    [x, y] = String.split(binary, ",", trim: true)
    {String.to_integer(x), String.to_integer(y)}
  end

  @spec solve_1(Enumerable.t()) :: non_neg_integer()
  def solve_1(enum \\ @example_input) do
    Stream.filter(enum, fn
      {{x1, y1}, {x2, y2}} when x1 == x2 or y1 == y2 -> true
      _ -> false
    end)
    |> Stream.map(fn {{x1, y1}, {x2, y2}} ->
      for x <- x1..x2,
          y <- y1..y2 do
        {x, y}
      end
    end)
    |> count_overlapping()
  end

  @spec solve_2(Enumerable.t()) :: non_neg_integer()
  def solve_2(enum \\ @example_input) do
    Stream.map(enum, fn
      {{x1, y1}, {x2, y2}} when x1 == x2 or y1 == y2 ->
        for x <- x1..x2,
            y <- y1..y2 do
          {x, y}
        end

      {{x1, y1}, {x2, y2}} ->
        m = (y1 - y2) / (x1 - x2)
        c = y1 - x1 * m

        for x <- x1..x2 do
          {x, trunc(m * x + c)}
        end
    end)
    |> count_overlapping()
  end

  @spec count_overlapping(Enumerable.t()) :: non_neg_integer()
  defp count_overlapping(enum) do
    Enum.reduce(enum, %{}, fn line, acc ->
      Enum.reduce(line, acc, fn coordinate, acc ->
        Map.update(acc, coordinate, 1, &(&1 + 1))
      end)
    end)
    |> Enum.count(&(elem(&1, 1) > 1))
  end
end
