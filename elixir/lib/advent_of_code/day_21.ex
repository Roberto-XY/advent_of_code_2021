defmodule Day21 do
  @spec solve!() :: String.t()
  def solve!() do
    read_input!()
    |> then(&%{res_1: solve_1(&1), res_2: solve_2(&1)})
    |> then(fn
      %{res_1: 684_495, res_2: 152_587_196_649_184} -> IO.inspect("Success on #{__MODULE__}")
    end)
  end

  @spec read_input! :: %{player1_start: 7, player2_start: 1}
  def read_input!() do
    %{player1_start: 7, player2_start: 1}
  end

  defmodule Player do
    @type t :: %__MODULE__{position: non_neg_integer(), score: non_neg_integer()}

    defstruct position: 0, score: 0
  end

  def solve_1(%{player1_start: player1_start, player2_start: player2_start}) do
    %{losing_score: losing_score, roll_sums: roll_sums} =
      play_game(%Player{position: player1_start}, %Player{position: player2_start})

    losing_score * roll_sums
  end

  def solve_2(%{player1_start: player1_start, player2_start: player2_start}) do
    # {{wins_player1, wins_player2}, _} =
    #   play_dirac_game(%Player{position: player1_start}, %Player{position: player2_start}, %{})

    # slow_res = max(wins_player1, wins_player2)

    fast_res =
      play_fast_dirac_game(
        {%{{%Player{position: player1_start}, %Player{position: player2_start}} => 1}, 0, 0}
      )

    # ^fast_res = slow_res
    fast_res
  end

  @rolls_per_turn 3
  @cycle_length 10

  def play_game(
        %Player{position: position, score: score} = active_player,
        %Player{} = inactive_player,
        dice_value \\ 0,
        roll_sums \\ 0
      ) do
    rolls = [dice_value + 1, dice_value + 2, dice_value + 3]
    new_position = looping_add(position + Enum.sum(rolls), @cycle_length)
    new_score = score + new_position
    new_roll_count = roll_sums + @rolls_per_turn

    if new_score > 999 do
      %{winning_score: new_score, losing_score: inactive_player.score, roll_sums: new_roll_count}
    else
      play_game(
        inactive_player,
        %{active_player | position: new_position, score: new_score},
        rem(dice_value + 3, 100),
        new_roll_count
      )
    end
  end

  @roll_sums (for first_roll <- 1..3,
                  second_roll <- 1..3,
                  third_roll <- 1..3 do
                Enum.sum([first_roll, second_roll, third_roll])
              end)
             |> Enum.frequencies()

  @winning_score 21

  @type game_state :: {{Player.t(), Player.t()}, non_neg_integer()}
  @type dp_state ::
          {%{optional(game_state) => non_neg_integer()}, non_neg_integer(), non_neg_integer()}

  # empty dp_state means that there are no tree leafs left that did not result in a win for either
  # player 1 or 2
  @spec play_fast_dirac_game(dp_state) :: non_neg_integer()
  def play_fast_dirac_game({dp_state, wins_player1, wins_player2}) when map_size(dp_state) == 0 do
    max(wins_player1, wins_player2)
  end

  def play_fast_dirac_game({dp_state, wins_player1, wins_player2}) do
    # swap player counts on each turn!
    # Expand the subtree for each dp_state entry that did not result in a game win
    Enum.reduce(dp_state, {%{}, wins_player2, wins_player1}, &simulate_game_turn/2)
    |> play_fast_dirac_game()
  end

  @spec simulate_game_turn(game_state, dp_state) :: dp_state
  def simulate_game_turn(
        {{%Player{position: position, score: score} = active_player, %Player{} = inactive_player},
         state_count},
        {dp_state, wins_player1, wins_player2}
      ) do
    # Generate all new player states & their frequency ...
    for {roll_sum, frequency} <- @roll_sums do
      new_position = looping_add(position + roll_sum, @cycle_length)
      new_score = score + new_position
      new_active_player = %{active_player | position: new_position, score: new_score}

      {{new_active_player, inactive_player}, state_count * frequency}
    end
    |> Enum.reduce({dp_state, wins_player1, wins_player2}, fn
      # ... if win: Add all equal states to the win count ...
      {{%Player{score: score}, _}, state_count}, {dp_state, wins_player1, wins_player2}
      when score >= @winning_score ->
        {dp_state, wins_player1 + state_count, wins_player2}

      # .. else just merge.
      {{active_player, inactive_player}, state_count}, {dp_state, wins_player1, wins_player2} ->
        new_dp_state =
          Map.update(
            dp_state,
            # swap player on each turn! -> this swap already initializes the next turn
            {inactive_player, active_player},
            state_count,
            &(&1 + state_count)
          )

        {new_dp_state, wins_player1, wins_player2}
    end)
  end

  # This solved me the day but takes a while to run, but checking some other solutions you can do
  # way better
  @spec play_dirac_game(Day21.Player.t(), Day21.Player.t(), map) ::
          {{non_neg_integer(), non_neg_integer()}, map}
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
          Enum.map(@roll_sums, fn {roll_sum, frequency} ->
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

  @spec looping_add(integer, integer) :: integer
  def looping_add(i, div) do
    rem = rem(i, div)

    if rem == 0 do
      rem + div
    else
      rem
    end
  end
end
