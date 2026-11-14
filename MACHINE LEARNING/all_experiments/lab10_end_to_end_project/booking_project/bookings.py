"""The booking-cancellation project: the code that training and serving share.

Everything that has to be done the same way when the model is trained and when it is used lives in
this one file: what a valid booking looks like, how its features are computed, and how the model is
built. train.py, serve.py, app.py, monitor.py and the tests all import it, so they cannot drift apart.
"""
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder, StandardScaler

# The contract: what each column of a booking may hold. A number column has a lowest and a highest
# allowed value, a text column has a set of allowed values, and None means "any value".
CONTRACT = {
    "hotel": {"City Hotel", "Resort Hotel"},
    "lead_time": (0, 800),
    "stays_in_weekend_nights": (0, 30),
    "stays_in_week_nights": (0, 60),
    "adults": (0, 10),
    "children": (0, 10),
    "babies": (0, 10),
    "meal": {"BB", "HB", "FB", "SC", "Undefined"},
    "market_segment": {"Online TA", "Offline TA/TO", "Groups", "Direct", "Corporate", "Complementary",
                       "Aviation"},
    "distribution_channel": {"TA/TO", "Direct", "Corporate", "GDS"},
    "is_repeated_guest": (0, 1),
    "previous_cancellations": (0, 50),
    "previous_bookings_not_canceled": (0, 100),
    "reserved_room_type": None,
    "deposit_type": {"No Deposit", "Non Refund", "Refundable"},
    "agent": None,
    "days_in_waiting_list": (0, 400),
    "customer_type": {"Transient", "Transient-Party", "Contract", "Group"},
    "adr": (0, 1000),
    "required_car_parking_spaces": (0, 8),
    "total_of_special_requests": (0, 5),
}
MAY_BE_BLANK = {"agent"}            # a blank agent means that no travel agent was involved

# Columns that exist in the hotel's file and must never reach the model: they are written after the
# day on which the model is asked.
WRITTEN_LATER = ["reservation_status", "reservation_status_date", "assigned_room_type", "booking_changes",
                 "country"]

NUMBERS = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
           "previous_cancellations", "previous_bookings_not_canceled", "adr", "required_car_parking_spaces",
           "total_of_special_requests", "total_nights", "total_guests", "with_children", "log_lead_time",
           "cancelled_before", "is_repeated_guest", "days_in_waiting_list"]
CATEGORIES = ["hotel", "meal", "market_segment", "deposit_type", "customer_type", "distribution_channel",
              "reserved_room_type", "agent_id"]
FEATURES = NUMBERS + CATEGORIES
TARGET = "is_canceled"


def validate(table, contract=CONTRACT):
    """Check a table against the contract. Returns one line per problem; an empty list means it passed."""
    problems = []
    for column, allowed in contract.items():
        if column not in table.columns:
            problems.append(f"{column}: column is missing")
            continue
        values = table[column].dropna()
        blanks = len(table) - len(values)
        if blanks and column not in MAY_BE_BLANK:
            problems.append(f"{column}: {blanks:,} blank cells")
        if isinstance(allowed, tuple):
            outside = int(((values < allowed[0]) | (values > allowed[1])).sum())
            if outside:
                problems.append(f"{column}: {outside:,} values outside {allowed[0]} to {allowed[1]}")
        elif isinstance(allowed, set):
            unknown = sorted(set(values.unique()) - allowed)
            if unknown:
                problems.append(f"{column}: unexpected values {unknown}")
    return problems


def check_booking(booking, contract=CONTRACT):
    """Check one booking, given as a dictionary. Returns a list of problems, written for whoever sent it."""
    problems = []
    for column, allowed in contract.items():
        value = booking.get(column)
        if value is None:
            if column not in MAY_BE_BLANK:
                problems.append(f"{column}: missing")
        elif isinstance(allowed, tuple):
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                problems.append(f"{column}: must be a number, got {value!r}")
            elif not allowed[0] <= value <= allowed[1]:
                problems.append(f"{column}: {value} is outside {allowed[0]} to {allowed[1]}")
        elif isinstance(allowed, set) and value not in allowed:
            problems.append(f"{column}: {value!r} is not one of {sorted(allowed)}")
    unknown = sorted(set(booking) - set(contract))
    if unknown:
        problems.append(f"unknown fields: {unknown}")
    return problems


def add_features(bookings):
    """Add the engineered columns. Each is computed from one booking alone, so one booking is enough."""
    bookings = bookings.copy()
    children = bookings["children"].fillna(0).astype(int)
    bookings["total_nights"] = bookings["stays_in_weekend_nights"] + bookings["stays_in_week_nights"]
    bookings["total_guests"] = bookings["adults"] + children + bookings["babies"]
    bookings["with_children"] = ((children + bookings["babies"]) > 0).astype(int)
    bookings["log_lead_time"] = np.log1p(bookings["lead_time"])
    bookings["cancelled_before"] = (bookings["previous_cancellations"] > 0).astype(int)
    agent = pd.to_numeric(bookings["agent"], errors="coerce").fillna(0)          # 0 stands for "no agent"
    bookings["agent_id"] = agent.astype(int).astype(str)
    return bookings


def read_bookings(path):
    """Read the hotel's file, build the arrival date, put the bookings in date order, add the features."""
    bookings = pd.read_csv(path)
    text_date = (bookings["arrival_date_year"].astype(str) + "-" + bookings["arrival_date_month"]
                 + "-" + bookings["arrival_date_day_of_month"].astype(str))
    bookings["arrival_date"] = pd.to_datetime(text_date, format="%Y-%B-%d")
    bookings = bookings.sort_values("arrival_date", kind="stable").reset_index(drop=True)
    return add_features(bookings)


def logistic(numbers=NUMBERS, categories=CATEGORIES):
    """Fill, scale and one-hot encode, then a logistic regression."""
    prepare = ColumnTransformer([
        ("num", Pipeline([("fill", SimpleImputer(strategy="median")), ("scale", StandardScaler())]), numbers),
        ("cat", Pipeline([("fill", SimpleImputer(strategy="most_frequent")),
                          ("onehot", OneHotEncoder(handle_unknown="ignore"))]), categories),
    ])
    return Pipeline([("prepare", prepare), ("model", LogisticRegression(max_iter=3000))])


def with_trees(model, numbers=NUMBERS, categories=CATEGORIES):
    """Fill the numbers and give each category a code, then a tree model. A new category gets the code -1."""
    codes = OrdinalEncoder(handle_unknown="use_encoded_value", unknown_value=-1, encoded_missing_value=-1)
    prepare = ColumnTransformer([("num", SimpleImputer(strategy="median"), numbers), ("cat", codes, categories)])
    return Pipeline([("prepare", prepare), ("model", model)])


def boosting(numbers=NUMBERS, categories=CATEGORIES, **settings):
    """Gradient boosting on trees, with the settings given (the rest keep scikit-learn's defaults)."""
    chosen = {"max_iter": 300, "learning_rate": 0.1, "random_state": 42, **settings}
    return with_trees(HistGradientBoostingClassifier(**chosen), numbers, categories)


def make_model():
    """The champion: the model the hotel runs."""
    return logistic()


def make_challenger():
    """The challenger: the best gradient boosting found by the search, kept running beside the champion."""
    return boosting(learning_rate=0.1, max_leaf_nodes=31, min_samples_leaf=50, max_iter=100)


def cancellation_risk(model, bookings):
    """The chance of cancelling for a list of bookings (dictionaries) that have passed check_booking."""
    table = add_features(pd.DataFrame(bookings, columns=list(CONTRACT)))
    return model.predict_proba(table[FEATURES])[:, 1]
