defmodule Day22 do
  defmodule Cuboid do
    @type t :: %__MODULE__{
            x: Range.t(integer, integer),
            y: Range.t(integer, integer),
            z: Range.t(integer, integer),
            carved_out: [t]
          }

    defstruct [:x, :y, :z, carved_out: []]

    @spec new(Range.t(), Range.t(), Range.t()) :: t()
    def new(%Range{} = x_dim, %Range{} = y_dim, %Range{} = z_dim) do
      %__MODULE__{x: x_dim, y: y_dim, z: z_dim}
    end

    @spec subtract(t(), t()) :: t()
    def subtract(%__MODULE__{} = minuend, %__MODULE__{} = subtrahend) do
      case intersect(minuend, subtrahend) do
        nil ->
          minuend

        intersection ->
          carved_out = Enum.map(minuend.carved_out, &subtract(&1, intersection))
          %{minuend | carved_out: [intersection | carved_out]}
      end
    end

    @spec volume(t()) :: non_neg_integer()
    def volume(%__MODULE__{x: x, y: y, z: z, carved_out: carved_out}) do
      carved_out_volume = Stream.map(carved_out, &volume/1) |> Enum.sum()

      Range.size(x) * Range.size(y) * Range.size(z) - carved_out_volume
    end

    @spec intersect(t(), t()) :: nil | t()
    def intersect(%__MODULE__{} = cube1, %__MODULE__{} = cube2) do
      x_dim = intersect_range(cube1.x, cube2.x)
      y_dim = intersect_range(cube1.y, cube2.y)
      z_dim = intersect_range(cube1.z, cube2.z)

      if Enum.any?([x_dim, y_dim, z_dim], &is_nil/1) do
        nil
      else
        new(x_dim, y_dim, z_dim)
      end
    end

    @spec intersect_range(Range.t(), Range.t()) :: nil | Range.t()
    defp intersect_range(a..b, c..d) when a <= b and c <= d do
      cond do
        b < c or d < a -> nil
        c <= a and b <= d -> a..b
        a < c and b <= d -> c..b
        c <= a and d < b -> a..d
        a < c and d < b -> c..d
      end
    end
  end

  @spec solve!() :: String.t()
  def solve!() do
    read_input!()
    |> Stream.map(&parse_input_line(String.trim(&1)))
    |> Enum.to_list()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 580_012, res_2: 1_334_238_660_555_542} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input! :: File.Stream.t()
  def read_input!() do
    File.stream!(Path.join(:code.priv_dir(:advent_of_code), "input/day_22.txt"))
  end

  @spec parse_input_line(binary) :: {binary, Cuboid.t()}
  def parse_input_line(line) do
    [switch_setting, cuboid] = String.split(line, " ", trim: true)

    [x_dim, y_dim, z_dim] = String.split(cuboid, ",", trim: true) |> Enum.map(&parse_dimension/1)

    {switch_setting, Cuboid.new(x_dim, y_dim, z_dim)}
  end

  @spec parse_dimension(binary) :: Range.t()
  def parse_dimension(cube_dimension) do
    [_, range] = String.split(cube_dimension, "=", trim: true)

    [start, finish] =
      String.split(range, "..", trim: true) |> Enum.map(&String.to_integer/1) |> Enum.sort()

    start..finish
  end

  @cube_100 Cuboid.new(-50..50, -50..50, -50..50)

  @spec solve_1(Enumerable.t()) :: non_neg_integer()
  def solve_1(actions) do
    Stream.map(actions, fn {action, %Cuboid{} = cuboid} ->
      {action, Cuboid.intersect(cuboid, @cube_100)}
    end)
    |> Stream.filter(&(not is_nil(elem(&1, 1))))
    |> count_active_cubes()
  end

  @spec solve_2(Enumerable.t()) :: non_neg_integer()
  def solve_2(actions) do
    count_active_cubes(actions)
  end

  # We could:
  #   1) split the cuboids into sub-cuboids to model removal - but that requires fiddly math
  #   2) maintain a nested list of cuboids & remove the new cuboid from all of them
  #       - if "off" its clear: That area is removed from all cubes & we are done
  #       - if "on" we still ned to remove because of overlap
  #       - We need a nested structure of cuboids to track correct removal. If the "removed" part
  #         has more complex shapes, the procedure is recursively the same: Remove the intersection
  #         from the removed part & ad the entire cuboid as removed without splitting. We thus build
  #         a tree of cuboids that is as deep as region in space with most action overlap.
  @spec count_active_cubes(Enumerable.t()) :: non_neg_integer()
  def count_active_cubes(actions) do
    Enum.reduce(actions, [], fn
      {"on", %Cuboid{} = cuboid}, acc ->
        [cuboid | Enum.map(acc, &Cuboid.subtract(&1, cuboid))]

      {"off", %Cuboid{} = cuboid}, acc ->
        Enum.map(acc, &Cuboid.subtract(&1, cuboid))
    end)
    |> Stream.map(&Cuboid.volume/1)
    |> Enum.sum()
  end
end
