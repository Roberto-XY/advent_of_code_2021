defmodule Day10 do
  @spec solve!() :: String.t()
  def solve!() do
    read_input!()
    |> Stream.map(&parse_input_line(String.trim(&1)))
    |> Enum.to_list()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 240_123, res_2: 3_260_812_321} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_10.txt"))
  end

  @spec solve_1(Enumerable.t()) :: non_neg_integer()
  def solve_1(checked_lines) do
    Stream.map(checked_lines, fn
      {:error, {:unexpected_char, ")"}} -> 3
      {:error, {:unexpected_char, "]"}} -> 57
      {:error, {:unexpected_char, "}"}} -> 1197
      {:error, {:unexpected_char, ">"}} -> 25137
      _ -> 0
    end)
    |> Enum.sum()
  end

  @spec solve_2(Enumerable.t()) :: non_neg_integer()
  def solve_2(checked_lines) do
    Stream.filter(checked_lines, fn
      {:error, {:incomplete, _}} -> true
      _ -> false
    end)
    |> Stream.map(fn
      {:error, {:incomplete, left_over}} ->
        Enum.reduce(left_over, 0, fn
          "(", acc -> acc * 5 + 1
          "[", acc -> acc * 5 + 2
          "{", acc -> acc * 5 + 3
          "<", acc -> acc * 5 + 4
        end)
    end)
    |> Enum.to_list()
    |> Enum.sort()
    |> then(&Enum.at(&1, floor(length(&1) / 2)))
  end

  @spec parse_input_line(binary, [<<_::8>>]) ::
          :ok | {:error, {:incomplete, [<<_::8>>]} | {:unexpected_char, <<_::8>>}}
  def parse_input_line(binary, acc \\ [])

  def parse_input_line(<<"[", rest::binary>>, acc) do
    parse_input_line(rest, ["[" | acc])
  end

  def parse_input_line(<<"]", rest::binary>>, ["[" | tail]) do
    parse_input_line(rest, tail)
  end

  def parse_input_line(<<"(", rest::binary>>, acc) do
    parse_input_line(rest, ["(" | acc])
  end

  def parse_input_line(<<")", rest::binary>>, ["(" | tail]) do
    parse_input_line(rest, tail)
  end

  def parse_input_line(<<"{", rest::binary>>, acc) do
    parse_input_line(rest, ["{" | acc])
  end

  def parse_input_line(<<"}", rest::binary>>, ["{" | tail]) do
    parse_input_line(rest, tail)
  end

  def parse_input_line(<<"<", rest::binary>>, acc) do
    parse_input_line(rest, ["<" | acc])
  end

  def parse_input_line(<<">", rest::binary>>, ["<" | tail]) do
    parse_input_line(rest, tail)
  end

  def parse_input_line("", []) do
    :ok
  end

  def parse_input_line("", left_over) do
    {:error, {:incomplete, left_over}}
  end

  def parse_input_line(<<head::binary-size(1), _::binary>>, _) do
    {:error, {:unexpected_char, head}}
  end
end
