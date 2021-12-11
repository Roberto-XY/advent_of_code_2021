defmodule Day11 do
  defmodule Grid do
    @type element :: any
    @type t :: %{optional(non_neg_integer) => %{optional(non_neg_integer) => any}}

    @spec new(Enumerable.t()) :: t
    def new(rows) do
      Stream.map(
        rows,
        fn row ->
          Stream.with_index(row)
          |> Stream.map(fn {a, b} -> {b, a} end)
          |> Enum.into(%{})
        end
      )
      |> Stream.with_index()
      |> Stream.map(fn {a, b} -> {b, a} end)
      |> Enum.into(%{})
    end

    @spec fetch!(__MODULE__.t(), non_neg_integer, non_neg_integer) :: element
    def fetch!(grid, row_i, col_i) do
      Map.fetch!(grid, row_i) |> Map.fetch!(col_i)
    end

    @spec on_grid?(__MODULE__.t(), non_neg_integer, non_neg_integer) :: boolean
    def on_grid?(grid, row_i, col_i) do
      case Map.fetch(grid, row_i) do
        {:ok, row} ->
          case Map.fetch(row, col_i) do
            {:ok, _} -> true
            _ -> false
          end

        _ ->
          false
      end
    end

    @spec neighbors(__MODULE__.t(), non_neg_integer, non_neg_integer) :: [
            {non_neg_integer, non_neg_integer}
          ]
    def neighbors(grid, row_i, col_i) do
      [
        {row_i - 1, col_i - 1},
        {row_i - 1, col_i},
        {row_i - 1, col_i + 1},
        {row_i, col_i + 1},
        {row_i + 1, col_i + 1},
        {row_i + 1, col_i},
        {row_i + 1, col_i - 1},
        {row_i, col_i - 1}
      ]
      |> Enum.filter(fn {row_i, col_i} -> on_grid?(grid, row_i, col_i) end)
    end

    @spec map(t, (element -> any)) :: t
    def map(grid, fun) do
      Stream.map(grid, fn {row_i, row} ->
        new_row =
          Stream.map(row, fn {col_i, val} ->
            {col_i, fun.(val)}
          end)
          |> Enum.into(%{})

        {row_i, new_row}
      end)
      |> Enum.into(%{})
    end

    @spec all?(t, (element -> boolean)) :: boolean
    def all?(grid, fun) do
      Stream.map(grid, fn {_, row} ->
        Stream.map(row, fn {_, val} ->
          fun.(val)
        end)
        |> Enum.all?()
      end)
      |> Enum.all?()
    end

    @spec update!(t, non_neg_integer, non_neg_integer, (element -> element)) :: t
    def update!(grid, row_i, col_i, fun) do
      new_row =
        Map.fetch!(grid, row_i)
        |> Map.update!(col_i, fun)

      Map.put(grid, row_i, new_row)
    end

    @spec put(t, non_neg_integer, non_neg_integer, element) :: t
    def put(grid, row_i, col_i, value) do
      new_row =
        Map.fetch!(grid, row_i)
        |> Map.put(col_i, value)

      Map.put(grid, row_i, new_row)
    end
  end

  @spec solve! :: String.t()
  def solve! do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 1683, res_2: 788} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input! do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_11.txt"))
  end

  def parse_input(lines) do
    String.split(lines, "\n", trim: true)
    |> Enum.map(fn line ->
      String.to_charlist(line)
      |> Enum.map(&(&1 - ?0))
    end)
    |> Grid.new()
  end

  @spec solve_1(Grid.t()) :: non_neg_integer
  def solve_1(grid) do
    {_, explosion_count} =
      Enum.reduce(0..99, {grid, 0}, fn _, {grid, count} ->
        {new_grid, new_count} = step(grid)
        {new_grid, new_count + count}
      end)

    explosion_count
  end

  @spec solve_2(Grid.t()) :: non_neg_integer
  def solve_2(grid) do
    first_synchronization(grid)
  end

  def first_synchronization(grid, iter \\ 0) do
    if Grid.all?(grid, &(&1 == 0)) do
      iter
    else
      {new_grid, _} = step(grid)
      first_synchronization(new_grid, iter + 1)
    end
  end

  def step(grid) do
    Grid.map(grid, &(&1 + 1))
    |> explode_all()
  end

  def explode_all(grid, count \\ 0) do
    Enum.reduce(grid, {grid, count}, fn {row_i, row}, acc ->
      Enum.reduce(row, acc, fn {col_i, _}, {grid, count} ->
        {new_grid, add_count} = explode(grid, row_i, col_i)
        {new_grid, count + add_count}
      end)
    end)
  end

  def explode(grid, row_i, col_i) do
    case Grid.fetch!(grid, row_i, col_i) do
      val when val > 9 ->
        grid = Grid.put(grid, row_i, col_i, 0)

        Grid.neighbors(grid, row_i, col_i)
        |> Enum.reduce({grid, 1}, fn {row_i, col_i}, {grid, count} ->
          {new_grid, new_count} =
            Grid.update!(grid, row_i, col_i, fn
              0 -> 0
              val -> val + 1
            end)
            |> explode(row_i, col_i)

          {new_grid, new_count + count}
        end)

      _ ->
        {grid, 0}
    end
  end
end
