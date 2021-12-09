defmodule Day8 do
  defmodule UniqueNumberIdentifier do
    @type t() :: %__MODULE__{
            digit: char(),
            segment_count: non_neg_integer(),
            overlap_with_1: non_neg_integer(),
            overlap_with_4: non_neg_integer()
          }
    defstruct [:digit, :segment_count, :overlap_with_1, :overlap_with_4]

    @dialyzer {:nowarn_function, {:new, 3}}
    @spec new(MapSet.t(), MapSet.t(), MapSet.t()) :: Day8.UniqueNumberIdentifier.t()
    def new(%MapSet{} = pattern, %MapSet{} = pattern_1, %MapSet{} = pattern_4) do
      case %__MODULE__{
        segment_count: MapSet.size(pattern),
        overlap_with_1: MapSet.intersection(pattern, pattern_1) |> MapSet.size(),
        overlap_with_4: MapSet.intersection(pattern, pattern_4) |> MapSet.size()
      } do
        %{segment_count: 6, overlap_with_1: 2, overlap_with_4: 3} = identifier ->
          %{identifier | digit: ?0}

        %{segment_count: 2, overlap_with_1: 2, overlap_with_4: 2} = identifier ->
          %{identifier | digit: ?1}

        %{segment_count: 5, overlap_with_1: 1, overlap_with_4: 2} = identifier ->
          %{identifier | digit: ?2}

        %{segment_count: 5, overlap_with_1: 2, overlap_with_4: 3} = identifier ->
          %{identifier | digit: ?3}

        %{segment_count: 4, overlap_with_1: 2, overlap_with_4: 4} = identifier ->
          %{identifier | digit: ?4}

        %{segment_count: 5, overlap_with_1: 1, overlap_with_4: 3} = identifier ->
          %{identifier | digit: ?5}

        %{segment_count: 6, overlap_with_1: 1, overlap_with_4: 3} = identifier ->
          %{identifier | digit: ?6}

        %{segment_count: 3, overlap_with_1: 2, overlap_with_4: 2} = identifier ->
          %{identifier | digit: ?7}

        %{segment_count: 7, overlap_with_1: 2, overlap_with_4: 4} = identifier ->
          %{identifier | digit: ?8}

        %{segment_count: 6, overlap_with_1: 2, overlap_with_4: 4} = identifier ->
          %{identifier | digit: ?9}
      end
    end

    @valid_digits [?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9]

    @spec fetch!(48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57) ::
            Day8.UniqueNumberIdentifier.t()
    def fetch!(digit) when digit in @valid_digits do
      %{
        ?0 => %__MODULE__{digit: ?0, segment_count: 6, overlap_with_1: 2, overlap_with_4: 3},
        ?1 => %__MODULE__{digit: ?1, segment_count: 2, overlap_with_1: 2, overlap_with_4: 2},
        ?2 => %__MODULE__{digit: ?2, segment_count: 5, overlap_with_1: 1, overlap_with_4: 2},
        ?3 => %__MODULE__{digit: ?3, segment_count: 5, overlap_with_1: 2, overlap_with_4: 3},
        ?4 => %__MODULE__{digit: ?4, segment_count: 4, overlap_with_1: 2, overlap_with_4: 4},
        ?5 => %__MODULE__{digit: ?5, segment_count: 5, overlap_with_1: 1, overlap_with_4: 3},
        ?6 => %__MODULE__{digit: ?6, segment_count: 6, overlap_with_1: 1, overlap_with_4: 3},
        ?7 => %__MODULE__{digit: ?7, segment_count: 3, overlap_with_1: 2, overlap_with_4: 2},
        ?8 => %__MODULE__{digit: ?8, segment_count: 7, overlap_with_1: 2, overlap_with_4: 4},
        ?9 => %__MODULE__{digit: ?9, segment_count: 6, overlap_with_1: 2, overlap_with_4: 4}
      }
      |> Map.fetch!(digit)
    end
  end

  @spec solve!() :: String.t()
  def solve!() do
    read_input!()
    |> Stream.map(&parse_input_line(String.trim(&1)))
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 504, res_2: 1_073_431} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_8.txt"))
  end

  @spec parse_input_line(binary) :: {[MapSet.t()], [MapSet.t()]}
  def parse_input_line(input) when is_binary(input) do
    [signal_pattern, output_value] = String.split(input, "|", trim: true)
    signal_patterns = String.split(signal_pattern, " ", trim: true)
    output_values = String.split(output_value, " ", trim: true)

    {Enum.map(signal_patterns, &MapSet.new(String.to_charlist(&1))),
     Enum.map(output_values, &MapSet.new(String.to_charlist(&1)))}
  end

  @spec solve_1(Enumerable.t()) :: non_neg_integer()
  def solve_1(inputs) do
    Stream.flat_map(inputs, fn {_, output_values} ->
      Stream.map(output_values, &MapSet.size/1)
    end)
    |> Enum.count(fn
      2 -> true
      3 -> true
      4 -> true
      7 -> true
      _ -> false
    end)
  end

  @spec solve_2(Enumerable.t()) :: non_neg_integer()
  def solve_2(inputs) do
    identifier_0 = UniqueNumberIdentifier.fetch!(?0)
    identifier_1 = UniqueNumberIdentifier.fetch!(?1)
    identifier_2 = UniqueNumberIdentifier.fetch!(?2)
    identifier_3 = UniqueNumberIdentifier.fetch!(?3)
    identifier_4 = UniqueNumberIdentifier.fetch!(?4)
    identifier_5 = UniqueNumberIdentifier.fetch!(?5)
    identifier_6 = UniqueNumberIdentifier.fetch!(?6)
    identifier_7 = UniqueNumberIdentifier.fetch!(?7)
    identifier_8 = UniqueNumberIdentifier.fetch!(?8)
    identifier_9 = UniqueNumberIdentifier.fetch!(?9)

    Stream.map(inputs, fn {signal_patterns, output_values} ->
      {pattern_1, pattern_4} =
        Stream.map(signal_patterns, &{&1, MapSet.size(&1)})
        |> Enum.reduce({nil, nil}, fn
          {pattern, 2}, {_, pattern_4} -> {pattern, pattern_4}
          {pattern, 4}, {pattern_1, _} -> {pattern_1, pattern}
          _, acc -> acc
        end)

      pattern_map =
        Stream.map(signal_patterns, &{&1, UniqueNumberIdentifier.new(&1, pattern_1, pattern_4)})
        |> Enum.reduce(%{}, fn
          {pattern, ^identifier_0}, acc -> Map.put_new(acc, pattern, identifier_0)
          {pattern, ^identifier_1}, acc -> Map.put_new(acc, pattern, identifier_1)
          {pattern, ^identifier_2}, acc -> Map.put_new(acc, pattern, identifier_2)
          {pattern, ^identifier_3}, acc -> Map.put_new(acc, pattern, identifier_3)
          {pattern, ^identifier_4}, acc -> Map.put_new(acc, pattern, identifier_4)
          {pattern, ^identifier_5}, acc -> Map.put_new(acc, pattern, identifier_5)
          {pattern, ^identifier_6}, acc -> Map.put_new(acc, pattern, identifier_6)
          {pattern, ^identifier_7}, acc -> Map.put_new(acc, pattern, identifier_7)
          {pattern, ^identifier_8}, acc -> Map.put_new(acc, pattern, identifier_8)
          {pattern, ^identifier_9}, acc -> Map.put_new(acc, pattern, identifier_9)
        end)

      Stream.map(output_values, &Map.fetch!(pattern_map, &1).digit)
      |> Enum.to_list()
      |> List.to_integer()
    end)
    |> Enum.sum()
  end
end
