import pandas as pd
from collections import defaultdict
from datetime import datetime

# =========================
# SEVERITY WEIGHTS
# =========================

weights = {
    "bajo": 1,
    "medio": 2,
    "alto": 3,
    "critico": 4
}

# =========================
# RISK ANALYSIS
# =========================

def analyze_risk(reports):

    zone_scores = defaultdict(int)
    hour_scores = defaultdict(int)
    day_scores = defaultdict(int)

    for report in reports:

        severity = (
            report.get("severity", "bajo")
            .lower()
        )

        zone = report.get(
            "zone",
            "Desconocido"
        )

        timestamp = report.get(
            "timestamp"
        )

        weight = weights.get(
            severity,
            1
        )

        # =========================
        # TIME ANALYSIS
        # =========================

        try:

            dt = datetime.fromisoformat(
                timestamp
            )

            hour = dt.hour

            day = dt.strftime("%A")

        except:

            hour = 0
            day = "Unknown"

        # =========================
        # NIGHT BONUS
        # =========================

        if hour >= 20 or hour <= 5:

            weight += 1

        # =========================
        # ACCUMULATE SCORES
        # =========================

        zone_scores[zone] += weight

        hour_scores[hour] += weight

        day_scores[day] += weight

    # =========================
    # TOP RESULTS
    # =========================

    most_dangerous_zone = max(
        zone_scores,
        key=zone_scores.get
    )

    most_dangerous_hour = max(
        hour_scores,
        key=hour_scores.get
    )

    most_dangerous_day = max(
        day_scores,
        key=day_scores.get
    )

    # =========================
    # NORMALIZED RISK
    # =========================

    max_score = zone_scores[
        most_dangerous_zone
    ]

    total = sum(
        zone_scores.values()
    )

    risk_score = round(
        max_score / total,
        2
    )

    return {

        "most_dangerous_zone":
            most_dangerous_zone,

        "most_dangerous_hour":
            most_dangerous_hour,

        "most_dangerous_day":
            most_dangerous_day,

        "risk_score":
            risk_score,

        "zone_scores":
            dict(zone_scores)
    }