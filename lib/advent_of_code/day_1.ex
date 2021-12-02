defmodule Day1 do
  @example_input [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

  @spec read_input! :: Enumerable.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_1.txt"))
    |> Stream.map(fn line ->
      {res, _} = Integer.parse(line)
      res
    end)
  end

  @spec solve_1(Enumerable.t()) :: integer()
  def solve_1(enum \\ @example_input) do
    Stream.chunk_every(enum, 2, 1, :discard)
    |> Enum.reduce(0, fn [first, second], acc ->
      if first < second do
        acc + 1
      else
        acc
      end
    end)
  end

  @spec solve_2(Enumerable.t()) :: integer()
  def solve_2(enum \\ @example_input) do
    Stream.chunk_every(enum, 3, 1, :discard)
    |> Stream.map(&Enum.sum/1)
    |> solve_1()
  end
end
