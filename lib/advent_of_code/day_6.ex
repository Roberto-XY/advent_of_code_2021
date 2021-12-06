defmodule Day6 do
  @example_input "3,4,3,1,2"

  @type timers :: %{optional(1..8) => non_neg_integer()}

  @spec solve! :: String.t()
  def solve!() do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 360_610, res_2: 1_631_629_590_423} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input! :: binary()
  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_6.txt"))
  end

  @spec parse_input(binary()) :: timers()
  def parse_input(input \\ @example_input) when is_binary(input) do
    String.split(input, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{}, fn timer, acc ->
      Map.update(acc, timer, 1, &(&1 + 1))
    end)
  end

  @spec solve_1(timers()) :: non_neg_integer()
  def solve_1(timers) do
    do_solve(timers, 80)
  end

  @spec solve_2(timers()) :: integer()
  def solve_2(timers) do
    do_solve(timers, 256)
  end

  @spec do_solve(timers(), non_neg_integer()) ::
          non_neg_integer()
  def do_solve(timers, days)

  def do_solve(timers, 0) when is_map(timers) do
    Map.values(timers) |> Enum.sum()
  end

  def do_solve(timers, days) when is_map(timers) and is_integer(days) and days >= 0 do
    do_solve(update_day(timers), days - 1)
  end

  @spec update_day(timers()) :: timers()
  def update_day(timers) when is_map(timers) do
    Enum.reduce(timers, %{}, fn
      {0, count}, acc ->
        Map.update(acc, 6, count, &(&1 + count))
        |> Map.update(8, count, &(&1 + count))

      {timer, count}, acc ->
        Map.update(acc, timer - 1, count, &(&1 + count))
    end)
  end
end
