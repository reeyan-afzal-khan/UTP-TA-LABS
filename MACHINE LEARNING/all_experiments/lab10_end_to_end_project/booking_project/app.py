"""A one-page app for the front desk: fill in a booking and read its chance of cancelling.

Start it from the course folder, after train.py has written the model:
    streamlit run all_experiments/lab10_end_to_end_project/booking_project/app.py
"""
import json
import os
import sys
from pathlib import Path

import joblib
import streamlit as st

sys.path.insert(0, str(Path(__file__).resolve().parent))         # find bookings.py beside this file
from bookings import cancellation_risk, check_booking

COURSE = Path(__file__).resolve().parents[3]
MODEL_PATH = Path(os.environ.get("MODEL_PATH", COURSE / "models" / "booking_cancellation.joblib"))


@st.cache_resource                       # load the model once, not every time a field changes
def load_model(path):
    card = json.loads(path.with_name("booking_cancellation_card.json").read_text(encoding="utf-8"))
    return joblib.load(path), card


model, card = load_model(MODEL_PATH)
st.title("Will this booking be cancelled?")
st.caption(f"Model version {card['version']}, trained on {card['trained_on']}.")

left, right = st.columns(2)
booking = {
    "hotel": left.selectbox("Hotel", ["City Hotel", "Resort Hotel"], key="hotel"),
    "lead_time": left.number_input("Days from booking to arrival", 0, 800, 60, key="lead_time"),
    "stays_in_weekend_nights": left.number_input("Weekend nights", 0, 30, 1, key="weekend_nights"),
    "stays_in_week_nights": left.number_input("Week nights", 0, 60, 2, key="week_nights"),
    "adults": left.number_input("Adults", 0, 10, 2, key="adults"),
    "children": left.number_input("Children", 0, 10, 0, key="children"),
    "babies": 0,
    "meal": left.selectbox("Meal", ["BB", "HB", "FB", "SC"], key="meal"),
    "market_segment": right.selectbox("Market segment", ["Online TA", "Offline TA/TO", "Groups", "Direct",
                                                         "Corporate"], key="market_segment"),
    "distribution_channel": right.selectbox("Channel", ["TA/TO", "Direct", "Corporate", "GDS"], key="channel"),
    "is_repeated_guest": int(right.checkbox("Has stayed before", key="repeated")),
    "previous_cancellations": right.number_input("Earlier cancellations", 0, 50, 0, key="cancellations"),
    "previous_bookings_not_canceled": 0,
    "reserved_room_type": "A",
    "deposit_type": right.selectbox("Deposit", ["No Deposit", "Non Refund", "Refundable"], key="deposit_type"),
    "agent": None,
    "days_in_waiting_list": 0,
    "customer_type": right.selectbox("Customer type", ["Transient", "Transient-Party", "Contract", "Group"],
                                     key="customer_type"),
    "adr": right.number_input("Price per night (euros)", 0.0, 1000.0, 95.0, key="adr"),
    "required_car_parking_spaces": 0,
    "total_of_special_requests": right.number_input("Special requests", 0, 5, 0, key="requests"),
}

problems = check_booking(booking)
if problems:
    st.error("This booking breaks the contract: " + "; ".join(problems))
else:
    risk = float(cancellation_risk(model, [booking])[0])
    st.metric("Chance of cancelling", f"{risk:.0%}")
    st.progress(risk)
