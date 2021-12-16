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

  @type packet :: operator_packet | value_packet

  @type operator_packet :: %{version: integer(), operator: operator, children: [packet]}
  @type value_packet :: %{version: integer(), value: integer()}

  @type operator :: :sum | :product | :minimum | :maximum | :greater_than | :less_than | :equal_to

  @binary_four "100"

  @spec solve_1(<<_::48, _::_*8>>) :: integer()
  def solve_1(bit_string) do
    {_rest, packet} = parse(bit_string)
    sum_versions(packet)
  end

  @spec sum_versions(packet) :: integer()
  def sum_versions(%{version: version, value: _}) do
    version
  end

  def sum_versions(%{version: version, children: child_packets}) do
    version + (Stream.map(child_packets, &sum_versions(&1)) |> Enum.sum())
  end

  @spec solve_2(<<_::48, _::_*8>>) :: integer
  def solve_2(bit_string) do
    {_rest, packet} = parse(bit_string)
    interpret_package(packet)
  end

  def interpret_package(%{operator: :sum, children: child_packets}) do
    Stream.map(child_packets, &interpret_package(&1)) |> Enum.sum()
  end

  def interpret_package(%{operator: :product, children: child_packets}) do
    Stream.map(child_packets, &interpret_package(&1)) |> Enum.product()
  end

  def interpret_package(%{operator: :minimum, children: child_packets}) do
    Stream.map(child_packets, &interpret_package(&1)) |> Enum.min()
  end

  def interpret_package(%{operator: :maximum, children: child_packets}) do
    Stream.map(child_packets, &interpret_package(&1)) |> Enum.max()
  end

  def interpret_package(%{operator: :greater_than, children: [a, b]}) do
    if interpret_package(a) > interpret_package(b), do: 1, else: 0
  end

  def interpret_package(%{operator: :less_than, children: [a, b]}) do
    if interpret_package(a) < interpret_package(b), do: 1, else: 0
  end

  def interpret_package(%{operator: :equal_to, children: [a, b]}) do
    if interpret_package(a) == interpret_package(b), do: 1, else: 0
  end

  def interpret_package(%{value: value}) do
    value
  end

  # @spec parse(<<_::64, _::_*8>>) :: packet
  def parse(bit_string)

  def parse(<<version::binary-size(3), @binary_four, rest::binary>>) do
    version = String.to_integer(version, 2)
    {number, rest} = parse_group(rest)
    {rest, create_packet(version, 4, number)}
  end

  def parse(
        <<version::binary-size(3), type_id::binary-size(3), "0", packet_bits::binary-size(15),
          rest::binary>>
      ) do
    version = String.to_integer(version, 2)
    type_id = String.to_integer(type_id, 2)
    # IO.inspect(packet_bits, label: :packet_bits)

    packet_bits = String.to_integer(packet_bits, 2)
    # IO.inspect(packet_bits, label: :packet_bits)
    # IO.inspect(rest)
    <<packets_binary::binary-size(packet_bits), rest::binary>> = rest

    {"", child_packets} =
      Enum.reduce_while(0..packet_bits, {packets_binary, []}, fn
        _, {"", acc} ->
          {:halt, {"", Enum.reverse(acc)}}

        _, {packets_binary, acc} ->
          {rest, packet} = parse(packets_binary)
          {:cont, {rest, [packet | acc]}}
      end)

    {rest, create_packet(version, type_id, child_packets)}
  end

  def parse(
        <<version::binary-size(3), type_id::binary-size(3), "1", packet_count::binary-size(11),
          rest::binary>>
      ) do
    version = String.to_integer(version, 2)
    type_id = String.to_integer(type_id, 2)

    packet_count = String.to_integer(packet_count, 2)

    {rest, child_packets} =
      Enum.reduce(1..packet_count, {rest, []}, fn _, {rest, acc} ->
        {rest, packet} = parse(rest)
        {rest, [packet | acc]}
      end)

    child_packets = Enum.reverse(child_packets)

    {rest, create_packet(version, type_id, child_packets)}
  end

  @spec parse_group(<<_::40, _::_*8>>, binary) :: {integer, binary}
  def parse_group(group, acc \\ "")

  def parse_group(<<"1", number_part::binary-size(4), rest::binary>>, acc) do
    parse_group(rest, acc <> number_part)
  end

  def parse_group(<<"0", number_part::binary-size(4), rest::binary>>, acc) do
    {String.to_integer(acc <> number_part, 2), rest}
  end

  def create_packet(version, type_id, value) do
    case type_id do
      0 -> %{version: version, operator: :sum, children: value}
      1 -> %{version: version, operator: :product, children: value}
      2 -> %{version: version, operator: :minimum, children: value}
      3 -> %{version: version, operator: :maximum, children: value}
      4 -> %{version: version, value: value}
      5 -> %{version: version, operator: :greater_than, children: value}
      6 -> %{version: version, operator: :less_than, children: value}
      7 -> %{version: version, operator: :equal_to, children: value}
    end
  end
end
