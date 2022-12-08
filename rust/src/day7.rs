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

    let mut file_sizes: HashMap<Vec<String>, u64> = HashMap::new();

    let root = vec!["/".to_owned()];
    let mut current_dir = root.clone();

    input
        .split("$ ")
        .map(|instruction| {
            instruction
                .split('\n')
                .filter(|part| !part.is_empty())
                .collect::<Vec<_>>()
        })
        .filter(|instruction| !instruction.is_empty())
        .for_each(|instruction| {
            let first = instruction.first().unwrap();
            if *first == "ls" {
                let (dir_stmts, file_stmts): (Vec<_>, Vec<_>) = instruction
                    .into_iter()
                    .skip(1)
                    .partition(|&x| x.starts_with("dir "));
                let _children = dir_stmts.into_iter().for_each(|dir_stmt| {
                    let dir_stmt = dir_stmt.split_whitespace().collect::<Vec<_>>();
                    let _dir_name = dir_stmt.last().unwrap();
                });

                file_stmts.into_iter().for_each(|file_stmt| {
                    let file_stmt = file_stmt.split_whitespace().collect::<Vec<_>>();
                    let _file_name = *file_stmt.last().unwrap();
                    let file_size = file_stmt.first().unwrap().parse::<u64>().unwrap();
                    let file_key = current_dir.clone();
                    // file_key.push(file_name.to_owned());

                    let mut current_key = vec![];
                    for key_segment in file_key.into_iter() {
                        current_key.push(key_segment);
                        file_sizes
                            .entry(current_key.clone())
                            .and_modify(|size| *size += file_size)
                            .or_insert(file_size);
                    }
                });
            } else if *first == "cd .." {
                current_dir.pop();
            } else if *first == "cd /" {
                current_dir.truncate(1);
            } else {
                let cd_instruction = first.split_whitespace().collect::<Vec<_>>();
                let target_dir = *cd_instruction.last().unwrap();
                current_dir.push(target_dir.to_owned())
            };
        });

    let res_1: u64 = file_sizes
        .iter()
        .filter_map(|(_key, dir_size)| {
            if *dir_size <= 100000 {
                Some(dir_size)
            } else {
                None
            }
        })
        .sum();
    dbg!(res_1);

    let used_space = file_sizes.get(&root).unwrap();
    let unused_space = 70000000 - used_space;
    let space_needed = 30000000 - unused_space;

    let res_2 = file_sizes
        .iter()
        .filter_map(|(_key, dir_size)| {
            if *dir_size >= space_needed {
                Some(dir_size)
            } else {
                None
            }
        })
        .min();
    dbg!(res_2);
    Ok(())
}
