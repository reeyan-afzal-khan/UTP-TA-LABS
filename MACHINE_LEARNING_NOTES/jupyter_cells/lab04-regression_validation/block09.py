# cnt = casual + registered, so casual and registered would leak the target.
features = [
    "season", "yr", "mnth", "holiday", "weekday", "workingday",
    "weathersit", "temp", "atemp", "hum", "windspeed",
]
X = df[features]
y = df["cnt"]
