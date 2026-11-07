"""Chapter 6 worked forecast; explicit capacity and opening-stock assumptions."""
from pathlib import Path
import argparse
import csv

parser = argparse.ArgumentParser()
parser.add_argument("--safety-stock", type=float, default=100,
                    help="Classroom opening inventory and minimum stock assumption")
parser.add_argument("--unit", choices=["pairs", "shoes"], default="pairs",
                    help="Interpret the stated rate of 40 units per hour")
args = parser.parse_args()
assert args.safety_stock >= 0
months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split()
sales = [4000,4000,4500,5000,5000,5500,5500,5750,6000,6000,6200,6300]
old_promo = [0,0,0,0,0,200,0,0,0,0,400,400]
new_promo = [0,0,0,0,0,0,0,0,0,0,500,400]
days = [22,20,23,20,21,22,21,22,22,21,22,21]
production = [4600,4600,5000,5400,5400,5700,5900,6050,6200,6200,6200,6200]
rate_pairs = 40 if args.unit == "pairs" else 20
inventory = args.safety_stock
rows = []
for month,actual,prior,promo,workdays,planned in zip(
        months,sales,old_promo,new_promo,days,production):
    base = actual - prior
    forecast = base * 1.03 + promo
    capacity = rate_pairs * 8 * workdays
    opening = inventory
    inventory = opening + planned - forecast
    utilisation = planned / capacity
    feasible = utilisation <= .99 and inventory >= args.safety_stock
    rows.append([month,base,forecast,capacity,planned,opening,inventory,utilisation,feasible])
    print(f"{month}: forecast={forecast:.1f} capacity={capacity} "
          f"close={inventory:.1f} utilisation={utilisation:.1%} feasible={feasible}")
assert abs(rows[10][2] - 6474) < 1e-9
out = Path(__file__).resolve().parents[1] / "results" / "lab06"
out.mkdir(parents=True, exist_ok=True)
with (out / ("sop_" + args.unit + ".csv")).open("w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["month","base","forecast","capacity_pairs","production_pairs",
                     "opening_pairs","closing_pairs","utilisation","feasible"])
    writer.writerows(rows)
print("Assumptions: chapter production plan; opening stock equals selected safety stock.")
