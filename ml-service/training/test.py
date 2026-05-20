import joblib
import pandas as pd
import spacy
import unicodedata
import re

# Load Spanish model
nlp = spacy.load("es_core_news_sm")

# Normalize text
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

# Clean text
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

# Load model
model = joblib.load(
    "../models/severity_classifier.pkl"
)

# Example report
description = (
    "Dos hombres armados persiguiendo estudiantes"
)

clean_text = clean_spanish_text(
    description
)

report = pd.DataFrame([{
    "clean_description": clean_text,
    "category": "robo"
}])

# Predict
prediction = model.predict(
    report
)[0]

# Confidence
confidence = max(
    model.predict_proba(
        report
    )[0]
)

print("\nPrediction:")
print(prediction)

print("\nConfidence:")
print(round(confidence, 2))