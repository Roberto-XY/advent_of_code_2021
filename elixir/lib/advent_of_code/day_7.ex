defmodule Day7 do
  @example_input "16,1,2,0,4,2,7,1,2,14"

  @spec solve! :: String.t()
  def solve!() do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 336_131, res_2: 92_676_646} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input! :: binary()
  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_7.txt"))
  end

  @spec parse_input(binary()) :: [integer()]
  def parse_input(input \\ @example_input) when is_binary(input) do
    String.split(input, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec solve_1([integer()]) :: non_neg_integer()
  def solve_1(positions) when is_list(positions) and length(positions) > 0 do
    mid = Enum.sort(positions) |> Enum.at(floor(length(positions) / 2))

    Stream.map(positions, &abs(&1 - mid)) |> Enum.sum()
  end

  @spec solve_2([integer()]) :: non_neg_integer()
  def solve_2(positions) do
    {min, max} = Enum.min_max(positions)

    Stream.map(min..max, fn possible_alignment_position ->
      Stream.map(positions, &sum_integers(abs(&1 - possible_alignment_position))) |> Enum.sum()
    end)
    |> Enum.min()
  end

  @spec sum_integers(non_neg_integer) :: non_neg_integer
  def sum_integers(n) when is_integer(n) and n >= 0 do
    div(n * (n + 1), 2)
  end
end
