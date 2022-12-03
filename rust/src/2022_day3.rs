use std::{
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
};

use itertools::Itertools;

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/2022_day3.txt");

    let reader = BufReader::new(File::open(path.clone())?);
    let res_1 = reader
        .lines()
        .map(|line_or_err| {
            line_or_err
                .map_err(|err| Box::new(err) as Box<dyn Error>)
                .and_then(|rucksack| {
                    let len = rucksack.len();
                    let (compartment_1, compartment_2) = rucksack.split_at(len / 2);
                    let common_item_priority = compartment_1
                        .chars()
                        .map(|item| compartment_2.find(item).map(|_| item))
                        .find(|common_item| common_item.is_some())
                        .flatten()
                        .ok_or("no common item found".into())
                        .map(|common_item| item_to_priority(&common_item));
                    common_item_priority
                })
        })
        .sum::<Result<u64, _>>()?;

    let reader = BufReader::new(File::open(path.clone())?);
    let res_2 = reader
        .lines()
        .tuples::<(_, _, _)>()
        .map(|(a, b, c)| a.and_then(|a| b.and_then(|b| c.map(|c| (a, b, c)))))
        .map(|lines_or_err| {
            lines_or_err
                .map_err(|err| Box::new(err) as Box<dyn Error>)
                .and_then(|(rucksack_a, rucksack_b, rucksack_c)| {
                    let common_item_priority = rucksack_a
                        .chars()
                        .flat_map(|item| rucksack_b.find(item).map(|_| item))
                        .map(|item| rucksack_c.find(item).map(|_| item))
                        .find(|common_item| common_item.is_some())
                        .flatten()
                        .ok_or("no common item found".into())
                        .map(|common_item| item_to_priority(&common_item));
                    common_item_priority
                })
        })
        .sum::<Result<u64, _>>()?;

    dbg!(res_1);
    dbg!(res_2);
    Ok(())
}

fn item_to_priority(item: &char) -> u64 {
    // assumption: only simple alphabet
    // A = 65
    // a = 97
    let utf_8_idx = *item as u64;
    if item.is_uppercase() {
        utf_8_idx - 38
    } else {
        utf_8_idx - 96
    }
}
