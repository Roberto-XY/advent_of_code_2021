defmodule Day18 do
  @spec solve!() :: String.t()
  def solve!() do
    read_input!()
    |> Stream.map(&parse_input_line(String.trim(&1)))
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 10878, res_2: 4716} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input!() :: binary
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_17.txt"))
  end

  @type target_area :: %{x_min: integer(), x_max: integer(), y_min: integer(), y_max: integer()}
  @type velocity :: %{x_velocity: integer(), y_velocity: integer()}

  def parse_input_line(line, stack \\ [], acc \\ [])

  # def parse_input_line(
  #       <<"[", left::binary-size(1), ",", right::binary-size(1), "]", rest::binary>>,
  #       _stack,
  #       acc
  #     ) do
  #   parse_input_line(rest, [String.to_integer(left), String.to_integer(right) | acc])
  # end

  # def parse_input_line(<<"[", left::binary-size(1), ",", rest::binary>>, acc) do
  #   [String.to_integer(left), parse_input_line(rest, acc)]
  # end

  # def parse_input_line(<<",", right::binary-size(1), rest::binary>>, acc) do
  #   [parse_input_line(rest, []), [String.to_integer(right), acc]]
  # end

  def parse_input_line(<<"]", rest::binary>>, [",", "[" | stack], acc) do
    IO.inspect(acc, label: :CLOSED)
    parse_input_line(rest, stack, Enum.reverse(acc))
  end

  def parse_input_line(<<"]", rest::binary>>, stack, acc) do
    IO.inspect(stack)
    IO.inspect(acc, label: :acc)

    case Enum.split_while(stack, &(&1 != "[")) |> IO.inspect() do
      {[right, ",", left], [_ | stack]} ->
        parse_input_line(rest, stack, [[String.to_integer(left), String.to_integer(right)] | acc])

      {[right, ","], [_ | stack]} ->
        parse_input_line(rest, stack, [acc, String.to_integer(right)])

      {[",", left], [_ | stack]} ->
        parse_input_line(rest, stack, [String.to_integer(left), acc])
    end
  end

  # def parse_input_line(<<"]", rest::binary>>, [right, ",", left, "[" | stack], acc) do
  #   parse_input_line(rest, stack, [[String.to_integer(left), String.to_integer(right)] | acc])
  # end

  def parse_input_line(<<head::binary-size(1), rest::binary>>, stack, acc) do
    parse_input_line(rest, [head | stack], acc)
  end

  def parse_input_line("", stack, acc) do
    acc
  end

  @spec solve_1(target_area) :: integer()
  def solve_1(%{x_max: x_max, y_min: y_min} = target_area) do
  end

  @spec solve_2(target_area) :: non_neg_integer()
  def solve_2(%{x_max: x_max, y_min: y_min} = target_area) do
  end
end
