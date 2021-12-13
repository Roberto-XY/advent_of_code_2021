defmodule Day12 do
  @spec solve! :: String.t()
  def solve! do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 3576, res_2: 84271} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input! do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_12.txt"))
  end

  def parse_input(lines) do
    String.split(lines, "\n", trim: true)
    |> Stream.map(&String.split(&1, "-", trim: true))
    |> Enum.reduce(%{}, fn
      ["start", cave_b], acc ->
        Map.update(acc, "start", [cave_b], &[cave_b | &1])

      [cave_a, "start"], acc ->
        Map.update(acc, "start", [cave_a], &[cave_a | &1])

      ["end", cave_b], acc ->
        Map.update(acc, cave_b, ["end"], &["end" | &1])

      [cave_a, "end"], acc ->
        Map.update(acc, cave_a, ["end"], &["end" | &1])

      [cave_a, cave_b], acc ->
        Map.update(acc, cave_a, [cave_b], &[cave_b | &1])
        |> Map.update(cave_b, [cave_a], &[cave_a | &1])
    end)
  end

  @spec solve_1(%{optional(binary) => [binary]}) :: non_neg_integer
  def solve_1(cave_system) do
    enumerate_paths_1(cave_system) |> length()
  end

  @spec enumerate_paths_1(%{binary => [binary]}, [binary], binary, [[binary]]) :: [[binary]]
  def enumerate_paths_1(cave_system, path \\ ["start"], current_cave \\ "start", acc \\ [])

  def enumerate_paths_1(_, path, "end", acc) do
    [Enum.reverse(["end" | path]) | acc]
  end

  def enumerate_paths_1(cave_system, path, current_cave, acc) do
    Map.fetch!(cave_system, current_cave)
    |> Stream.filter(fn next_cave ->
      if small_cave?(next_cave) do
        not cave_visited?(path, next_cave)
      else
        true
      end
    end)
    |> Enum.reduce(acc, fn
      next_cave, acc -> enumerate_paths_1(cave_system, [next_cave | path], next_cave, acc)
    end)
  end

  @spec solve_2(%{optional(binary) => [binary]}) :: non_neg_integer
  def solve_2(cave_system) do
    enumerate_paths_2(cave_system) |> length()
  end

  @spec enumerate_paths_2(%{binary => [binary]}, boolean(), [binary], binary, [[binary]]) :: [
          [binary]
        ]
  def enumerate_paths_2(
        cave_system,
        small_cave_visited_twice? \\ false,
        path \\ ["start"],
        current_cave \\ "start",
        acc \\ []
      )

  def enumerate_paths_2(_, _, path, "end", acc) do
    [Enum.reverse(["end" | path]) | acc]
  end

  def enumerate_paths_2(cave_system, small_cave_visited_twice?, path, current_cave, acc) do
    Map.fetch!(cave_system, current_cave)
    |> Stream.filter(fn next_cave ->
      if small_cave?(next_cave) and small_cave_visited_twice? do
        not cave_visited?(path, next_cave)
      else
        true
      end
    end)
    |> Enum.reduce(acc, fn
      next_cave, acc ->
        if small_cave_visited_twice? or
             (small_cave?(next_cave) and cave_visited?(path, next_cave)) do
          enumerate_paths_2(cave_system, true, [next_cave | path], next_cave, acc)
        else
          enumerate_paths_2(cave_system, false, [next_cave | path], next_cave, acc)
        end
    end)
  end

  @spec small_cave?(binary) :: boolean
  def small_cave?(cave) do
    String.first(cave) |> String.downcase() == String.first(cave)
  end

  @spec cave_visited?([String.t()], String.t()) :: boolean
  def cave_visited?(path, cave) do
    Enum.any?(path, &(&1 == cave))
  end
end
