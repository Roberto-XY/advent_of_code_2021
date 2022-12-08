use std::{
    env,
    error::Error,
    fs::File,
    io::{BufRead, BufReader},
    iter,
};

fn main() -> Result<(), Box<dyn Error>> {
    let path = env::current_dir()?.join("data/day8.txt");
    let reader = BufReader::new(File::open(path.clone())?);

    let mut forest: Vec<Vec<u8>> = vec![];
    for line_or_err in reader.lines() {
        let line = line_or_err?;
        let row = line
            .chars()
            .map(|c| c as u8 - '0' as u8)
            .collect::<Vec<_>>();

        forest.push(row);
    }
    let forest = forest;

    let max_row_idx = forest.len() - 1;
    let max_col_idx = forest
        .iter()
        .map(|row| row.len() - 1)
        .min()
        .unwrap_or_default();

    let mut visibility_count = 0u64;
    for row_idx in 0..forest.len() {
        for col_idx in 0..forest[row_idx].len() {
            if row_idx == 0 || row_idx == max_row_idx || col_idx == 0 || col_idx == max_col_idx {
                visibility_count += 1;
            } else {
                let current_tree_height = forest[row_idx][col_idx];

                let right = iter::repeat(row_idx).zip(col_idx..=max_col_idx).skip(1);
                let left = iter::repeat(row_idx).zip((0..col_idx).rev());
                let up = (0..row_idx).rev().zip(iter::repeat(col_idx));
                let down = (row_idx..=max_row_idx).skip(1).zip(iter::repeat(col_idx));

                let is_visible_from_right = is_visible(right, &forest, current_tree_height);
                let is_visible_from_left = is_visible(left, &forest, current_tree_height);
                let is_visible_from_up = is_visible(up, &forest, current_tree_height);
                let is_visible_from_down = is_visible(down, &forest, current_tree_height);

                let is_visible = is_visible_from_right
                    || is_visible_from_left
                    || is_visible_from_up
                    || is_visible_from_down;

                if is_visible {
                    visibility_count += 1;
                }
            }
        }
    }
    dbg!(&visibility_count);

    let max_scenic_score = (0..forest.len())
        .flat_map(|row_idx| iter::repeat(row_idx).zip(0..forest[row_idx].len()))
        .map(|(row_idx, col_idx)| {
            let current_tree_height = forest[row_idx][col_idx];

            let right = iter::repeat(row_idx).zip(col_idx..=max_col_idx).skip(1);
            let left = iter::repeat(row_idx).zip((0..col_idx).rev());
            let up = (0..row_idx).rev().zip(iter::repeat(col_idx));
            let down = (row_idx..=max_row_idx).skip(1).zip(iter::repeat(col_idx));

            let scenic_score = get_visibility_score(right, &forest, current_tree_height)
                * get_visibility_score(left, &forest, current_tree_height)
                * get_visibility_score(up, &forest, current_tree_height)
                * get_visibility_score(down, &forest, current_tree_height);
            scenic_score
        })
        .max();
    dbg!(&max_scenic_score);

    Ok(())
}

fn is_visible(
    idx_iter: impl Iterator<Item = (usize, usize)>,
    forest: &Vec<Vec<u8>>,
    current_tree_height: u8,
) -> bool {
    idx_iter
        .map(|(row_idx, col_idx)| forest[row_idx][col_idx])
        .all(|height| height < current_tree_height)
}

fn get_visibility_score(
    idx_iter: impl Iterator<Item = (usize, usize)>,
    forest: &Vec<Vec<u8>>,
    current_tree_height: u8,
) -> u64 {
    let mut visibility_score = 0u64;
    for (row_idx, col_idx) in idx_iter {
        if forest[row_idx][col_idx] < current_tree_height {
            visibility_score += 1;
        } else {
            return visibility_score + 1;
        }
    }

    return visibility_score;
}
