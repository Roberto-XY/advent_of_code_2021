defmodule Day17 do
  @spec solve!() :: String.t()
  def solve!() do
    read_input!()
    |> parse_input()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 10878, res_2: 4716} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input!() :: binary
  def read_input!() do
    File.read!(Path.join(:code.priv_dir(:advent_of_code), "input/day_17.txt"))
  end

  @type target_area :: %{x_min: integer(), x_max: integer(), y_min: integer(), y_max: integer()}
  @type velocity :: %{x_velocity: integer(), y_velocity: integer()}

  @spec parse_input(<<_::64, _::_*8>>) :: target_area
  def parse_input(<<"target area:", range::binary>>) do
    [<<"x=", x_range::binary>>, <<"y=", y_range::binary>>] =
      String.trim(range)
      |> String.split(", ", trim: true)

    [x_min, x_max] = String.split(x_range, "..", trim: true) |> Enum.map(&String.to_integer/1)
    [y_min, y_max] = String.split(y_range, "..", trim: true) |> Enum.map(&String.to_integer/1)

    %{x_min: x_min, x_max: x_max, y_min: y_min, y_max: y_max}
  end

  @spec solve_1(target_area) :: integer()
  def solve_1(%{x_max: x_max, y_min: y_min} = target_area) do
    # greater would be a guaranteed miss, we need a x_velocity of
    # x_min_target <= (n^2 + n) / 2 <= x_max_target.
    # If we assume the least fortunate last step we need a y_velocity > 2 * y_min to skip
    # the target area completely in the next step.
    for x_velocity <- 0..(x_max + 1),
        y_velocity <- 0..(abs(y_min) * 2) do
      targeted_shot_trajectory(%{x_velocity: x_velocity, y_velocity: y_velocity}, target_area)
      |> Enum.reduce_while(-1, fn
        :missed_or_passed, _ -> {:halt, -1}
        {:hit, {_, y}}, max_y_reached -> {:halt, max(y, max_y_reached)}
        {_, y}, max_y_reached -> {:cont, max(y, max_y_reached)}
      end)
    end
    |> Stream.reject(&(&1 == -1))
    |> Enum.max()
  end

  @spec solve_2(target_area) :: non_neg_integer()
  def solve_2(%{x_max: x_max, y_min: y_min} = target_area) do
    for x_velocity <- 0..(x_max + 1),
        y_velocity <- (y_min - 1)..(abs(y_min) * 2) do
      velocity = %{x_velocity: x_velocity, y_velocity: y_velocity}

      targeted_shot_trajectory(velocity, target_area)
      |> Enum.reduce_while(:unknown_if_hit, fn
        :missed_or_passed, _ -> {:halt, {:missed_or_passed, velocity}}
        {:hit, _}, _ -> {:halt, {:hit, velocity}}
        _, acc -> {:cont, acc}
      end)
    end
    |> Stream.reject(&match?({:missed_or_passed, _}, &1))
    |> Enum.into(MapSet.new())
    |> Enum.count()
  end

  @spec shot_trajectory(velocity) :: Enumerable.t()
  def shot_trajectory(%{x_velocity: x_velocity, y_velocity: y_velocity})
      when is_integer(x_velocity) and is_integer(y_velocity) do
    Stream.unfold({{0, 0}, {x_velocity, y_velocity}}, fn {{x, y}, {x_velocity, y_velocity}} ->
      x = x + x_velocity
      y = y + y_velocity

      x_velocity =
        cond do
          x_velocity < 0 -> x_velocity + 1
          x_velocity > 0 -> x_velocity - 1
          x_velocity == 0 -> x_velocity
        end

      y_velocity = y_velocity - 1

      {{x, y}, {{x, y}, {x_velocity, y_velocity}}}
    end)
  end

  @spec targeted_shot_trajectory(velocity, target_area()) :: Enumerable.t()
  def targeted_shot_trajectory(velocity, %{
        x_min: x_min,
        x_max: x_max,
        y_min: y_min,
        y_max: y_max
      }) do
    Stream.map(
      shot_trajectory(velocity),
      fn
        {x, y} when x > x_max or y < y_min -> :missed_or_passed
        {x, y} when x >= x_min and x <= x_max and y >= y_min and y <= y_max -> {:hit, {x, y}}
        {x, y} -> {x, y}
      end
    )
  end
end
