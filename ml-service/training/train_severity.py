import pandas as pd
import joblib
import spacy
import unicodedata
import re

from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

# Load Spanish NLP model
nlp = spacy.load("es_core_news_sm")


# =========================
# TEXT NORMALIZATION
# =========================

def normalize_text(text):

    text = str(text)

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


# =========================
# SPANISH CLEANING
# =========================

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


# =========================
# LOAD DATASET
# =========================

df = pd.read_csv(
    "../data/severity_dataset.csv"
)

# Clean category column
df["category"] = (
    df["category"]
    .astype(str)
    .str.lower()
    .str.strip()
)

# Clean text descriptions
df["clean_description"] = df[
    "description"
].apply(clean_spanish_text)

# Optional debug
print("Unique categories:")
print(df["category"].unique())


# =========================
# FEATURES / TARGET
# =========================

X = df[
    ["clean_description", "category"]
]

y = df["severity"]


# =========================
# PREPROCESSING
# =========================

preprocessor = ColumnTransformer([
    (
        "text",
        TfidfVectorizer(),
        "clean_description"
    ),
    (
        "category",
        OneHotEncoder(
            handle_unknown="ignore"
        ),
        ["category"]
    )
])


# =========================
# PIPELINE
# =========================

pipeline = Pipeline([
    (
        "preprocessor",
        preprocessor
    ),
    (
        "classifier",
        LogisticRegression(
            max_iter=1000
        )
    )
])


# =========================
# TRAIN / TEST SPLIT
# =========================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42
)


# =========================
# TRAIN MODEL
# =========================

pipeline.fit(
    X_train,
    y_train
)


# =========================
# PREDICTIONS
# =========================

predictions = pipeline.predict(
    X_test
)


# =========================
# EVALUATION
# =========================

print("\nClassification Report:\n")

print(
    classification_report(
        y_test,
        predictions
    )
)


# =========================
# SAVE MODEL
# =========================

joblib.dump(
    pipeline,
    "../models/severity_classifier.pkl"
)

print("\nModel saved successfully!")