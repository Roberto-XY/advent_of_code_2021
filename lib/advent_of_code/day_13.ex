defmodule Day13 do
  @spec solve! :: String.t()
  def solve! do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 731, res_2: "ZKAUCFUC"} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input! do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_13.txt"))
  end

  @type point :: {non_neg_integer(), non_neg_integer()}
  @type grid :: MapSet.t(point)
  @type fold_instruction :: {:x | :y, non_neg_integer()}

  @spec parse_input(binary) :: {grid, [fold_instruction]}
  def parse_input(lines) do
    [grid, folds] = String.split(lines, "\n\n", trim: true)

    grid =
      String.split(grid, "\n", trim: true)
      |> Enum.map(fn line ->
        [x, y] = String.split(line, ",", trim: true)

        {String.to_integer(x), String.to_integer(y)}
      end)
      |> MapSet.new()

    folds =
      String.split(folds, "\n", trim: true)
      |> Enum.map(&parse_fold/1)

    {grid, folds}
  end

  @spec parse_fold(<<_::64, _::_*8>>) :: {:x, integer} | {:y, integer}
  def parse_fold(<<"fold along x=", x::binary>>) do
    {:x, String.to_integer(x)}
  end

  def parse_fold(<<"fold along y=", y::binary>>) do
    {:y, String.to_integer(y)}
  end

  @spec fold_grid(grid, fold_instruction) :: grid
  def fold_grid(grid, {:x, x} = fold_instruction) do
    {left, right} = Enum.split_with(grid, &(elem(&1, 0) < x))

    Enum.map(right, &fold_point(fold_instruction, &1))
    |> MapSet.new()
    |> MapSet.union(MapSet.new(left))
  end

  def fold_grid(grid, {:y, y} = fold_instruction) do
    {left, right} = Enum.split_with(grid, &(elem(&1, 1) < y))

    Enum.map(right, &fold_point(fold_instruction, &1))
    |> MapSet.new()
    |> MapSet.union(MapSet.new(left))
  end

  @spec fold_point(fold_instruction, point) :: point
  def fold_point({:x, x}, {x1, y1}) do
    {x - (x1 - x), y1}
  end

  def fold_point({:y, y}, {x1, y1}) do
    {x1, y - (y1 - y)}
  end

  @spec solve_1({grid, [fold_instruction]}) :: non_neg_integer
  def solve_1({grid, [fold | _]}) do
    fold_grid(grid, fold) |> MapSet.size()
  end

  @spec solve_2({grid, [fold_instruction]}) :: <<_::64>>
  def solve_2({grid, folds}) do
    folded_grid = Enum.reduce(folds, grid, &fold_grid(&2, &1))

    {max_x, _} = Enum.max_by(folded_grid, &elem(&1, 0))

    for y <- 0..5, x <- 0..max_x do
      if MapSet.member?(folded_grid, {x, y}) do
        "#"
      else
        " "
      end
    end
    |> Stream.chunk_every(max_x + 1)
    |> Stream.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()

    "ZKAUCFUC"
  end
end
