"""Predict whether one telecom customer will leave, with the model saved by Lab 2.

The notebook trained the model and saved two files in models/:
  customer_churn.joblib      the fitted pipeline (preprocessing + classifier)
  customer_churn_card.json   what the model expects, a typical customer, and how well it tested

This script loads both and prints a prediction. No training code is needed. Every column you do not
give takes the typical customer's value, from the card.

Example, from the course folder:
    python all_experiments/lab02_supervised_workflow/predict_churn.py --tenure 2 --contract Month-to-month --monthly 85
"""
import argparse
import json
from pathlib import Path

import joblib
import pandas as pd

MODELS = Path(__file__).resolve().parents[2] / "models"


def main():
    parser = argparse.ArgumentParser(description="Predict churn for one customer.")
    parser.add_argument("--tenure", type=int, required=True, help="months with the company")
    parser.add_argument("--contract", required=True, choices=["Month-to-month", "One year", "Two year"])
    parser.add_argument("--monthly", type=float, required=True, help="monthly charge in dollars")
    parser.add_argument("--internet", choices=["DSL", "Fiber optic"], help="internet service")
    parser.add_argument("--payment", choices=["Electronic check", "Mailed check", "Bank transfer (automatic)",
                                              "Credit card (automatic)"], help="how the customer pays")
    args = parser.parse_args()

    model = joblib.load(MODELS / "customer_churn.joblib")
    card = json.loads((MODELS / "customer_churn_card.json").read_text())

    # Start from the typical customer and change what was given; the total bill follows from tenure and charge.
    customer = dict(card["typical_customer"])
    customer.update({"tenure": args.tenure, "Contract": args.contract, "MonthlyCharges": args.monthly,
                     "TotalCharges": args.tenure * args.monthly})
    if args.internet:
        customer["InternetService"] = args.internet
    if args.payment:
        customer["PaymentMethod"] = args.payment
    row = pd.DataFrame([customer])[card["features"]]

    probability = float(model.predict_proba(row)[0, 1])
    decision = "likely to leave" if probability >= card["decision_threshold"] else "likely to stay"
    print(f"churn probability: {probability:.3f}  ->  {decision}")
    print(f"(model: {card['model']}, test ROC AUC {card['final_test_roc_auc']})")


if __name__ == "__main__":
    main()
