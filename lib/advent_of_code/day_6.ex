defmodule Day6 do
  @example_input [3, 4, 3, 1, 2]

  @spec solve! :: String.t()
  def solve!() do
    read_input!()
    |> Enum.to_list()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 360_610, res_2: 1395} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input! :: Enumerable.t()
  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_6.txt"))
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec solve_1(Enumerable.t(), non_neg_integer()) :: integer()
  def solve_1(enum \\ @example_input, days \\ 80)

  def solve_1(enum, 0) when is_list(enum) do
    length(enum)
  end

  def solve_1(enum, days) when is_list(enum) and is_integer(days) and days >= 0 do
    solve_1(update_day(enum), days - 1)
  end

  @spec update_day([non_neg_integer()]) :: [non_neg_integer()]
  def update_day(counters) do
    Enum.flat_map(counters, fn
      0 -> [6, 8]
      counter -> [counter - 1]
    end)
  end

  @spec solve_2(Enumerable.t()) :: integer()
  def solve_2(enum \\ @example_input) do
    solve_1(enum, 256)
  end
end
