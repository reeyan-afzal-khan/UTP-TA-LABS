"""Watching a model after it ships: has the data moved, and is the model still right?

psi() compares one column in two periods. drift_report() does that for several columns, and
monthly_report() adds what can only be known once the outcomes have arrived.
"""
import numpy as np
import pandas as pd
from sklearn.metrics import brier_score_loss, roc_auc_score

from bookings import FEATURES, TARGET


def psi(reference, current, bins=10):
    """Population stability index of one column: 0 when the two periods have the same distribution.

    A number column is cut into bins that each hold a tenth of the reference values; a text column
    uses its categories. The index adds up, over the bins, (share now - share then) x ln(share now / share then)."""
    reference, current = pd.Series(reference).dropna(), pd.Series(current).dropna()
    if pd.api.types.is_numeric_dtype(reference):
        edges = np.unique(np.quantile(reference, np.linspace(0, 1, bins + 1)))
        edges[0], edges[-1] = -np.inf, np.inf
        then = np.histogram(reference, edges)[0] / len(reference)
        now = np.histogram(current, edges)[0] / len(current)
    else:
        categories = sorted(set(reference.unique()) | set(current.unique()))
        then = reference.value_counts(normalize=True).reindex(categories, fill_value=0).to_numpy()
        now = current.value_counts(normalize=True).reindex(categories, fill_value=0).to_numpy()
    then, now = np.clip(then, 1e-4, None), np.clip(now, 1e-4, None)          # an empty bin would give ln(0)
    return float(((now - then) * np.log(now / then)).sum())


def drift_report(reference, current, columns):
    """The PSI of each column, largest first."""
    values = {column: psi(reference[column], current[column]) for column in columns}
    return pd.Series(values, name="psi").sort_values(ascending=False)


def monthly_report(model, bookings, months, reference):
    """One line per month of arrival: what could be seen on the first day, and what the outcomes showed later."""
    month = bookings["arrival_date"].dt.to_period("M")
    known_agents = set(reference["agent_id"])
    reference_risk = model.predict_proba(reference[FEATURES])[:, 1]
    rows = []
    for name in months:
        current = bookings[month == name]
        risk = model.predict_proba(current[FEATURES])[:, 1]
        rows.append({
            "month": str(name),
            "bookings": len(current),
            "new_agent_share": float((~current["agent_id"].isin(known_agents)).mean()),
            "psi_lead_time": psi(reference["lead_time"], current["lead_time"]),
            "psi_market_segment": psi(reference["market_segment"], current["market_segment"]),
            "psi_deposit_type": psi(reference["deposit_type"], current["deposit_type"]),
            "psi_risk": psi(reference_risk, risk),
            "expected": float(risk.sum()),
            "cancelled": int(current[TARGET].sum()),
            "auc": float(roc_auc_score(current[TARGET], risk)),
            "brier": float(brier_score_loss(current[TARGET], risk)),
        })
    return pd.DataFrame(rows).set_index("month")
