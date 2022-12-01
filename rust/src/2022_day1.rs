use std::{
    cmp::max,
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
};

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/2022_day1.txt");
    let acc = with_loop(BufReader::new(File::open(&path)?))?;
    let max_sum = with_closure(BufReader::new(File::open(&path)?))?;

    dbg!(max_sum);
    dbg!(&acc.first());
    dbg!(&acc.iter().take(3).sum::<i64>());
    Ok(())
}

fn with_loop(reader: BufReader<File>) -> Result<Vec<i64>, Box<dyn Error>> {
    let mut current_sum = 0i64;
    let mut acc: Vec<i64> = vec![];

    for next_line in reader.lines() {
        let next_line = next_line?;
        if next_line.eq("") {
            acc.push(current_sum);
            current_sum = 0i64;
        } else {
            let next_value = next_line.parse::<i64>()?;
            let new_sum = current_sum + next_value;
            current_sum = new_sum;
        }
    }
    acc.sort();
    acc.reverse();

    Ok(acc)
}

fn with_closure(reader: BufReader<File>) -> Result<i64, Box<dyn Error>> {
    let (_, max_sum) =
        reader.lines().try_fold(
            (0, 0),
            |(current_sum, max_sum), next_line| match next_line {
                Ok(next_line) => {
                    if next_line.eq("") {
                        Ok((0, max_sum))
                    } else {
                        match next_line.parse::<i64>() {
                            Ok(next_value) => {
                                let new_sum = current_sum + next_value;
                                Ok((new_sum, max(max_sum, new_sum)))
                            }
                            Err(err) => Err(Box::new(err) as Box<dyn Error>),
                        }
                    }
                }
                Err(err) => Err(Box::new(err) as Box<dyn Error>),
            },
        )?;

    Ok(max_sum)
}
