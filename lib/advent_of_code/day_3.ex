defmodule Day3 do
  @example_input [
    [0, 0, 1, 0, 0],
    [1, 1, 1, 1, 0],
    [1, 0, 1, 1, 0],
    [1, 0, 1, 1, 1],
    [1, 0, 1, 0, 1],
    [0, 1, 1, 1, 1],
    [0, 0, 1, 1, 1],
    [1, 1, 1, 0, 0],
    [1, 0, 0, 0, 0],
    [1, 1, 0, 0, 1],
    [0, 0, 0, 1, 0],
    [0, 1, 0, 1, 0]
  ]

  @type direction() :: :forward | :down | :up

  @spec read_input! :: Enumerable.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_3.txt"))
    |> Stream.map(&parse_line/1)
  end

  @spec parse_line(bitstring()) :: [0 | 1]
  defp parse_line(line) do
    String.trim(line)
    |> String.to_charlist()
    |> Enum.map(fn
      ?0 -> 0
      ?1 -> 1
    end)
  end

  @spec solve_1([[0 | 1]]) :: integer()
  def solve_1(enum \\ @example_input) do
    gamma_bits =
      Enum.zip_reduce(enum, [], fn index_list, acc ->
        one_count = Enum.sum(index_list)
        zero_count = length(index_list) - one_count

        gamma_bit =
          if zero_count <= one_count do
            '1'
          else
            '0'
          end

        [gamma_bit | acc]
      end)
      |> :lists.reverse()

    epsilon_bits =
      Enum.map(gamma_bits, fn
        '0' -> '1'
        '1' -> '0'
      end)

    {gamma, _} = Integer.parse(List.to_string(gamma_bits), 2)
    {epsilon, _} = Integer.parse(List.to_string(epsilon_bits), 2)

    gamma * epsilon
  end

  @spec solve_2([[0 | 1]]) :: integer()
  def solve_2(enum \\ @example_input) do
    enum = Enum.to_list(enum)

    {:done, {oxygen_generator_rating_bits, co2_scrubber_rating_bits}} =
      Stream.unfold({enum, enum, 0}, fn
        {[], [], _} ->
          nil

        {oxygen_generator_rating, co2_scrubber_rating, index} ->
          oxygen_generator_rating =
            if length(oxygen_generator_rating) > 1 do
              index_list = Enum.map(oxygen_generator_rating, &Enum.at(&1, index))
              one_count = Enum.sum(index_list)
              zero_count = length(index_list) - one_count

              if zero_count <= one_count do
                Enum.filter(oxygen_generator_rating, fn x -> Enum.at(x, index) == 1 end)
              else
                Enum.filter(oxygen_generator_rating, fn x -> Enum.at(x, index) == 0 end)
              end
            else
              oxygen_generator_rating
            end

          co2_scrubber_rating =
            if length(co2_scrubber_rating) > 1 do
              index_list = Enum.map(co2_scrubber_rating, &Enum.at(&1, index))
              one_count = Enum.sum(index_list)
              zero_count = length(index_list) - one_count

              if zero_count > one_count do
                Enum.filter(co2_scrubber_rating, fn x -> Enum.at(x, index) == 1 end)
              else
                Enum.filter(co2_scrubber_rating, fn x -> Enum.at(x, index) == 0 end)
              end
            else
              co2_scrubber_rating
            end

          case {oxygen_generator_rating, co2_scrubber_rating} do
            {[hd0], [hd1]} ->
              {{hd0, hd1}, {[], [], index + 1}}

            _ ->
              {nil, {oxygen_generator_rating, co2_scrubber_rating, index + 1}}
          end
      end)
      |> Enumerable.reduce({:cont, nil}, fn x, _ ->
        {:cont, x}
      end)

    {oxygen_generator_rating, _} =
      Integer.parse(
        List.to_string(
          Enum.map(oxygen_generator_rating_bits, fn
            0 -> '0'
            1 -> '1'
          end)
        ),
        2
      )

    {co2_scrubber_rating, _} =
      Integer.parse(
        List.to_string(
          Enum.map(co2_scrubber_rating_bits, fn
            0 -> '0'
            1 -> '1'
          end)
        ),
        2
      )

    oxygen_generator_rating * co2_scrubber_rating
  end
end
