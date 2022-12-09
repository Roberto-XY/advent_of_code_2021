use std::{
    collections::HashSet,
    env,
    error::Error,
    fs::File,
    io::{BufReader, Read},
};

use itertools::Itertools;

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/day6.txt");
    let mut reader = BufReader::new(File::open(path)?);
    let mut input = String::new();
    reader.read_to_string(&mut input)?;

    let res_1 = input
        .chars()
        .tuple_windows::<(_, _, _, _)>()
        .enumerate()
        .find_map(|indexed_window| match indexed_window {
            (idx, (c_1, c_2, c_3, c_4))
                if c_1 != c_2
                    && c_1 != c_3
                    && c_1 != c_4
                    && c_2 != c_3
                    && c_2 != c_4
                    && c_3 != c_4 =>
            {
                Some(idx + 4)
            }
            _ => None,
        });
    dbg!(res_1);

    let res_2 = input
        .chars()
        .collect::<Vec<_>>()
        .windows(14)
        .enumerate()
        .find_map(|indexed_window| {
            let (idx, window) = indexed_window;
            let set = window.iter().collect::<HashSet<_>>();
            if set.len() == window.len() {
                Some(idx + 14)
            } else {
                None
            }
        });
    dbg!(res_2);

    Ok(())
}
