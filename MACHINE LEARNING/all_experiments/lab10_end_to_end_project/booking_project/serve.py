"""The service: a small web program that answers one question, "how likely is this booking to cancel?"

Start it from the course folder, after train.py has written the model:
    python all_experiments/lab10_end_to_end_project/booking_project/serve.py
Then send it a booking, for example with curl:
    curl -X POST http://127.0.0.1:8000/predict -H "Content-Type: application/json" -d @booking.json
"""
import json
import os
import time
from pathlib import Path

import joblib
from flask import Flask, jsonify, request

from bookings import cancellation_risk, check_booking

COURSE = Path(__file__).resolve().parents[3]
MODEL_PATH = Path(os.environ.get("MODEL_PATH", COURSE / "models" / "booking_cancellation.joblib"))
CARD_PATH = MODEL_PATH.with_name("booking_cancellation_card.json")


def create_app(model, version, log_path=None):
    """Build the web application around a fitted model. The model is loaded once, not for every request."""
    app = Flask(__name__)

    @app.get("/health")
    def health():
        return jsonify(status="ok", model_version=version)

    @app.post("/predict")
    def predict():
        started = time.perf_counter()
        booking = request.get_json(silent=True)
        if not isinstance(booking, dict):
            return jsonify(error="send one booking as a JSON object"), 400
        problems = check_booking(booking)
        if problems:
            return jsonify(error="the booking breaks the contract", problems=problems), 400
        risk = round(float(cancellation_risk(model, [booking])[0]), 4)
        if log_path is not None:                    # one line per answer: what came in, what went out
            line = {"time": time.strftime("%Y-%m-%d %H:%M:%S"), "model_version": version, "risk": risk,
                    "milliseconds": round(1000 * (time.perf_counter() - started), 1), "booking": booking}
            with open(log_path, "a", encoding="utf-8") as log:
                log.write(json.dumps(line) + "\n")
        return jsonify(cancel_probability=risk, model_version=version)

    return app


if __name__ == "__main__":
    card = json.loads(CARD_PATH.read_text(encoding="utf-8"))
    application = create_app(joblib.load(MODEL_PATH), card["version"], log_path=MODEL_PATH.with_name("predictions.log"))
    application.run(host=os.environ.get("HOST", "127.0.0.1"), port=int(os.environ.get("PORT", 8000)))
