defmodule Day21 do
  def solve!() do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 5259, res_2: 15287} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_20.txt"))
  end

  def parse_input(lines) do
  end

  def solve_1(%{picture: picture, decode_string: decode_string}) do
  end

  def solve_2(%{decode_string: decode_string, picture: picture}) do
  end
end
