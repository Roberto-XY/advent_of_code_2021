defmodule Day14 do
  @spec solve! :: String.t()
  def solve! do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 3259, res_2: "ZKAUCFUC"} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input! do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_14.txt"))
  end

  def parse_input(lines) do
    [template, insertion_rules] = String.split(lines, "\n\n", trim: true)

    insertion_rules =
      String.split(insertion_rules, "\n", trim: true)
      |> Enum.map(fn line ->
        [pattern, insertion] = String.split(line, " -> ", trim: true)
        {pattern, insertion}
      end)

    {template, insertion_rules}
  end

  def solve_1({template, insertion_rules}) do
    do_solve({template, insertion_rules}, 10)
  end

  def solve_2({template, insertion_rules}) do
    do_solve({template, insertion_rules}, 40)
  end

  def do_solve({template, insertion_rules}, n) do
    {least_common_count, most_common_count} =
      Enum.reduce(1..n, template, fn _, acc ->
        execute_insertion_step(acc, insertion_rules)
      end)
      |> String.to_charlist()
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.min_max()

    most_common_count - least_common_count
  end

  @spec execute_insertion_step(<<_::16, _::_*8>>, [{<<_::16>>, binary}], binary) :: binary
  def execute_insertion_step(_, _, acc \\ "")

  def execute_insertion_step(
        <<first::binary-size(1), second::binary-size(1)>> <> tail,
        insertion_rules,
        acc
      ) do
    insertion =
      Stream.map(insertion_rules, fn
        {
          <<^first::binary-size(1), ^second::binary-size(1)>>,
          insertion
        } ->
          insertion

        _ ->
          nil
      end)
      |> Stream.filter(&(not is_nil(&1)))
      |> Enum.join()

    execute_insertion_step(second <> tail, insertion_rules, acc <> first <> insertion)
  end

  def execute_insertion_step(<<last::binary-size(1)>>, _, acc) do
    acc <> last
  end
end
