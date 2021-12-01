defmodule Day1 do
  @example_input [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

  @spec read_input! :: list(integer())
  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_1.txt"))
    |> String.split("\n")
    |> Enum.map(fn x ->
      {res, ""} = Integer.parse(x)
      res
    end)
  end

  @spec solve_1(list(integer())) :: integer()
  def solve_1(list \\ @example_input) do
    Enum.chunk_every(list, 2, 1, :discard)
    |> Enum.reduce(0, fn [first, second], acc ->
      if first < second do
        acc + 1
      else
        acc
      end
    end)
  end

  @spec solve_2(list(integer())) :: integer()
  def solve_2(list \\ @example_input) do
    Enum.chunk_every(list, 3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> solve_1()
  end
end
