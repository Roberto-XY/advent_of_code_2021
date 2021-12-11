defmodule Day1 do
  @example_input [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

  @spec solve! :: String.t()
  def solve!() do
    read_input!()
    |> Enum.to_list()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 1451, res_2: 1395} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input! :: Enumerable.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_1.txt"))
    |> Stream.map(&String.to_integer(String.trim(&1)))
  end

  @spec solve_1(Enumerable.t()) :: integer()
  def solve_1(enum \\ @example_input) do
    Stream.chunk_every(enum, 2, 1, :discard)
    |> Enum.count(fn [first, second] -> first < second end)
  end

  @spec solve_2(Enumerable.t()) :: integer()
  def solve_2(enum \\ @example_input) do
    Stream.chunk_every(enum, 3, 1, :discard)
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.count(fn [[left, _, _], [_, _, right]] -> right > left end)
  end
end
