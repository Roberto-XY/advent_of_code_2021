use std::{
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut stack_state = [
        "STHFWR".chars().collect::<Vec<_>>(),
        "SGDQW".chars().collect::<Vec<_>>(),
        "BTW".chars().collect::<Vec<_>>(),
        "DRWTNQZJ".chars().collect::<Vec<_>>(),
        "FBHGLVTZ".chars().collect::<Vec<_>>(),
        "LPTCVBSG".chars().collect::<Vec<_>>(),
        "ZBRTWGP".chars().collect::<Vec<_>>(),
        "NGMTCJR".chars().collect::<Vec<_>>(),
        "LGBW".chars().collect::<Vec<_>>(),
    ];

    let path = env::current_dir()?.join("data/day5.txt");
    let reader = BufReader::new(File::open(path)?);

    for line_or_err in reader
        .lines()
        .skip_while(|line_or_err| line_or_err.as_ref().map_or(true, |line| !line.is_empty()))
        .skip(1)
    {
        let line = line_or_err?;
        let segments = line.split_whitespace().collect::<Vec<_>>();
        let amount = segments.get(1).ok_or("parse error")?.parse::<usize>()?;
        let from_stack = segments.get(3).ok_or("parse error")?.parse::<usize>()? - 1;
        let to_stack = segments.get(5).ok_or("parse error")?.parse::<usize>()? - 1;
        let from_stack = stack_state
            .get_mut(from_stack)
            .ok_or("invalid instruction")?;
        let at = from_stack.len() - amount;
        let mut to_be_moved = from_stack.split_off(at);
        to_be_moved.reverse();
        let to_stack = stack_state.get_mut(to_stack).ok_or("invalid instruction")?;
        to_stack.extend(to_be_moved);
    }

    let res_1 = stack_state
        .iter()
        .flat_map(|vec| vec.last())
        .collect::<String>();
    dbg!(res_1);

    let mut stack_state = [
        "STHFWR".chars().collect::<Vec<_>>(),
        "SGDQW".chars().collect::<Vec<_>>(),
        "BTW".chars().collect::<Vec<_>>(),
        "DRWTNQZJ".chars().collect::<Vec<_>>(),
        "FBHGLVTZ".chars().collect::<Vec<_>>(),
        "LPTCVBSG".chars().collect::<Vec<_>>(),
        "ZBRTWGP".chars().collect::<Vec<_>>(),
        "NGMTCJR".chars().collect::<Vec<_>>(),
        "LGBW".chars().collect::<Vec<_>>(),
    ];

    let path = env::current_dir()?.join("data/day5.txt");
    let reader = BufReader::new(File::open(path)?);

    for line_or_err in reader
        .lines()
        .skip_while(|line_or_err| line_or_err.as_ref().map_or(true, |line| !line.is_empty()))
        .skip(1)
    {
        let line = line_or_err?;
        let segments = line.split_whitespace().collect::<Vec<_>>();
        let amount = segments.get(1).ok_or("parse error")?.parse::<usize>()?;
        let from_stack = segments.get(3).ok_or("parse error")?.parse::<usize>()? - 1;
        let to_stack = segments.get(5).ok_or("parse error")?.parse::<usize>()? - 1;
        let from_stack = stack_state
            .get_mut(from_stack)
            .ok_or("invalid instruction")?;
        let at = from_stack.len() - amount;
        let to_be_moved = from_stack.split_off(at);
        let to_stack = stack_state.get_mut(to_stack).ok_or("invalid instruction")?;
        to_stack.extend(to_be_moved);
    }

    let res_2 = stack_state
        .iter()
        .flat_map(|vec| vec.last())
        .collect::<String>();
    dbg!(res_2);
    // dbg!(res_2);
    Ok(())
}
