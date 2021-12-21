defmodule Day21 do
  def solve!() do
    read_input!()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 739_785, res_2: 15287} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  def read_input!() do
    %{player1_start: 4, player2_start: 8}
  end

  defmodule Player do
    defstruct id: nil, position: 0, score: 0
  end

  def solve_1(%{player1_start: player1_start, player2_start: player2_start}) do
    %{losing_score: losing_score, roll_count: roll_count} =
      play_game(%Player{id: 1, position: player1_start}, %Player{id: 2, position: player2_start})

    losing_score * roll_count
  end

  def solve_2(%{player1_start: player1_start, player2_start: player2_start}) do
    %{1 => player1_wins, 2 => player2_wins} =
      play_dirac_game(
        %Player{id: 1, position: player1_start},
        %Player{id: 2, position: player2_start}
      )
      |> IO.inspect()
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

  def play_dirac_game(
        active_player,
        active_player,
        rolls_this_turn \\ [],
        roll \\ nil,
        dp_acc \\ %{}
      )

  def play_dirac_game(
        %Player{} = active_player,
        %Player{} = inactive_player,
        rolls_this_turn,
        roll,
        dp_acc
      )
      when is_integer(roll) and length(rolls_this_turn) < 3 do
    play_dirac_game(
      active_player,
      inactive_player,
      rolls_this_turn ++ [roll],
      nil,
      dp_acc
    )
  end

  def play_dirac_game(
        %Player{} = active_player,
        %Player{} = inactive_player,
        rolls_this_turn,
        nil,
        dp_acc
      ) do
    Map.get_lazy(dp_acc, {%{active_player | id: nil}, %{inactive_player | id: nil}}, fn ->
      [
        play_dirac_game(inactive_player, active_player, rolls_this_turn, 1, dp_acc),
        play_dirac_game(inactive_player, active_player, rolls_this_turn, 2, dp_acc),
        play_dirac_game(inactive_player, active_player, rolls_this_turn, 3, dp_acc)
      ]
      |> Enum.reduce(&Map.merge(&2, &1, fn _, v1, v2 -> v1 + v2 end))
    end)
  end

  def play_dirac_game(
        %Player{position: position, score: score} = active_player,
        %Player{} = inactive_player,
        rolls_this_turn,
        _,
        dp_acc
      )
      when length(rolls_this_turn) == 3 do
    roll_sum = Enum.sum(rolls_this_turn)
    new_position = looping_add(position + roll_sum, @cycle_length)
    new_score = score + new_position

    if new_score > 3 do
      Map.update(
        dp_acc,
        {%{active_player | id: nil}, %{inactive_player | id: nil}},
        1,
        fn win_counter -> Map.update(win_counter, active_player.id, 1, &(&1 + 1)) end
      )
    else
      new_active_player = %{active_player | position: new_position, score: new_score}

      play_dirac_game(inactive_player, new_active_player, [], nil, dp_acc)
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
