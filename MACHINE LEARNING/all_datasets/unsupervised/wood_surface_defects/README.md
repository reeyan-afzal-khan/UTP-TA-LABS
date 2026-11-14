# Wood surface defects

15,701 photos of defects on sawn wooden boards, cut from 10,358 board photos and shrunk to 32 x 32 colour pixels, each labeled with one of 7 defect types, as NumPy arrays.

**Used in:** Lab 4 (PCA: how few directions describe a defect), the chapter *Convolutional Networks* (dense networks against CNNs, shifts, augmentation and random starts) and Lab 7 (a CNN against the PCA baseline). Lab 4 never trains on the labels except to measure what PCA kept.

**Source and licence:** Kodytek, Bodzas and Bilik, *A large-scale image dataset of wood surface defects for automated vision-based quality control processes*, F1000Research, 2022 (doi:10.12688/f1000research.52903.2), via [Hugging Face](https://huggingface.co/datasets/iluvvatar/wood_surface_defects); CC BY 4.0.

**Changed from the source:** The source holds 20,276 photos of whole boards, with a box around each defect. Every box of the seven defect types kept here was cut out as a square 20% wider than the defect's longer side, and shrunk to 32 x 32 colour pixels. The three most common types, live knots, dead knots and resin, were capped at 3,000 crops each (seed 42). `board` keeps the photo each crop came from.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `wood_defects.npz` | 39.0 MB | `np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- Load it with `np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")`. `x` holds the images as height x width x colour, with values from 0 to 255; `y` is the defect type, a position in `classes`.
- Crops per type: live knot 3,000, dead knot 3,000, resin 3,000, knot with crack 2,276, crack 2,169, marrow 1,181, quartzity 1,075. The classes are not balanced, so report per-class recall as well as accuracy.
- 9,016 crops share their board with at least one other crop (up to 12 on one board). Split by `board` (for example with `GroupShuffleSplit`), or crops of the same board land on both sides of the split.

## Arrays in `wood_defects.npz`

| Array | Shape | Type |
| --- | --- | --- |
| `x` | (15701, 32, 32, 3) | uint8 |
| `y` | (15701,) | int64 |
| `board` | (15701,) | int64 |
| `classes` | (7,) | <U15 |
