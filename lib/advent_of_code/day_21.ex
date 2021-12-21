defmodule Day21 do
  def solve!() do
    read_input!()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 739_785, res_2: 15287} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    %{player1_start: 7, player2_start: 1}
  end

  defmodule Player do
    defstruct position: 0, score: 0
  end

  def solve_1(%{player1_start: player1_start, player2_start: player2_start}) do
    %{losing_score: losing_score, roll_count: roll_count} =
      play_game(%Player{position: player1_start}, %Player{position: player2_start})

    losing_score * roll_count
  end

  def solve_2(%{player1_start: player1_start, player2_start: player2_start}) do
    # %{
    #   {%Player{position: ^player1_start}, %Player{position: ^player2_start}} =>
    #     {player1_wins, player2_wins}
    # } =
    {counter, acc} =
      play_dirac_game(
        %Player{position: player1_start},
        %Player{position: player2_start},
        %{}
        # %{{%Player{position: player1_start}, %Player{position: player2_start}} => 1}
      )

    IO.inspect(counter)
  end

  @rolls_per_turn 3
  @cycle_length 10

  def play_game(
        %Player{position: position, score: score} = active_player,
        %Player{} = inactive_player,
        dice_value \\ 0,
        roll_count \\ 0
      ) do
    rolls = [dice_value + 1, dice_value + 2, dice_value + 3]
    new_position = looping_add(position + Enum.sum(rolls), @cycle_length)
    new_score = score + new_position
    new_roll_count = roll_count + @rolls_per_turn

    if new_score > 999 do
      %{winning_score: new_score, losing_score: inactive_player.score, roll_count: new_roll_count}
    else
      play_game(
        inactive_player,
        %{active_player | position: new_position, score: new_score},
        rem(dice_value + 3, 100),
        new_roll_count
      )
    end
  end

  @roll_count (for first_roll <- 1..3,
                   second_roll <- 1..3,
                   third_roll <- 1..3 do
                 Enum.sum([first_roll, second_roll, third_roll])
               end)
              |> Enum.frequencies()

  def play_dirac_game(
        active_player,
        active_player,
        dp_acc
      )

  def play_dirac_game(%Player{score: score} = active_player, %Player{} = inactive_player, _)
      when score > 20 do
    {{1, 0}, %{{active_player, inactive_player} => {1, 0}}}
  end

  def play_dirac_game(%Player{} = active_player, %Player{score: score} = inactive_player, _)
      when score > 20 do
    {{0, 1}, %{{active_player, inactive_player} => {0, 1}}}
  end

  def play_dirac_game(
        %Player{position: position, score: score} = active_player,
        %Player{} = inactive_player,
        dp_acc
      ) do
    key = {active_player, inactive_player}

    case Map.get(dp_acc, key) do
      nil ->
        {counter, new_dp_acc} =
          Enum.map(@roll_count, fn {roll_sum, frequency} ->
            new_position = looping_add(position + roll_sum, @cycle_length)
            new_score = score + new_position
            new_active_player = %{active_player | position: new_position, score: new_score}

            {{count2, count1}, acc} = play_dirac_game(inactive_player, new_active_player, dp_acc)

            acc =
              acc
              |> Enum.map(fn {key, {count2, count1}} ->
                {key, {count1 * frequency, count2 * frequency}}
              end)
              |> Enum.into(%{})

            {{count1 * frequency, count2 * frequency}, acc}
          end)
          |> Enum.reduce(fn {{v11, v12}, acc1}, {{v21, v22}, acc2} ->
            {{v11 + v21, v12 + v22},
             Map.merge(acc1, acc2, fn _, {v11, v12}, {v21, v22} -> {v11 + v21, v12 + v22} end)}
          end)

        {counter,
         Map.merge(dp_acc, new_dp_acc, fn _, {v11, v12}, {v21, v22} -> {v11 + v21, v12 + v22} end)}

      val ->
        val
    end
  end

  def looping_add(i, div) do
    rem = rem(i, div)

    if rem == 0 do
      rem + div
    else
      rem
    end
  end
end
