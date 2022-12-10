use std::{
    collections::HashSet,
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
    iter,
};

#[derive(Debug)]
enum Direction {
    Up,
    Down,
    Right,
    Left,
}

impl<'a> TryFrom<&'a str> for Direction {
    type Error = &'static str;

    fn try_from(value: &'a str) -> Result<Self, Self::Error> {
        match value {
            "U" => Ok(Direction::Up),
            "D" => Ok(Direction::Down),
            "R" => Ok(Direction::Right),
            "L" => Ok(Direction::Left),
            _ => Err("Invalid direction"),
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/day9.txt");
    let reader = BufReader::new(File::open(path.clone())?);

    let mut head_pos = (0, 0);
    let mut tail_pos = (0, 0);
    let mut pos_visited_by_tail: HashSet<(i32, i32)> = HashSet::new();
    pos_visited_by_tail.insert(tail_pos);

    for line_or_err in reader.lines() {
        let line = line_or_err?;

        let mut instruction_segments = line.split_whitespace();
        let direction: Direction = instruction_segments.next().ok_or("err")?.try_into()?;
        let repetition = instruction_segments.next().ok_or("err")?.parse::<usize>()?;
        iter::repeat(&direction)
            .take(repetition)
            .for_each(|direction| match direction {
                Direction::Up => {
                    head_pos.1 += 1;
                    if must_tail_move(head_pos, tail_pos) {
                        tail_pos.0 = head_pos.0;
                        tail_pos.1 = head_pos.1 - 1;
                        pos_visited_by_tail.insert(tail_pos);
                    }
                }
                Direction::Down => {
                    head_pos.1 -= 1;
                    if must_tail_move(head_pos, tail_pos) {
                        tail_pos.0 = head_pos.0;
                        tail_pos.1 = head_pos.1 + 1;
                        pos_visited_by_tail.insert(tail_pos);
                    }
                }
                Direction::Right => {
                    head_pos.0 += 1;
                    if must_tail_move(head_pos, tail_pos) {
                        tail_pos.0 = head_pos.0 - 1;
                        tail_pos.1 = head_pos.1;
                        pos_visited_by_tail.insert(tail_pos);
                    }
                }
                Direction::Left => {
                    head_pos.0 -= 1;
                    if must_tail_move(head_pos, tail_pos) {
                        tail_pos.0 = head_pos.0 + 1;
                        tail_pos.1 = head_pos.1;
                        pos_visited_by_tail.insert(tail_pos);
                    }
                }
            });
    }

    dbg!(pos_visited_by_tail.len());
    Ok(())
}

fn must_tail_move(head_pos: (i32, i32), tail_pos: (i32, i32)) -> bool {
    head_pos.0.abs_diff(tail_pos.0) > 1 || head_pos.1.abs_diff(tail_pos.1) > 1
}
