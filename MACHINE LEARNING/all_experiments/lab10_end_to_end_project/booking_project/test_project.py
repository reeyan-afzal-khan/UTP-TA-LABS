"""Tests for the booking project: the checks that must pass before a new version is allowed to ship.

From the course folder, either of:
    python all_experiments/lab10_end_to_end_project/booking_project/test_project.py
    pytest all_experiments/lab10_end_to_end_project/booking_project/test_project.py
"""
import functools
import json
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.metrics import roc_auc_score

from bookings import CONTRACT, FEATURES, TARGET, add_features, cancellation_risk, check_booking, read_bookings
from serve import create_app
from train import train

COURSE = Path(__file__).resolve().parents[3]
DATA = COURSE / "all_datasets" / "supervised" / "hotel_bookings" / "hotel_bookings.zip"


@functools.lru_cache(maxsize=None)
def project():
    """The bookings and a model trained on those before 2017: built once and shared by every test."""
    bookings = read_bookings(DATA)
    model, facts = train(bookings, "2017-01-01")
    return bookings, model, facts


def as_request(row):
    """One row of the table as the service would receive it: plain Python values, blanks as None."""
    return json.loads(row[list(CONTRACT)].to_json())


def test_contract_accepts_a_real_booking():
    bookings, _, _ = project()
    assert check_booking(as_request(bookings.iloc[1000])) == []


def test_contract_says_what_is_wrong():
    bookings, _, _ = project()
    bad = as_request(bookings.iloc[1000])
    bad.update(lead_time=-3, deposit_type="Maybe")
    del bad["adr"]
    problems = check_booking(bad)
    assert len(problems) == 3
    assert [line.split(":")[0] for line in problems] == ["lead_time", "deposit_type", "adr"]


def test_features_do_not_depend_on_the_batch():
    """A booking gets the same features alone as in a table of thousands: no feature looks at other rows."""
    bookings, _, _ = project()
    raw = bookings[list(CONTRACT)]
    together = add_features(raw).iloc[[5000]]
    alone = add_features(raw.iloc[[5000]])
    pd.testing.assert_frame_equal(together[FEATURES], alone[FEATURES])


def test_a_new_category_does_not_crash():
    bookings, model, _ = project()
    new = as_request(bookings.iloc[1000])
    new.update(agent=99999, reserved_room_type="Z")              # an agent and a room type never seen
    risk = cancellation_risk(model, [new])[0]
    assert 0 <= risk <= 1


def test_model_clears_the_floor():
    """The agreed floor: on the first quarter of 2017, which the model never saw, ROC AUC of at least 0.84."""
    bookings, model, _ = project()
    quarter = bookings[(bookings["arrival_date"] >= "2017-01-01") & (bookings["arrival_date"] < "2017-04-01")]
    auc = roc_auc_score(quarter[TARGET], model.predict_proba(quarter[FEATURES])[:, 1])
    assert auc >= 0.84, auc


def test_non_refundable_bookings_score_higher():
    """A direction the hotel relies on: the same booking, made non-refundable, must not look safer."""
    bookings, model, _ = project()
    sample = bookings[bookings["deposit_type"] == "No Deposit"].sample(200, random_state=0)
    before = model.predict_proba(sample[FEATURES])[:, 1]
    after = model.predict_proba(sample.assign(deposit_type="Non Refund")[FEATURES])[:, 1]
    assert np.all(after >= before)


def test_service_answers_and_refuses():
    bookings, model, facts = project()
    client = create_app(model, facts["version"]).test_client()
    assert client.get("/health").get_json() == {"status": "ok", "model_version": "2017-01-01"}
    good = client.post("/predict", json=as_request(bookings.iloc[1000]))
    assert good.status_code == 200 and 0 <= good.get_json()["cancel_probability"] <= 1
    bad = client.post("/predict", json={"hotel": "City Hotel"})
    assert bad.status_code == 400 and len(bad.get_json()["problems"]) == 19
    assert client.post("/predict", data="not json").status_code == 400


if __name__ == "__main__":
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_")]
    for test in tests:
        test()
        print("passed:", test.__name__)
    print(f"{len(tests)} tests passed")
