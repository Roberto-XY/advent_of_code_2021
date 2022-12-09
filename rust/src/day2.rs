use std::{
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
};

enum Action {
    Rock,
    Paper,
    Scissors,
}

impl Action {
    fn score(&self) -> u64 {
        match self {
            Action::Rock => 1,
            Action::Paper => 2,
            Action::Scissors => 3,
        }
    }
}

enum RoundResult {
    Loss,
    Draw,
    Win,
}

impl RoundResult {
    fn score(&self) -> u64 {
        match self {
            RoundResult::Loss => 0,
            RoundResult::Draw => 3,
            RoundResult::Win => 6,
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/day2.txt");

    let reader = BufReader::new(File::open(path.clone())?);
    let mut total_score_1 = 0u64;
    for round_str in reader.lines() {
        let round_str = round_str?;
        let mut round_iter = round_str
            .split_whitespace()
            .map(|action_str| match action_str {
                "A" | "X" => Action::Rock,
                "B" | "Y" => Action::Paper,
                "C" | "Z" => Action::Scissors,
                _ => unimplemented!("Unsupported action"),
            });
        let opponent_action = round_iter.next().ok_or("No opponent action found")?;
        let player_action = round_iter.next().ok_or("No player action found")?;
        let round_res = eval_round(&player_action, &opponent_action);
        let round_score = player_action.score() + round_res.score();
        total_score_1 += round_score;
    }
    dbg!(&total_score_1);

    let reader = BufReader::new(File::open(path)?);
    let mut total_score_2 = 0u64;
    for round_str in reader.lines() {
        let round_str = round_str?;
        let mut round_iter = round_str.split_whitespace();
        let opponent_action = round_iter.next().ok_or("No opponent action found")?;
        let opponent_action = match opponent_action {
            "A" => Action::Rock,
            "B" => Action::Paper,
            "C" => Action::Scissors,
            _ => unimplemented!("Unsupported action"),
        };
        let desired_outcome = round_iter.next().ok_or("No desired outcome found")?;
        let desired_outcome = match desired_outcome {
            "X" => RoundResult::Loss,
            "Y" => RoundResult::Draw,
            "Z" => RoundResult::Win,
            _ => unimplemented!("Unsupported round result"),
        };
        let inferred_player_action = infer_player_action(&opponent_action, &desired_outcome);
        let round_score = inferred_player_action.score() + desired_outcome.score();
        total_score_2 += round_score;
    }
    dbg!(&total_score_2);

    Ok(())
}

fn eval_round(player_action: &Action, opponent_action: &Action) -> RoundResult {
    match (player_action, opponent_action) {
        (Action::Rock, Action::Rock) => RoundResult::Draw,
        (Action::Rock, Action::Paper) => RoundResult::Loss,
        (Action::Rock, Action::Scissors) => RoundResult::Win,
        (Action::Paper, Action::Rock) => RoundResult::Win,
        (Action::Paper, Action::Paper) => RoundResult::Draw,
        (Action::Paper, Action::Scissors) => RoundResult::Loss,
        (Action::Scissors, Action::Rock) => RoundResult::Loss,
        (Action::Scissors, Action::Paper) => RoundResult::Win,
        (Action::Scissors, Action::Scissors) => RoundResult::Draw,
    }
}

fn infer_player_action(opponent_action: &Action, desired_outcome: &RoundResult) -> Action {
    match (&opponent_action, desired_outcome) {
        (Action::Rock, RoundResult::Loss) => Action::Scissors,
        (Action::Rock, RoundResult::Draw) => Action::Rock,
        (Action::Rock, RoundResult::Win) => Action::Paper,
        (Action::Paper, RoundResult::Loss) => Action::Rock,
        (Action::Paper, RoundResult::Draw) => Action::Paper,
        (Action::Paper, RoundResult::Win) => Action::Scissors,
        (Action::Scissors, RoundResult::Loss) => Action::Paper,
        (Action::Scissors, RoundResult::Draw) => Action::Scissors,
        (Action::Scissors, RoundResult::Win) => Action::Rock,
    }
}
