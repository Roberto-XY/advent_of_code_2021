defmodule Day3 do
  @example_input [
    [?0, ?0, ?1, ?0, ?0],
    [?1, ?1, ?1, ?1, ?0],
    [?1, ?0, ?1, ?1, ?0],
    [?1, ?0, ?1, ?1, ?1],
    [?1, ?0, ?1, ?0, ?1],
    [?0, ?1, ?1, ?1, ?1],
    [?0, ?0, ?1, ?1, ?1],
    [?1, ?1, ?1, ?0, ?0],
    [?1, ?0, ?0, ?0, ?0],
    [?1, ?1, ?0, ?0, ?1],
    [?0, ?0, ?0, ?1, ?0],
    [?0, ?1, ?0, ?1, ?0]
  ]

  @spec read_input! :: Enumerable.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_3.txt"))
    |> Stream.map(&String.to_charlist(String.trim(&1)))
  end

  @spec solve_1(Enumerable.t()) :: integer()
  def solve_1(enum \\ @example_input) do
    gamma_bits =
      Enum.zip_reduce(enum, [], fn index_list, acc ->
        one_count = Enum.count(index_list, &(&1 == ?1))
        zero_count = length(index_list) - one_count
        gamma_bit = if zero_count <= one_count, do: ?1, else: ?0

        [gamma_bit | acc]
      end)
      |> :lists.reverse()

    epsilon_bits =
      Enum.map(gamma_bits, fn
        ?0 -> ?1
        ?1 -> ?0
      end)

    gamma = String.to_integer(List.to_string(gamma_bits), 2)
    epsilon = String.to_integer(List.to_string(epsilon_bits), 2)

    gamma * epsilon
  end

  @spec solve_2(Enumerable.t()) :: integer()
  def solve_2(numbers \\ @example_input) do
    numbers = Stream.map(numbers, &List.to_tuple/1) |> Enum.to_list()

    %{o2_generator_rating: o2_generator_rating, co2_scrubber_rating: co2_scrubber_rating} =
      do_solve_2(numbers, numbers)

    o2_generator_rating * co2_scrubber_rating
  end

  @spec do_solve_2([tuple()], [tuple()], non_neg_integer()) :: %{
          co2_scrubber_rating: integer,
          o2_generator_rating: integer
        }
  def do_solve_2(o2_generator_ratings, co2_scrubber_ratings, index \\ 0)

  def do_solve_2([o2_generator_rating], [co2_scrubber_rating], _index) do
    o2_generator_rating =
      Tuple.to_list(o2_generator_rating) |> List.to_string() |> String.to_integer(2)

    co2_scrubber_rating =
      Tuple.to_list(co2_scrubber_rating) |> List.to_string() |> String.to_integer(2)

    %{o2_generator_rating: o2_generator_rating, co2_scrubber_rating: co2_scrubber_rating}
  end

  def do_solve_2(o2_generator_ratings, co2_scrubber_ratings, index) do
    o2_generator_ratings =
      if length(o2_generator_ratings) > 1 do
        update_rating(o2_generator_ratings, index, fn one_count, zero_count ->
          if one_count >= zero_count, do: ?1, else: ?0
        end)
      else
        o2_generator_ratings
      end

    co2_scrubber_ratings =
      if length(co2_scrubber_ratings) > 1 do
        update_rating(co2_scrubber_ratings, index, fn one_count, zero_count ->
          if zero_count <= one_count, do: ?0, else: ?1
        end)
      else
        co2_scrubber_ratings
      end

    do_solve_2(o2_generator_ratings, co2_scrubber_ratings, index + 1)
  end

  @spec update_rating(
          [tuple()],
          non_neg_integer(),
          (non_neg_integer(), non_neg_integer() -> ?0 | ?1)
        ) :: [tuple()]
  def update_rating(numbers, index, fun) do
    one_count = Enum.count(numbers, &(elem(&1, index) == ?1))
    zero_count = length(numbers) - one_count
    to_keep = fun.(one_count, zero_count)
    Enum.filter(numbers, &(elem(&1, index) == to_keep))
  end
end
