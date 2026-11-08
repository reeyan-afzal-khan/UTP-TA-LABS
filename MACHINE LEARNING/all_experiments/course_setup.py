"""The setup every lab shares.

Each lab's first code cell starts the same way:

    import sys
    sys.path.insert(0, "..")                    # all_experiments/, the folder that holds this file
    from course_setup import start_lab
    DATA, RESULTS, MODELS = start_lab("lab02")

After that the lab reads its data from DATA (the course's all_datasets/ folder), writes figures and tables
to RESULTS (results/lab02/), and saves trained models to MODELS (models/). Nothing else in a lab needs
to know where the course folder is.

The two deep-learning labs also call start_pytorch(), which makes sure PyTorch is installed and picks
the device the network will train on.

A notebook runs inside its own lab folder, and each lab's .py script moves there first, so ".."
above is always all_experiments/.
"""
import os
import platform
import site
import subprocess
import sys
from pathlib import Path

# Anaconda's NumPy and pip's PyTorch each bring an OpenMP runtime on Windows. Allow both, before either
# is imported; without this line a Windows run can stop with "OMP: Error #15".
os.environ.setdefault("KMP_DUPLICATE_LIB_OK", "TRUE")


def find_course_folder(start=None):
    """Return the course folder: the nearest folder, from here upwards, that holds all_datasets/."""
    here = Path(start or Path.cwd()).resolve()
    for folder in [here, *here.parents]:
        if (folder / "all_datasets").is_dir():
            return folder
    raise FileNotFoundError(f"No all_datasets/ folder above {here}. Open the notebook from inside the course folder.")


def start_lab(lab):
    """Name the three folders a lab uses, create the two it writes to, and say where they are.

    lab is the lab's short name, such as "lab02". Returns (DATA, RESULTS, MODELS) as Path objects.
    """
    course = find_course_folder()
    data = course / "all_datasets"
    results = course / "results" / lab
    models = course / "models"
    results.mkdir(parents=True, exist_ok=True)
    models.mkdir(exist_ok=True)
    print(f"course folder: {course.name}")
    print(f"reads all_datasets/, writes results/{lab}/ and models/")
    return data, results, models


def start_pytorch(seed=42):
    """Make sure PyTorch can be imported, choose the device to train on, and seed PyTorch.

    If PyTorch is missing from the Python running this notebook, the CPU build is installed once
    (a few hundred MB). The device is an NVIDIA GPU ("cuda") or an Apple GPU ("mps") when PyTorch
    can see one, otherwise the CPU; every lab runs on a laptop CPU in a few minutes.
    """
    try:
        import torch
    except ModuleNotFoundError:
        print("PyTorch is not installed for", sys.executable, "- installing the CPU build once ...")
        pip = [sys.executable, "-m", "pip", "install", "torch"]
        if subprocess.run(pip + ["--index-url", "https://download.pytorch.org/whl/cpu"]).returncode != 0:
            subprocess.run(pip, check=True)            # PyTorch's own index unreachable: use PyPI instead
        site.addsitedir(site.getusersitepackages())    # pip may have used the per-user folder
        import torch

    if torch.cuda.is_available():
        device = torch.device("cuda")
    elif getattr(torch.backends, "mps", None) is not None and torch.backends.mps.is_available():
        device = torch.device("mps")
    else:
        device = torch.device("cpu")
    torch.manual_seed(seed)

    gpu = f" ({torch.cuda.get_device_name(0)})" if device.type == "cuda" else ""
    print(f"Python {platform.python_version()} at {sys.executable}")
    print(f"PyTorch {torch.__version__} | device: {device}{gpu}")
    return device
