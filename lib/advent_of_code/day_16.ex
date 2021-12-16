defmodule Day16 do
  @spec solve! :: String.t()
  def solve! do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 3259, res_2: 3_459_174_981_021} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_16.txt"))
  end

  def parse_input(line) do
    binary_string = String.to_integer(line, 16) |> Integer.to_string(2)
    binary_string_length = String.length(binary_string)
    desired_string_length = ceil(binary_string_length / 8) * 8

    String.pad_leading(binary_string, desired_string_length, "0")
  end

  def solve_1(bit_string) do
    # IO.inspect(bit_string, label: :bit_string)
    parse(bit_string)
  end

  @binary_four "100"

  def parse(bit_string, acc \\ %{})

  def parse(<<version::binary-size(3), @binary_four, rest::binary>>, acc) do
    version = String.to_integer(version, 2)
    {_number, rest} = parse_group(rest)
    acc = Map.update(acc, :version_sum, version, &(&1 + version))

    {rest, acc}
  end

  def parse(
        <<version::binary-size(3), _type_id::binary-size(3), "0", packet_bits::binary-size(15),
          rest::binary>>,
        acc
      ) do
    version = String.to_integer(version, 2)
    # IO.inspect(packet_bits, label: :packet_bits)

    packet_bits = String.to_integer(packet_bits, 2)
    acc = Map.update(acc, :version_sum, version, &(&1 + version))
    # IO.inspect(packet_bits, label: :packet_bits)
    # IO.inspect(rest)
    <<packets::binary-size(packet_bits), rest::binary>> = rest

    {"", acc} =
      Enum.reduce_while(0..packet_bits, {packets, acc}, fn
        _, {"", acc} ->
          {:halt, {"", acc}}

        _, {packets, acc} ->
          {rest, acc} = parse(packets, acc)
          {:cont, {rest, acc}}
      end)

    {rest, acc}
  end

  def parse(
        <<version::binary-size(3), _type_id::binary-size(3), "1", packet_count::binary-size(11),
          rest::binary>>,
        acc
      ) do
    version = String.to_integer(version, 2)
    acc = Map.update(acc, :version_sum, version, &(&1 + version))

    packet_count = String.to_integer(packet_count, 2)

    Enum.reduce(1..packet_count, {rest, acc}, fn _, {rest, acc} ->
      parse(rest, acc)
    end)
  end

  def parse_group(group, acc \\ "")

  def parse_group(<<"1", number_part::binary-size(4), rest::binary>>, acc) do
    parse_group(rest, acc <> number_part)
  end

  def parse_group(<<"0", number_part::binary-size(4), rest::binary>>, acc) do
    {String.to_integer(acc <> number_part, 2), rest}
  end

  def solve_2(bit_string) do
  end
end
