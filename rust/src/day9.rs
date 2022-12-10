use std::{
    collections::{HashMap, HashSet},
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

    let mut rope = [(0, 0); 10];
    let mut pos_visited_by_knots: HashMap<usize, HashSet<(i32, i32)>> = HashMap::new();

    for line_or_err in reader.lines() {
        let line = line_or_err?;
        let mut instruction_segments = line.split_whitespace();
        let direction: Direction = instruction_segments
            .next()
            .ok_or("parsing error")?
            .try_into()?;
        let repetition = instruction_segments
            .next()
            .ok_or("parsing error")?
            .parse::<usize>()?;

        for direction in iter::repeat(&direction).take(repetition) {
            match direction {
                Direction::Up => {
                    rope[0].1 += 1;
                }
                Direction::Down => {
                    rope[0].1 -= 1;
                }
                Direction::Right => {
                    rope[0].0 += 1;
                }
                Direction::Left => {
                    rope[0].0 -= 1;
                }
            };

            for idx in 1..rope.len() {
                let head_pos = rope[idx - 1];
                let next_tail_pos = rope.get_mut(idx).ok_or("idx out of bounds")?;

                // top-left corner
                if (next_tail_pos.0 - 1, next_tail_pos.1 + 2) == head_pos
                    || (next_tail_pos.0 - 2, next_tail_pos.1 + 1) == head_pos
                    || (next_tail_pos.0 - 2, next_tail_pos.1 + 2) == head_pos
                {
                    next_tail_pos.0 = next_tail_pos.0 - 1;
                    next_tail_pos.1 = next_tail_pos.1 + 1;
                }
                // left lane
                else if (next_tail_pos.0 - 2, next_tail_pos.1) == head_pos {
                    next_tail_pos.0 = next_tail_pos.0 - 1;
                }
                // bottom-left corner
                else if (next_tail_pos.0 - 2, next_tail_pos.1 - 1) == head_pos
                    || (next_tail_pos.0 - 1, next_tail_pos.1 - 2) == head_pos
                    || (next_tail_pos.0 - 2, next_tail_pos.1 - 2) == head_pos
                {
                    next_tail_pos.0 = next_tail_pos.0 - 1;
                    next_tail_pos.1 = next_tail_pos.1 - 1;
                }
                // bottom lane
                else if (next_tail_pos.0, next_tail_pos.1 - 2) == head_pos {
                    next_tail_pos.1 = next_tail_pos.1 - 1;
                }
                // bottom-right corner
                else if (next_tail_pos.0 + 1, next_tail_pos.1 - 2) == head_pos
                    || (next_tail_pos.0 + 2, next_tail_pos.1 - 1) == head_pos
                    || (next_tail_pos.0 + 2, next_tail_pos.1 - 2) == head_pos
                {
                    next_tail_pos.0 = next_tail_pos.0 + 1;
                    next_tail_pos.1 = next_tail_pos.1 - 1;
                }
                // right lane
                else if (next_tail_pos.0 + 2, next_tail_pos.1) == head_pos {
                    next_tail_pos.0 = next_tail_pos.0 + 1;
                }
                // top-right corner
                else if (next_tail_pos.0 + 2, next_tail_pos.1 + 1) == head_pos
                    || (next_tail_pos.0 + 1, next_tail_pos.1 + 2) == head_pos
                    || (next_tail_pos.0 + 2, next_tail_pos.1 + 2) == head_pos
                {
                    next_tail_pos.0 = next_tail_pos.0 + 1;
                    next_tail_pos.1 = next_tail_pos.1 + 1;
                }
                // top lane
                else if (next_tail_pos.0, next_tail_pos.1 + 2) == head_pos {
                    next_tail_pos.1 = next_tail_pos.1 + 1;
                }

                pos_visited_by_knots
                    .entry(idx)
                    .and_modify(|set| {
                        set.insert(*next_tail_pos);
                    })
                    .or_insert_with(|| {
                        let mut set = HashSet::new();
                        set.insert((0, 0));
                        set
                    });
            }
        }
    }

    let res_1 = pos_visited_by_knots.get(&1).map(|set| set.len());
    let res_2 = pos_visited_by_knots.get(&9).map(|set| set.len());

    dbg!(res_1);
    dbg!(res_2);

    Ok(())
}
