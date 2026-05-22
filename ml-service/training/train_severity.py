import random
import pandas as pd
import joblib
from sklearn.compose import ColumnTransformer
import spacy
import unicodedata
import re

from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import OneHotEncoder
from sklearn.svm import LinearSVC
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

# =========================
# LOAD SPANISH NLP
# =========================

nlp = spacy.load(
    "es_core_news_sm"
)

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
# NOISE / SLANG
# =========================

def add_noise(text):

    replacements = {

        "celular": [
            "celu",
            "telefono",
            "movil"
        ],

        "persona": [
            "sujeto",
            "tipo",
            "individuo",
            "man"
        ],

        "robo": [
            "hurto",
            "atraco"
        ],

        "bicicleta": [
            "bici"
        ],

        "parque": [
            "parquecito"
        ],

        "moto": [
            "motocicleta"
        ]
    }

    for word, options in replacements.items():

        if (
            word in text
            and random.random() < 0.35
        ):

            text = text.replace(
                word,
                random.choice(options)
            )

    return text

# =========================
# CLEAN SPANISH TEXT
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
    "synthetic_chia_reports.csv"
)

# =========================
# ADD MORE LANGUAGE VARIETY
# =========================

df["description"] = df[
    "description"
].apply(add_noise)

# =========================
# CLEAN CATEGORIES
# =========================

df["category"] = (
    df["category"]
    .astype(str)
    .str.lower()
    .str.strip()
)

# =========================
# CLEAN DESCRIPTIONS
# =========================

df["clean_description"] = df[
    "description"
].apply(clean_spanish_text)

# =========================
# DEBUG
# =========================

print("\nUnique categories:\n")

print(
    df["category"].unique()
)

# =========================
# FEATURES / TARGET
# =========================

X = df[[
    "clean_description",
    "category"
]]

y = df["severity"]

# =========================
# TRAIN / TEST SPLIT
# =========================

X_train, X_test, y_train, y_test = train_test_split(

    X,
    y,

    test_size=0.2,

    random_state=42,

    stratify=y
)

# =========================
# PIPELINE
# =========================
preprocessor = ColumnTransformer([
    (
        "text",
        TfidfVectorizer(
            ngram_range=(1, 2),
            min_df=2,
            max_df=0.95
        ),
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

pipeline = Pipeline([

    (
        "preprocessor",
        preprocessor
    ),

    (
        "classifier",

        LinearSVC(
            class_weight="balanced"
        )
    )
])

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