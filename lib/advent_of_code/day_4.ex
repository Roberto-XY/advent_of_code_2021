defmodule Day4 do
  @example_input """
  7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

  22 13 17 11  0
  8  2 23  4 24
  21  9 14 16  7
  6 10  3 18  5
  1 12 20 15 19

  3 15  0  2 22
  9 18 13 17  5
  19  8  7 25 23
  20 11 10 24  4
  14 21 16 12  6

  14 21 17 24  4
  10 16 15  9 19
  18  8 23 26 20
  22 11 13  6  5
  2  0 12  3  7
  """

  defmodule BingoBoard do
    @type square :: %{number: integer(), crossed_out: boolean()}

    @type t :: %__MODULE__{
            size: non_neg_integer(),
            rows: [square()]
          }
    defstruct [:size, :rows]

    @spec new(non_neg_integer, list) :: __MODULE__.t()
    def new(size, board)
        when is_integer(size) and size > 0 and is_list(board) and length(board) == size do
      %__MODULE__{
        size: size,
        rows:
          Enum.map(board, fn row when is_list(row) and length(row) == size ->
            Enum.map(row, fn square_num -> %{number: square_num, crossed_out: false} end)
          end)
      }
    end

    @spec cross_out(__MODULE__.t(), integer()) :: __MODULE__.t()
    def cross_out(%__MODULE__{rows: rows} = board, number) do
      %{
        board
        | rows:
            Enum.map(rows, fn row ->
              Enum.map(row, fn
                %{number: ^number, crossed_out: false} ->
                  %{number: number, crossed_out: true}

                square ->
                  square
              end)
            end)
      }
    end

    @spec bingo?(__MODULE__.t()) :: boolean
    def bingo?(%__MODULE__{rows: rows}) do
      any_rows? = Enum.any?(rows, &bingo_line?/1)

      any_columns? =
        Enum.zip_reduce(rows, [], &[&1 | &2])
        |> Enum.any?(&bingo_line?/1)

      any_rows? or any_columns?
    end

    defp bingo_line?(line) when is_list(line) do
      Enum.all?(line, & &1.crossed_out)
    end

    @spec score(__MODULE__.t(), integer) :: number
    def score(%__MODULE__{rows: rows}, multiplier) when is_integer(multiplier) do
      (Enum.map(
         rows,
         fn row ->
           Enum.filter(row, &(!&1.crossed_out))
           |> Enum.map(& &1.number)
           |> Enum.sum()
         end
       )
       |> Enum.sum()) * multiplier
    end
  end

  @type direction() :: :forward | :down | :up

  @spec read_input!() :: %{numbers: [integer()], boards: [BingoBoard.t()]}
  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_4.txt"))
    |> parse_input()
  end

  @spec parse_input(binary) :: %{numbers: [integer()], boards: [BingoBoard.t()]}
  def parse_input(input \\ @example_input) when is_binary(input) do
    [numbers, boards] = String.split(input, "\n", trim: true, parts: 2)

    numbers =
      String.split(numbers, ",", trim: true)
      |> Enum.map(fn s ->
        {res, _} = Integer.parse(s)
        res
      end)

    boards =
      String.split(boards, "\n\n", trim: false)
      |> Enum.map(fn board ->
        String.split(board, "\n", trim: true)
        |> Enum.map(fn row ->
          String.split(row, " ", trim: true)
          |> Enum.map(fn s ->
            {res, _} = Integer.parse(s)
            res
          end)
        end)
      end)
      |> Enum.map(fn board ->
        BingoBoard.new(length(board), board)
      end)

    %{numbers: numbers, boards: boards}
  end

  @spec solve_1(%{numbers: [integer()], boards: [BingoBoard.t()]}) :: [BingoBoard.t()] | integer()
  def solve_1(%{numbers: numbers, boards: boards}) do
    Enum.reduce_while(numbers, boards, fn number, boards ->
      boards = Enum.map(boards, &BingoBoard.cross_out(&1, number))

      case Enum.find(boards, &BingoBoard.bingo?/1) do
        nil -> {:cont, boards}
        bingo_board -> {:halt, BingoBoard.score(bingo_board, number)}
      end
    end)
  end

  @spec solve_2(%{numbers: [integer()], boards: [BingoBoard.t()]}) :: [BingoBoard.t()] | integer()
  def solve_2(%{numbers: numbers, boards: boards}) do
    Enum.reduce_while(numbers, boards, fn number, boards ->
      boards = Enum.map(boards, &BingoBoard.cross_out(&1, number))

      case Enum.filter(boards, &(!BingoBoard.bingo?(&1))) do
        [] ->
          {:halt, BingoBoard.score(hd(boards), number)}

        boards ->
          {:cont, boards}
      end
    end)
  end
end
