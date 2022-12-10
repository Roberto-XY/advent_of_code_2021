use std::{
    collections::{HashMap, HashSet},
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
    iter,
};

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
    let mut visited_by_knots: HashMap<usize, HashSet<(i32, i32)>> =
        HashMap::from_iter((1..10).map(|idx| (idx, HashSet::from([(0, 0)]))));

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
            // move head
            let (head_x, head_y) = rope[0];
            let new_head = match direction {
                Direction::Up => (head_x, head_y + 1),
                Direction::Down => (head_x, head_y - 1),
                Direction::Right => (head_x + 1, head_y),
                Direction::Left => (head_x - 1, head_y),
            };
            rope[0] = new_head;

            // let all knots follow
            for idx in 1..rope.len() {
                let current_pos = rope[idx];
                let previous_pos = rope[idx - 1];
                if let Some(new_pos) = follow(current_pos, previous_pos) {
                    rope[idx] = new_pos;

                    visited_by_knots.entry(idx).and_modify(|set| {
                        set.insert(new_pos);
                    });
                }
            }
        }
    }

    let res_1 = visited_by_knots.get(&1).map(|set| set.len());
    let res_2 = visited_by_knots.get(&9).map(|set| set.len());

    dbg!(res_1);
    dbg!(res_2);

    Ok(())
}

fn follow(current_pos: (i32, i32), previous_pos: (i32, i32)) -> Option<(i32, i32)> {
    let (x, y) = current_pos;

    // top-left corner
    if (x - 1, y + 2) == previous_pos
        || (x - 2, y + 1) == previous_pos
        || (x - 2, y + 2) == previous_pos
    {
        Some((x - 1, y + 1))
    }
    // left lane
    else if (x - 2, y) == previous_pos {
        Some((x - 1, y))
    }
    // bottom-left corner
    else if (x - 2, y - 1) == previous_pos
        || (x - 1, y - 2) == previous_pos
        || (x - 2, y - 2) == previous_pos
    {
        Some((x - 1, y - 1))
    }
    // bottom lane
    else if (x, y - 2) == previous_pos {
        Some((x, y - 1))
    }
    // bottom-right corner
    else if (x + 1, y - 2) == previous_pos
        || (x + 2, y - 1) == previous_pos
        || (x + 2, y - 2) == previous_pos
    {
        Some((x + 1, y - 1))
    }
    // right lane
    else if (x + 2, y) == previous_pos {
        Some((x + 1, y))
    }
    // top-right corner
    else if (x + 2, y + 1) == previous_pos
        || (x + 1, y + 2) == previous_pos
        || (x + 2, y + 2) == previous_pos
    {
        Some((x + 1, y + 1))
    }
    // top lane
    else if (x, y + 2) == previous_pos {
        Some((x, y + 1))
    } else {
        None
    }
}
