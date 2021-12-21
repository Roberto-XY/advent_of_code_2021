defmodule Day20 do
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

  @spec solve!() :: String.rest()
  def solve!() do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 5259, res_2: 15287} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_20.txt"))
  end

  def parse_input(lines) do
    [decode_string, picture] = String.split(lines, "\n\n", trim: true)

    decode_string = String.replace(decode_string, "\n", "")

    picture_rows = String.split(picture, "\n", trim: true)

    picture =
      Stream.map(
        picture_rows,
        fn row ->
          String.split(row, "", trim: true)
        end
      )
      |> Enum.to_list()

    %{picture: picture, decode_string: decode_string}
  end

  def solve_1(%{picture: picture, decode_string: decode_string}) do
    Enum.reduce(0..1, picture, fn i, picture ->
      default = if rem(i, 2) == 0, do: ".", else: String.at(decode_string, 0)

      add_padding(picture, default)
      |> decode_picture(decode_string, default)
    end)
    |> Stream.concat()
    |> Enum.count(&(&1 == "#"))
  end

  def decode_picture(picture, decode_string, default) do
    Stream.with_index(picture)
    |> Stream.map(fn {row, row_i} ->
      new_row =
        Stream.with_index(row)
        |> Stream.map(fn {_, col_i} ->
          neighbors = [
            {row_i - 1, col_i - 1},
            {row_i - 1, col_i},
            {row_i - 1, col_i + 1},
            {row_i, col_i - 1},
            {row_i, col_i},
            {row_i, col_i + 1},
            {row_i + 1, col_i - 1},
            {row_i + 1, col_i},
            {row_i + 1, col_i + 1}
          ]

          pixel_index =
            Stream.map(neighbors, fn {neighbor_row_i, neighbor_col_i} ->
              case Enum.at(picture, neighbor_row_i) do
                nil -> default
                col -> Enum.at(col, neighbor_col_i, default)
              end
            end)
            |> Enum.to_list()

          # IO.puts("#{row_i}, #{col_i}")

          # Enum.chunk_every(pixel_index, 3)
          # |> Enum.join("\n")
          # |> IO.puts()

          pixel_index =
            pixel_index
            |> Stream.map(fn
              "." -> 0
              "#" -> 1
            end)
            |> Enum.join()
            # |> IO.inspect(label: "#{row_i}, #{col_i}")
            |> String.to_integer(2)

          # |> IO.inspect(label: "#{row_i}, #{col_i}")

          # IO.puts("\n")

          String.at(decode_string, pixel_index)
        end)
        |> Enum.to_list()

      # IO.puts("\n")

      new_row
    end)
    |> Enum.to_list()
  end

  def add_padding(picture, default) do
    first_row = hd(picture)
    row_padding = List.duplicate(default, length(first_row))
    column_padding = List.duplicate(default, 2)

    picture = [row_padding, row_padding | picture]
    picture = [row_padding, row_padding | Enum.reverse(picture)] |> Enum.reverse()

    Enum.map(picture, fn row -> Enum.concat([column_padding, row, column_padding]) end)
  end

  def solve_2(%{decode_string: decode_string, picture: picture}) do
    Enum.reduce(0..49, picture, fn i, picture ->
      # Stream.map(picture, &Enum.join/1)
      # |> Enum.join("\n")
      # |> IO.puts()

      # IO.puts("\n")
      default = if rem(i, 2) == 0, do: ".", else: String.at(decode_string, 0)

      picture = add_padding(picture, default)

      # Stream.map(picture, &Enum.join/1)
      # |> Enum.join("\n")
      # |> IO.puts()

      # IO.puts("\n")

      picture = decode_picture(picture, decode_string, default)

      # Stream.map(picture, &Enum.join/1)
      # |> Enum.join("\n")
      # |> IO.puts()

      # IO.puts("\n")
      # IO.puts("\n")
      # IO.puts("\n")

      picture

      # |> IO.inspect()
    end)
    |> Stream.concat()
    |> Enum.count(&(&1 == "#"))
  end
end
