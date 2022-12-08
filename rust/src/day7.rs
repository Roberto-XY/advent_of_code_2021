use std::{
    collections::HashMap,
    env,
    error::Error,
    fs::File,
    io::{BufReader, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/day7.txt");
    let mut reader = BufReader::new(File::open(path)?);
    let mut input = String::new();
    reader.read_to_string(&mut input)?;
    let input = input;

    let mut dir_sizes: HashMap<Vec<&str>, u64> = HashMap::new();
    let root = vec!["/"];
    let mut current_dir = root.clone();

    let instructions = input
        .split("$ ")
        .map(|instruction| {
            instruction
                .split('\n')
                .filter(|part| !part.is_empty())
                .collect::<Vec<_>>()
        })
        .filter(|instruction| !instruction.is_empty());

    for instruction in instructions {
        let first = *instruction.first().ok_or("unexpected_input")?;
        if first == "ls" {
            let file_stmts = instruction
                .into_iter()
                .skip(1)
                .filter(|&x| !x.starts_with("dir "));

            for file_stmt in file_stmts {
                let file_stmt = file_stmt.split_whitespace().collect::<Vec<_>>();
                let file_size = file_stmt
                    .first()
                    .ok_or("unexpected_input")?
                    .parse::<u64>()?;
                let current_dir = current_dir.clone();
                for dir_idx in 1..=current_dir.len() {
                    dir_sizes
                        .entry(current_dir[..dir_idx].to_vec())
                        .and_modify(|size| *size += file_size)
                        .or_insert(file_size);
                }
            }
        } else if first == "cd .." {
            current_dir.pop();
        } else if first == "cd /" {
            current_dir.truncate(1);
        } else {
            let cd_instruction = first.split_whitespace().collect::<Vec<_>>();
            let target_dir = *cd_instruction.last().ok_or("unexpected_input")?;
            current_dir.push(target_dir)
        };
    }

    let res_1: u64 = dir_sizes
        .iter()
        .filter_map(|(_key, &dir_size)| {
            if dir_size <= 100000 {
                Some(dir_size)
            } else {
                None
            }
        })
        .sum();
    dbg!(res_1);

    let used_space = dir_sizes.get(&root[..]).ok_or("missing filesystem root")?;
    let unused_space = 70000000 - used_space;
    let space_needed = 30000000 - unused_space;

    let res_2 = dir_sizes
        .iter()
        .filter_map(|(_key, &dir_size)| {
            if dir_size >= space_needed {
                Some(dir_size)
            } else {
                None
            }
        })
        .min();
    dbg!(res_2);
    Ok(())
}
