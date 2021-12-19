defmodule Day18 do
  @spec solve!() :: String.rest()
  def solve!() do
    read_input!()
    |> Stream.map(&parse_input_line(String.trim(&1)))
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 10878, res_2: 4716} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_18.txt"))
  end

  def parse_input_line(line) do
    {number, ""} = do_parse(line)
    number
  end

  def do_parse(binary, depth \\ -1)

  def do_parse(<<"[", rest::binary>>, depth) do
    {left, <<",", rest::binary>>} = do_parse(rest, depth + 1)
    {right, <<"]", rest::binary>>} = do_parse(rest, depth + 1)
    {[left, right], rest}
  end

  def do_parse(<<x::binary-size(1), rest::binary>>, depth) do
    {%{value: String.to_integer(x), depth: depth}, rest}
  end

  def solve_1(numbers) do
    numbers
    |> Stream.map(fn number ->
      List.flatten(number)
      |> Stream.with_index()
      |> Stream.map(fn {a, b} -> {b, a} end)
      |> Enum.into(%{})
    end)
    |> Enum.reduce(&add(&2, &1))
  end

  def add(a, b) do
    a =
      Stream.map(a, fn {_, group} -> %{group | depth: group.depth + 1} end)
      |> Enum.to_list()
      |> IO.inspect(label: :A)

    b =
      Stream.map(b, fn {_, group} -> %{group | depth: group.depth + 1} end)
      |> Enum.to_list()
      |> IO.inspect(label: :B)

    new_number =
      Stream.concat(a, b)
      |> Stream.with_index()
      |> Stream.map(fn {a, b} -> {b, a} end)
      |> Enum.into(%{})

    new_number |> IO.inspect(label: :new_number)

    Enum.reduce_while(
      Stream.cycle([0]),
      new_number,
      fn
        _, last_number ->
          current_number =
            Enum.reduce_while(last_number, last_number, fn
              {index, %{depth: depth}}, acc when depth >= 4 ->
                {:halt, explode_at(acc, index)}
                |> IO.inspect(label: "explode_at#{index}")

              {index, %{value: value}}, acc when value >= 10 ->
                {:halt, split_at(acc, index)}
                |> IO.inspect(label: "split_at#{index}")

              _, acc ->
                {:cont, acc}
            end)

          if current_number == last_number do
            {:halt, current_number}
          else
            {:cont, current_number}
          end
      end
    )
  end

  def explode_at(number, index) when is_map(number) do
    # IO.inspect({index, number}, label: :explode_at_INNER)
    first = Map.fetch!(number, index)
    second = Map.fetch!(number, index + 1)

    if first.depth >= 4 and second.depth >= 4 do
      update_existing(number, index - 1, &%{depth: &1.depth, value: &1.value + first.value})
      |> update_existing(index + 2, &%{depth: &1.depth, value: &1.value + second.value})
      |> Map.drop([index])
      |> Enum.map(fn
        {i, num} when i > index -> {i - 1, num}
        i_num -> i_num
      end)
      |> Enum.into(%{})
      |> Map.update!(index, fn _ -> %{depth: first.depth - 1, value: 0} end)
    else
      number
    end
  end

  def split_at(number, index) do
    # IO.inspect({index, number}, label: :split_at_INNER)

    elem = Map.fetch!(number, index)

    if elem.value >= 10 do
      Enum.map(number, fn
        {i, num} when i > index -> {i + 1, num}
        i_num -> i_num
      end)
      |> Enum.into(%{})
      |> Map.put(index, %{depth: elem.depth + 1, value: floor(elem.value / 2)})
      |> Map.put(index + 1, %{depth: elem.depth + 1, value: ceil(elem.value / 2)})
    else
      number
    end

    #     def split(arr, ind)
    #   arr.insert(ind + 1, (arr[ind].real / 2.0).round + (arr[ind].imaginary + 1).i)
    #   arr[ind] = arr[ind].real / 2 + (arr[ind].imaginary + 1).i
    # end
  end

  def update_existing(map, key, fun) do
    case map do
      %{^key => old} -> %{map | key => fun.(old)}
      %{} -> map
    end
  end

  def solve_2(x) do
  end
end
