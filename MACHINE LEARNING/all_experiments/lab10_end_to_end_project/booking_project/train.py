"""Train the booking-cancellation model with one command.

From the course folder:
    python all_experiments/lab10_end_to_end_project/booking_project/train.py
    python all_experiments/lab10_end_to_end_project/booking_project/train.py --until 2017-06-01
It reads the hotel's file, checks it against the contract, measures the model on the most recent
bookings it can, fits it on every booking before the cut-off date, and writes three things:
the model, its card, and one line in the run log.
"""
import argparse
import json
import logging
import time
from pathlib import Path

import joblib
import pandas as pd
from sklearn.metrics import brier_score_loss, roc_auc_score

from bookings import FEATURES, TARGET, WRITTEN_LATER, make_model, read_bookings, validate

COURSE = Path(__file__).resolve().parents[3]
DATA = COURSE / "all_datasets" / "supervised" / "hotel_bookings" / "hotel_bookings.zip"
log = logging.getLogger("train")


def train(bookings, until, make=make_model):
    """Fit a model on every booking that arrives before `until`. Returns the model and the facts for its card.

    Before the final fit, the model is fitted without the bookings since the start of the previous
    quarter and scored on them. That score is the gate a new model must pass before it replaces the old one."""
    until = pd.Timestamp(until)
    past = bookings[bookings["arrival_date"] < until]
    gate_start = (until.to_period("Q") - 1).start_time
    earlier, gate = past[past["arrival_date"] < gate_start], past[past["arrival_date"] >= gate_start]
    risk = make().fit(earlier[FEATURES], earlier[TARGET]).predict_proba(gate[FEATURES])[:, 1]
    facts = {
        "task": "chance that a hotel booking is cancelled, asked on the first day of its month of arrival",
        "version": f"{until:%Y-%m-%d}",
        "trained_on": f"{len(past):,} bookings arriving {past['arrival_date'].min():%Y-%m-%d}"
                      f" to {past['arrival_date'].max():%Y-%m-%d}",
        "gate": f"bookings arriving from {gate_start:%Y-%m-%d}, scored by a model fitted on the earlier ones",
        "gate_bookings": len(gate),
        "gate_auc": round(float(roc_auc_score(gate[TARGET], risk)), 4),
        "gate_brier": round(float(brier_score_loss(gate[TARGET], risk)), 4),
        "gate_expected": int(round(risk.sum())),
        "gate_cancelled": int(gate[TARGET].sum()),
        "features": FEATURES,
        "never_use": WRITTEN_LATER,
    }
    model = make().fit(past[FEATURES], past[TARGET])
    return model, facts


def save(model, facts, models_folder, results_folder, name="booking_cancellation"):
    """Write the model, its card, and one line in the run log. Returns the three paths."""
    models_folder, results_folder = Path(models_folder), Path(results_folder)
    models_folder.mkdir(parents=True, exist_ok=True)
    results_folder.mkdir(parents=True, exist_ok=True)
    model_path, card_path = models_folder / f"{name}.joblib", models_folder / f"{name}_card.json"
    joblib.dump(model, model_path)
    card_path.write_text(json.dumps(facts, indent=2), encoding="utf-8")
    run = {"time": time.strftime("%Y-%m-%d %H:%M:%S"), "model": name}
    run.update({key: facts[key] for key in ["version", "gate_bookings", "gate_auc", "gate_brier", "gate_expected",
                                            "gate_cancelled"]})
    runs_path = results_folder / "runs.csv"
    pd.DataFrame([run]).to_csv(runs_path, mode="a", header=not runs_path.exists(), index=False)
    return model_path, card_path, runs_path


def main():
    parser = argparse.ArgumentParser(description="Train the booking-cancellation model.")
    parser.add_argument("--until", default="2017-01-01", help="train on bookings that arrive before this date")
    parser.add_argument("--data", default=str(DATA), help="the hotel's file")
    parser.add_argument("--models", default=str(COURSE / "models"), help="where the model and its card go")
    parser.add_argument("--results", default=str(COURSE / "results" / "lab10"), help="where the run log goes")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    started = time.perf_counter()
    problems = validate(pd.read_csv(args.data))
    for line in problems:
        log.warning("contract: %s", line)
    if any("column is missing" in line for line in problems):
        raise SystemExit("stopped: the file breaks the contract, a column is missing")
    bookings = read_bookings(args.data)
    log.info("read %s bookings, %s contract warnings", f"{len(bookings):,}", len(problems))

    model, facts = train(bookings, args.until)
    log.info("gate: AUC %.4f on %s bookings; expected %s cancellations, %s happened", facts["gate_auc"],
             f"{facts['gate_bookings']:,}", f"{facts['gate_expected']:,}", f"{facts['gate_cancelled']:,}")
    model_path, card_path, runs_path = save(model, facts, args.models, args.results)
    log.info("wrote %s, %s and a line in %s (%.0f seconds)", model_path.name, card_path.name, runs_path.name,
             time.perf_counter() - started)


if __name__ == "__main__":
    main()
