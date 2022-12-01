defmodule Day2 do
  @example_input [{:forward, 5}, {:down, 5}, {:forward, 8}, {:up, 3}, {:down, 8}, {:forward, 2}]

  @type direction() :: :forward | :down | :up

  defmodule Position do
    @type t :: %__MODULE__{horizontal: integer(), depth: integer(), aim: integer()}
    defstruct horizontal: 0, depth: 0, aim: 0
  end

  @spec read_input! :: Enumerable.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_2.txt"))
    |> Stream.map(&parse_line/1)
  end

  @spec parse_line(String.t()) :: {direction(), integer()}
  defp parse_line(line) do
    [direction, units] = String.split(line)
    {units, _} = Integer.parse(units)

    case [direction, units] do
      ["forward", units] -> {:forward, units}
      ["down", units] -> {:down, units}
      ["up", units] -> {:up, units}
    end
  end

  @spec solve_1(Enumerable.t()) :: integer()
  def solve_1(enum \\ @example_input) do
    %Position{horizontal: horizontal, depth: depth} =
      Enum.reduce(enum, %Position{}, fn
        {:forward, units}, acc -> %Position{acc | horizontal: acc.horizontal + units}
        {:down, units}, acc -> %Position{acc | depth: acc.depth + units}
        {:up, units}, acc -> %Position{acc | depth: acc.depth - units}
      end)

    horizontal * depth
  end

  @spec solve_2(Enumerable.t()) :: integer()
  def solve_2(enum \\ @example_input) do
    %Position{horizontal: horizontal, depth: depth} =
      Enum.reduce(enum, %Position{}, fn
        {:forward, units}, acc ->
          %Position{acc | horizontal: acc.horizontal + units, depth: acc.depth + acc.aim * units}

        {:down, units}, acc ->
          %Position{acc | aim: acc.aim + units}

        {:up, units}, acc ->
          %Position{acc | aim: acc.aim - units}
      end)

    horizontal * depth
  end
end
