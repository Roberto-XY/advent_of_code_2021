defmodule Day14 do
  @spec solve! :: String.t()
  def solve! do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 3259, res_2: 3_459_174_981_021} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input! :: binary
  def read_input! do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_14.txt"))
  end

  @type element_frequency :: %{<<_::8>> => non_neg_integer()}
  @type polymer_pair_frequency :: %{<<_::16>> => non_neg_integer()}
  @type insertion_rules :: %{<<_::16>> => <<_::8>>}

  @spec parse_input(binary) :: {insertion_rules, polymer_pair_frequency, element_frequency}
  def parse_input(lines) do
    [starting_polymer, insertion_rules] = String.split(lines, "\n\n", trim: true)

    element_count =
      for(<<x::binary-size(1) <- starting_polymer>>, do: x)
      |> Enum.frequencies()

    polymer_pair_frequency =
      String.to_charlist(starting_polymer)
      |> Stream.chunk_every(2, 1, :discard)
      |> Stream.map(&List.to_string/1)
      |> Enum.frequencies()

    insertion_rules =
      String.split(insertion_rules, "\n", trim: true)
      |> Stream.map(fn line ->
        [pattern, insertion] = String.split(line, " -> ", trim: true)
        {pattern, insertion}
      end)
      |> Enum.into(%{})

    {insertion_rules, polymer_pair_frequency, element_count}
  end

  @spec solve_1({insertion_rules, polymer_pair_frequency, element_frequency}) :: non_neg_integer()
  def solve_1({insertion_rules, polymer_pair_frequency, element_frequency}) do
    do_solve({insertion_rules, polymer_pair_frequency, element_frequency}, 10)
  end

  @spec solve_2({insertion_rules, polymer_pair_frequency, element_frequency}) :: non_neg_integer()
  def solve_2({insertion_rules, polymer_pair_frequency, element_frequency}) do
    do_solve({insertion_rules, polymer_pair_frequency, element_frequency}, 40)
  end

  @spec do_solve({insertion_rules, polymer_pair_frequency, element_frequency}, non_neg_integer()) ::
          non_neg_integer()
  def do_solve({insertion_rules, polymer_pair_frequency, element_frequency}, n) do
    {_, acc} =
      Enum.reduce(
        1..n,
        {polymer_pair_frequency, element_frequency},
        fn _, {polymer_pair_frequency, element_frequency} ->
          execute_insertion_step(insertion_rules, polymer_pair_frequency, element_frequency)
        end
      )

    {least_common_count, most_common_count} =
      Map.values(acc)
      |> Enum.min_max()

    most_common_count - least_common_count
  end

  @spec execute_insertion_step(insertion_rules, polymer_pair_frequency, element_frequency) ::
          {polymer_pair_frequency, element_frequency}
  def execute_insertion_step(insertion_rules, polymer_pair_frequency, element_frequency) do
    Enum.reduce(
      polymer_pair_frequency,
      {%{}, element_frequency},
      fn {<<first::binary-size(1), second::binary-size(1)>> = polymer_pair, count},
         {new_polymer_pair_frequency, element_frequency} ->
        case Map.get(insertion_rules, polymer_pair) do
          nil ->
            {new_polymer_pair_frequency, element_frequency}

          insertion ->
            new_polymer_pair_frequency =
              Map.update(new_polymer_pair_frequency, first <> insertion, count, &(&1 + count))
              |> Map.update(insertion <> second, count, &(&1 + count))

            new_element_frequency = Map.update(element_frequency, insertion, count, &(&1 + count))

            {new_polymer_pair_frequency, new_element_frequency}
        end
      end
    )
  end
end
