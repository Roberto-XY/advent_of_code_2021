use std::{
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
};

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/day4.txt");

    let reader = BufReader::new(File::open(path)?);

    let mut res_1 = 0u64;
    let mut res_2 = 0u64;

    for line_or_err in reader.lines() {
        let line = line_or_err?;
        let mut pairs = line.splitn(2, ',');
        let range_1 = parse_range(pairs.next().ok_or("unexpected input")?)?;
        let range_2 = parse_range(pairs.next().ok_or("unexpected input")?)?;
        if is_sub_range(&range_1, &range_2) {
            res_1 += 1;
        }
        if is_overlapping(&range_1, &range_2) {
            res_2 += 1;
        }
    }

    dbg!(res_1);
    dbg!(res_2);
    Ok(())
}

fn parse_range(range_str: &str) -> Result<(u64, u64), Box<dyn Error>> {
    let mut range_splitter = range_str.splitn(2, '-');
    let start = range_splitter.next().ok_or("unexpected input")?;
    let end = range_splitter.next().ok_or("unexpected input")?;
    let start = start.parse::<u64>()?;
    let end = end.parse::<u64>()?;
    Ok((start, end))
}

fn is_sub_range(range_1: &(u64, u64), range_2: &(u64, u64)) -> bool {
    range_1.0 <= range_2.0 && range_2.1 <= range_1.1
        || (range_2.0 <= range_1.0 && range_1.1 <= range_2.1)
}

fn is_overlapping(range_1: &(u64, u64), range_2: &(u64, u64)) -> bool {
    range_1.0 <= range_2.1 && range_2.0 <= range_1.1
}
