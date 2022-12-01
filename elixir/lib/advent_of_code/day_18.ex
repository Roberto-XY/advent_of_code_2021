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

  @spec read_input! :: File.Stream.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_18.txt"))
  end

  @type snail_number :: [non_neg_integer() | snail_number]

  @spec parse_input_line(nonempty_binary) :: snail_number
  def parse_input_line(line) do
    {number, ""} = do_parse(line)
    number
  end

  @spec do_parse(nonempty_binary) :: {snail_number | integer, binary}
  def do_parse(<<"[", rest::binary>>) do
    {left, <<",", rest::binary>>} = do_parse(rest)
    {right, <<"]", rest::binary>>} = do_parse(rest)
    {[left, right], rest}
  end

  def do_parse(<<x::binary-size(1), rest::binary>>) do
    {String.to_integer(x), rest}
  end

  @spec solve_1(Enumerable.t()) :: non_neg_integer
  def solve_1(numbers) do
    numbers
    |> Enum.reduce(&add(&2, &1))
    |> magnitude()
  end

  @spec solve_2(Enumerable.t()) :: non_neg_integer
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

  @spec magnitude(snail_number) :: non_neg_integer()
  def magnitude([left, right]) do
    3 * magnitude(left) + 2 * magnitude(right)
  end

  def magnitude(leaf) when is_integer(leaf) do
    leaf
  end

  @spec add(snail_number, snail_number) :: snail_number
  def add(number1, number2) do
    reduce([number1, number2])
  end

  @spec reduce(snail_number) :: snail_number
  def reduce(number) do
    case explode(number) do
      %{exploded: true, new_number: number} ->
        reduce(number)

      _ ->
        case split(number) do
          %{split: true, new_number: number} ->
            reduce(number)

          _ ->
            number
        end
    end
  end

  @doc """
  Descend the tree until depth 4 is hit, follow the recursive call stack back up until correct
  ancestor is found.
  If exploding pair is on the left of its parent
    -> find first ancestor with right arm & descend down to leaf
    -> add exploding right value to it
  If exploding pair is on the right of its parent
    -> find first ancestor with left arm & descend down to leaf
    -> add exploding left value to it
  """
  @spec explode(snail_number, non_neg_integer()) :: %{
          :exploded => boolean,
          optional(:left_add) => non_neg_integer(),
          optional(:new_number) => snail_number | 0,
          optional(:right_add) => non_neg_integer()
        }
  def explode(number, depth \\ 0)

  def explode([left, right], 4) do
    %{exploded: true, new_number: 0, left_add: left, right_add: right}
  end

  def explode([left, right], depth) do
    case explode(left, depth + 1) do
      # Not strictly necessary but safes a tree traversal to add 0
      %{exploded: true, new_number: new_number, right_add: 0} = x ->
        %{x | new_number: [new_number, right]}

      %{exploded: true, new_number: new_number, left_add: left_add, right_add: right_add} ->
        %{
          exploded: true,
          # Add to the left most leaf of the right sub tree (descending back down)
          new_number: [new_number, add_left(right, right_add)],
          left_add: left_add,
          right_add: 0
        }

      %{exploded: false} ->
        case explode(right, depth + 1) do
          # Not strictly necessary but safes a tree traversal to add 0
          %{exploded: true, new_number: new_number, left_add: 0} = x ->
            %{x | new_number: [left, new_number]}

          %{exploded: true, new_number: new_number, left_add: left_add, right_add: right_add} ->
            %{
              exploded: true,
              # Add to the right most leaf of the left sub tree (descending back down)
              new_number: [add_right(left, left_add), new_number],
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

  @doc """
  Adds `value` to the left most leaf of the tree
  """
  @spec add_left(snail_number(), integer) :: snail_number() | integer
  def add_left([left, right], value) when is_integer(value) do
    [add_left(left, value), right]
  end

  def add_left(leaf, value) when is_integer(leaf) and is_integer(value) do
    leaf + value
  end

  @doc """
  Adds `value` to the right most leaf of the tree
  """
  @spec add_right(snail_number(), integer) :: snail_number() | integer
  def add_right([left, right], value) when is_integer(value) do
    [left, add_right(right, value)]
  end

  def add_right(leaf, value) when is_integer(leaf) and is_integer(value) do
    leaf + value
  end

  @spec split(snail_number) :: %{:split => boolean, optional(:new_number) => snail_number}
  def split([left, right]) do
    case split(left) do
      %{split: true, new_number: new_left_value} ->
        %{split: true, new_number: [new_left_value, right]}

      %{split: false} ->
        case split(right) do
          %{split: true, new_number: new_right_value} ->
            %{split: true, new_number: [left, new_right_value]}

          %{split: false} ->
            %{split: false}
        end
    end
  end

  def split(leaf) when is_integer(leaf) and leaf >= 10 do
    %{split: true, new_number: [floor(leaf / 2), ceil(leaf / 2)]}
  end

  def split(leaf) when is_integer(leaf) do
    %{split: false}
  end
end
