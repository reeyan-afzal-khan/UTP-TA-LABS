"""Convolutional networks: the worked numbers of Chapter 29.

Photographs of wood surface defects, 32 x 32 pixels in colour, seven kinds of defect, split by board as
in Labs 4 and 7. The script counts what convolution saves, works out sizes and receptive fields, and then
asks three networks a question a dense network finds hard: is a defect still the same defect when the
photo is moved a few pixels? It also measures what augmenting the training photos buys, and how much
the result moves from one random start to the next. Lab 7's test boards are not used.

Run from the course folder:      python all_experiments/book_checks/demo_cnn.py
It reads all_datasets/unsupervised/wood_surface_defects/ and takes about a minute and a half on a laptop CPU.
Network results move a little between computers and PyTorch versions, so their checks allow for it.
"""
import os
from pathlib import Path

os.environ.setdefault("KMP_DUPLICATE_LIB_OK", "TRUE")
import numpy as np
import torch
from sklearn.model_selection import GroupShuffleSplit
from torch import nn

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
torch.set_num_threads(4)


def photos():
    """Lab 7's board-wise split: the fitting and validation images only."""
    wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
    labels, boards = wood["y"], wood["board"]
    dev, _ = next(GroupShuffleSplit(n_splits=1, test_size=0.20, random_state=42).split(labels, labels, boards))
    fit, valid = next(GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=42).split(dev, labels[dev], boards[dev]))

    def tensors(rows):
        X = torch.tensor(wood["x"][dev[rows]], dtype=torch.float32).permute(0, 3, 1, 2) / 255.0
        return X, torch.tensor(labels[dev[rows]], dtype=torch.long)

    return tensors(fit), tensors(valid)


(X_FIT, Y_FIT), (X_VALID, Y_VALID) = photos()


def dense():
    """Lab 7's dense network."""
    return nn.Sequential(nn.Flatten(), nn.Linear(3 * 32 * 32, 128), nn.ReLU(), nn.Linear(128, 7))


def cnn():
    """Lab 7's CNN: two blocks of convolution and pooling, then flatten into a dense classifier."""
    return nn.Sequential(nn.Conv2d(3, 16, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
                         nn.Conv2d(16, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
                         nn.Flatten(), nn.Linear(32 * 8 * 8, 64), nn.ReLU(), nn.Dropout(0.2), nn.Linear(64, 7))


def averaging_cnn():
    """Three blocks, then the average of each of the 64 maps over the whole image: no position survives."""
    return nn.Sequential(nn.Conv2d(3, 16, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
                         nn.Conv2d(16, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
                         nn.Conv2d(32, 64, 3, padding=1), nn.ReLU(),
                         nn.AdaptiveAvgPool2d(1), nn.Flatten(), nn.Linear(64, 7))


def weights(model):
    return sum(p.numel() for p in model.parameters())


def output_size(n, kernel, padding, stride):
    return (n + 2 * padding - kernel) // stride + 1


def receptive_fields(layers):
    """How many input pixels, across, one unit sees after each layer. Each layer is (kernel, stride)."""
    field, jump, out = 1, 1, []
    for kernel, stride in layers:
        field += (kernel - 1) * jump
        jump *= stride
        out.append(field)
    return out


def shift(X, pixels):
    """Move every photo right by a number of pixels, repeating its left edge into the gap."""
    if pixels == 0:
        return X
    return torch.cat([X[..., :1].expand(-1, -1, -1, pixels), X[..., :-pixels]], dim=3)


def flips(batch, generator):
    """Flip each photo left to right, and top to bottom, each with a chance of one half."""
    batch = batch.clone()
    across = torch.rand(len(batch), generator=generator) < 0.5
    down = torch.rand(len(batch), generator=generator) < 0.5
    batch[across] = batch[across].flip(3)
    batch[down] = batch[down].flip(2)
    return batch


def nudges(batch, generator, most=4):
    """Move each photo by up to four pixels in each direction, wrapping round at the edges."""
    moves = torch.randint(-most, most + 1, (len(batch), 2), generator=generator).tolist()
    return torch.stack([torch.roll(photo, shifts=(down, across), dims=(1, 2)) for photo, (across, down) in zip(batch, moves)])


def train(make_model, augment=None, epochs=10, seed=42):
    """Build the model after seeding, so its starting weights repeat, then train it with Adam."""
    torch.manual_seed(seed)
    model = make_model()
    generator = torch.Generator().manual_seed(seed)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    for _ in range(epochs):
        model.train()
        order = torch.randperm(len(X_FIT), generator=generator)
        for start in range(0, len(order), 128):
            batch = order[start:start + 128]
            photos_ = X_FIT[batch] if augment is None else augment(X_FIT[batch], generator)
            optimizer.zero_grad()
            nn.functional.cross_entropy(model(photos_), Y_FIT[batch]).backward()
            optimizer.step()
    return model


def accuracy(model, X):
    model.eval()
    with torch.no_grad():
        guesses = torch.cat([model(X[i:i + 2000]).argmax(1) for i in range(0, len(X), 2000)])
    return (guesses == Y_VALID).float().mean().item()


def shift_test(model):
    return [round(accuracy(model, shift(X_VALID, pixels)), 3) for pixels in (0, 2, 4, 8)]


def main():
    print(f"{len(Y_FIT):,} photos to fit and {len(Y_VALID):,} to validate, from different boards; 7 kinds of defect\n")

    # Sizes and counts.
    FOUND["sizes"] = {"pad 1": output_size(32, 3, 1, 1), "no pad": output_size(32, 3, 0, 1),
                      "pad 1, stride 2": output_size(32, 3, 1, 2), "pool": output_size(32, 2, 0, 2)}
    print("output width of a 32-pixel input:", FOUND["sizes"])
    FOUND["fields"] = receptive_fields([(3, 1), (2, 2), (3, 1), (2, 2), (3, 1)])
    print("pixels seen across, after conv, pool, conv, pool, conv:", FOUND["fields"])
    first_dense = 3 * 32 * 32 * 128 + 128
    first_conv = 3 * 3 * 3 * 16 + 16
    FOUND["counts"] = {"first dense layer": first_dense, "first conv layer": first_conv,
                       "dense network": weights(dense()), "cnn": weights(cnn()), "averaging cnn": weights(averaging_cnn())}
    print("weights:", FOUND["counts"])

    # Moving the photos.
    FOUND["shift"] = {}
    for name, make in [("dense network", dense), ("cnn", cnn), ("averaging cnn", averaging_cnn)]:
        model = train(make)
        FOUND["shift"][name] = shift_test(model)
        print(f"{name:14s} validation accuracy when the photos move 0, 2, 4, 8 pixels: {FOUND['shift'][name]}")

    # Augmenting the training photos.
    FOUND["augment"] = {}
    for name, augment in [("flips", flips), ("moves of up to 4 pixels", nudges)]:
        model = train(cnn, augment=augment)
        FOUND["augment"][name] = shift_test(model)
        print(f"cnn trained with {name:24s}: {FOUND['augment'][name]}")

    # The same CNN from three other random starts.
    FOUND["seeds"] = [round(accuracy(train(cnn, seed=seed), X_VALID), 3) for seed in (0, 1, 2)]
    print("cnn from three other random starts:", FOUND["seeds"])

    if not CHECK_BOOK_NUMBERS:
        return

    def near(values, book, tolerance=0.03):
        assert all(abs(v - b) <= tolerance for v, b in zip(values, book)), f"got {values}, the book says {book}"

    assert FOUND["sizes"] == {"pad 1": 32, "no pad": 30, "pad 1, stride 2": 16, "pool": 16}
    assert FOUND["fields"] == [3, 4, 8, 10, 18]
    assert FOUND["counts"] == {"first dense layer": 393344, "first conv layer": 448, "dense network": 394247,
                               "cnn": 136679, "averaging cnn": 24039}
    near(FOUND["shift"]["dense network"], [0.573, 0.556, 0.441, 0.336])
    near(FOUND["shift"]["cnn"], [0.702, 0.660, 0.588, 0.472])
    near(FOUND["shift"]["averaging cnn"], [0.600, 0.590, 0.587, 0.556])
    near(FOUND["augment"]["flips"], [0.715, 0.685, 0.612, 0.455])
    near(FOUND["augment"]["moves of up to 4 pixels"], [0.695, 0.688, 0.674, 0.507])
    near(FOUND["seeds"], [0.708, 0.673, 0.701])
    # The pattern the chapter draws, which must hold whatever the exact numbers.
    assert FOUND["shift"]["cnn"][0] > FOUND["shift"]["dense network"][0] + 0.08
    assert FOUND["shift"]["averaging cnn"][3] > FOUND["shift"]["cnn"][3] + 0.05
    assert FOUND["augment"]["moves of up to 4 pixels"][2] > FOUND["shift"]["cnn"][2] + 0.04
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
