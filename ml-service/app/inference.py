import joblib
import pandas as pd
import spacy
import unicodedata
import re

model = joblib.load(
    "../models/severity_classifier.pkl"
)

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

    clean_text = clean_spanish_text(
        report["description"]
    )

    input_df = pd.DataFrame([{
        "clean_description":
            clean_text,

        "category":
            report["category"]
    }])

    prediction = model.predict(
        input_df
    )[0]

    confidence = max(
        model.predict_proba(
            input_df
        )[0]
    )

    return {

        "severity":
            prediction,

        "confidence":
            round(
                float(confidence),
                2
            ),

        "zone":
            "A1",

        "risk_score":
            0.72
    }