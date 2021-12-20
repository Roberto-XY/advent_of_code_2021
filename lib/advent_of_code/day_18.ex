defmodule Day18 do
  @spec solve!() :: String.rest()
  def solve!() do
    read_input!()
    |> Stream.map(&parse_input_line(String.trim(&1)))
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 3691, res_2: 4756} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_18.txt"))
  end

  def parse_input_line(line) do
    {number, ""} = do_parse(line)
    number
  end

  def do_parse(<<"[", rest::binary>>) do
    {left, <<",", rest::binary>>} = do_parse(rest)
    {right, <<"]", rest::binary>>} = do_parse(rest)
    {[left, right], rest}
  end

  def do_parse(<<x::binary-size(1), rest::binary>>) do
    {String.to_integer(x), rest}
  end

  def solve_1(numbers) do
    numbers
    |> Enum.reduce(&add(&2, &1))
    |> magnitude()
  end

  def solve_2(numbers) do
    for number1 <- numbers,
        number2 <- numbers,
        number1 != number2 do
      {number1, number2}
    end
    |> Stream.map(fn {number1, number2} -> add(number1, number2) end)
    |> Stream.map(&magnitude/1)
    |> Enum.max()
  end

  @type snail_number_component :: [non_neg_integer()]

  def magnitude([left, right]) do
    3 * magnitude(left) + 2 * magnitude(right)
  end

  def magnitude(leaf) when is_integer(leaf) do
    leaf
  end

  def add(number1, number2) do
    reduce([number1, number2])
  end

  def reduce(number) do
    case explode(number, 0) do
      %{exploded: true, new_value: number} ->
        reduce(number)

      _ ->
        case split(number) do
          %{split: true, new_value: number} ->
            reduce(number)

          _ ->
            number
        end
    end
  end

  def explode([left, right], 4) do
    %{exploded: true, new_value: 0, left_add: left, right_add: right}
  end

  def explode([left, right], depth) do
    case explode(left, depth + 1) do
      %{exploded: true, new_value: new_value, left_add: left_add, right_add: right_add} ->
        %{
          exploded: true,
          new_value: [new_value, add_left(right, right_add)],
          left_add: left_add,
          right_add: 0
        }

      %{exploded: false} ->
        case explode(right, depth + 1) do
          %{exploded: true, new_value: new_value, left_add: left_add, right_add: right_add} ->
            %{
              exploded: true,
              new_value: [add_right(left, left_add), new_value],
              left_add: 0,
              right_add: right_add
            }

          %{exploded: false} ->
            %{exploded: false}
        end
    end
  end

  def explode(leaf, _) when is_integer(leaf) do
    %{exploded: false}
  end

  def add_left([left, right], value) when is_integer(value) do
    [add_left(left, value), right]
  end

  def add_left(leaf, value) when is_integer(leaf) and is_integer(value) do
    leaf + value
  end

  def add_right([left, right], value) when is_integer(value) do
    [left, add_right(right, value)]
  end

  def add_right(leaf, value) when is_integer(leaf) and is_integer(value) do
    leaf + value
  end

  def split([left, right]) do
    case split(left) do
      %{split: true, new_value: new_left_value} ->
        %{split: true, new_value: [new_left_value, right]}

      %{split: false} ->
        case split(right) do
          %{split: true, new_value: new_right_value} ->
            %{split: true, new_value: [left, new_right_value]}

          %{split: false} ->
            %{split: false}
        end
    end
  end

  def split(leaf) when is_integer(leaf) and leaf >= 10 do
    %{split: true, new_value: [floor(leaf / 2), ceil(leaf / 2)]}
  end

  def split(leaf) when is_integer(leaf) do
    %{split: false}
  end
end
