use std::{
    collections::VecDeque,
    env::{self},
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
};

enum Instruction {
    Noop,
    Add(i64),
}

impl Instruction {
    fn parse(str: &str) -> Result<Self, Box<dyn Error>> {
        if str == "noop" {
            Ok(Instruction::Noop)
        } else {
            let mut segment_iter = str.split_whitespace();
            let _ = segment_iter.next().ok_or("parse err")?;
            let value = segment_iter.next().ok_or("parse err")?.parse::<i64>()?;
            Ok(Instruction::Add(value))
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/day10.txt");
    let reader = BufReader::new(File::open(path.clone())?);

    let mut relevant_cycles = VecDeque::from([20usize, 60, 100, 140, 180, 220]);
    let screen_length = 40usize;

    let mut screen: Vec<char> = vec![];
    let mut current_cycle = 0usize;
    let mut res_1 = 0i64;
    let mut register_x = 1i64;

    for line_or_err in reader.lines() {
        let line = line_or_err?;
        let instruction = Instruction::parse(&line)?;
        check_cycle_of_interest(&mut res_1, &mut relevant_cycles, current_cycle, register_x);
        match instruction {
            Instruction::Noop => {
                draw_pixel(&mut screen, screen_length, current_cycle, register_x);
                current_cycle += 1
            }
            Instruction::Add(value) => {
                for _ in 0..2 {
                    draw_pixel(&mut screen, screen_length, current_cycle, register_x);
                    current_cycle += 1;
                    check_cycle_of_interest(
                        &mut res_1,
                        &mut relevant_cycles,
                        current_cycle,
                        register_x,
                    );
                }
                register_x += value;
            }
        };
    }

    dbg!(&res_1);
    screen
        .chunks(40)
        .map(|screen_line| screen_line.into_iter().collect::<String>())
        .for_each(|str| println!("{}", str));
    Ok(())
}

fn check_cycle_of_interest(
    res: &mut i64,
    relevant_cycles: &mut VecDeque<usize>,
    current_cycle: usize,
    register_x: i64,
) -> () {
    if let Some(cycle_of_interest) = relevant_cycles.front() {
        if *cycle_of_interest == current_cycle {
            *res += register_x * current_cycle as i64;
            relevant_cycles.pop_front();
        }
    }
}

fn draw_pixel(
    screen: &mut Vec<char>,
    screen_length: usize,
    current_cycle: usize,
    register_x: i64,
) -> () {
    let screen_line_pos = (current_cycle % screen_length) as i64;
    let sprite_range = (register_x - 1)..=(register_x + 1);
    if sprite_range.contains(&screen_line_pos) {
        screen.push('#')
    } else {
        screen.push('.')
    }
}
