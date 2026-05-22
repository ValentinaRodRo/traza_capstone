import joblib
import pandas as pd
import spacy
import unicodedata
import re
from app.zone_classifier import classify_zone
import numpy as np

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = (
    BASE_DIR.parent
    / "models"
    / "severity_classifier.pkl"
)

model = joblib.load(MODEL_PATH)

nlp = spacy.load(
    "es_core_news_sm"
)


def normalize_text(text):

    text = text.lower()

    text = unicodedata.normalize(
        "NFKD",
        text
    ).encode(
        "ascii",
        "ignore"
    ).decode(
        "utf-8"
    )

    text = re.sub(
        r"(.)\1{2,}",
        r"\1\1",
        text
    )

    return text


def clean_spanish_text(text):

    text = normalize_text(text)

    doc = nlp(text)

    tokens = []

    for token in doc:

        if (
            not token.is_stop
            and not token.is_punct
            and not token.like_num
        ):

            tokens.append(
                token.lemma_.lower()
            )

    return " ".join(tokens)


def process_report(report):

    # =========================
    # CLEAN TEXT
    # =========================

    clean_text = clean_spanish_text(
        report["description"]
    )

    # =========================
    # PREPARE INPUT
    # =========================

    input_df = pd.DataFrame([{

        "clean_description":
            clean_text,

        "category":
            report["category"]

    }])

    # =========================
    # PREDICT SEVERITY
    # =========================

    prediction = model.predict(
        input_df
    )[0]

    decision_scores = model.decision_function(
        input_df
    )

    scores = decision_scores[0]

    exp_scores = np.exp(scores)

    probabilities = exp_scores / exp_scores.sum()

    confidence = round(
        float(max(probabilities)),
        2
    )

    # =========================
    # CLASSIFY ZONE
    # =========================

    zone = classify_zone(
        report["latitude"],
        report["longitude"]
    )

    # =========================
    # RISK WEIGHTS
    # =========================

    severity_weights = {

        "bajo": 0.25,

        "medio": 0.50,

        "alto": 0.75,

        "critico": 1.00
    }

    base_risk = severity_weights.get(
        prediction,
        0.50
    )

    # =========================
    # TIME ANALYSIS
    # =========================

    timestamp = pd.to_datetime(
        report["timestamp"]
    )

    hour = timestamp.hour

    night_bonus = 0

    if hour >= 22 or hour <= 5:

        night_bonus = 0.15

    # =========================
    # FINAL RISK SCORE
    # =========================

    risk_score = min(

        1.0,

        (
            base_risk
            *
            confidence
        )
        +
        night_bonus
    )

    # =========================
    # RETURN RESULT
    # =========================

    return {

        "severity":
            prediction,

        "confidence":
            round(
                float(confidence),
                2
            ),

        "zone":
            zone,

        "risk_score":
            round(
                float(risk_score),
                2
            )
    }