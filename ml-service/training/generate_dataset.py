import random
import pandas as pd
import geopandas as gpd

from shapely.geometry import Point
from datetime import datetime, timedelta

# =========================
# LOAD REAL GEOJSON
# =========================

zones_gdf = gpd.read_file(
    "../app/chia_zones.geojson"
)

# =========================
# RANDOM POINT IN POLYGON
# =========================

def random_point_in_polygon(polygon):

    minx, miny, maxx, maxy = polygon.bounds

    while True:

        point = Point(
            random.uniform(minx, maxx),
            random.uniform(miny, maxy)
        )

        if polygon.contains(point):

            return point

# =========================
# LANGUAGE BLOCKS
# =========================

subjects = [
    "Un hombre",
    "Dos sujetos",
    "Un tipo",
    "Un grupo de personas",
    "Un ladrón"
]

victims = [
    "a un estudiante",
    "a una mujer",
    "a un ciudadano",
    "a varias personas"
]

weapons = [
    "con pistola",
    "con cuchillo",
    "armados",
    "con arma de fuego"
]

actions_critico = [
    "atracaron",
    "amenazaron",
    "golpearon",
    "agredieron violentamente"
]

actions_alto = [
    "robaron",
    "intimidaron",
    "persiguieron",
    "causaron daños"
]

actions_medio = [
    "alteraron el orden",
    "intentaron robar",
    "hicieron vandalismo"
]

actions_bajo = [
    "merodeaban",
    "parecían sospechosos",
    "hicieron ruido"
]

places = [
    "cerca del parque",
    "en vía pública",
    "en zona residencial",
    "frente a un comercio"
]

# =========================
# CATEGORY CONFIG
# =========================

categories = {

    "Hurto": {

        "critico": (
            actions_critico,
            True
        ),

        "alto": (
            actions_alto,
            True
        ),

        "medio": (
            actions_medio,
            False
        ),

        "bajo": (
            actions_bajo,
            False
        )
    },

    "Comportamiento sospechoso": {

        "critico": (
            actions_critico,
            True
        ),

        "alto": (
            actions_alto,
            False
        ),

        "medio": (
            actions_medio,
            False
        ),

        "bajo": (
            actions_bajo,
            False
        )
    },

    "Vandalismo": {

        "critico": (
            actions_critico,
            False
        ),

        "alto": (
            actions_alto,
            False
        ),

        "medio": (
            actions_medio,
            False
        ),

        "bajo": (
            actions_bajo,
            False
        )
    },

    "Otro": {

        "critico": (
            actions_critico,
            False
        ),

        "alto": (
            actions_alto,
            False
        ),

        "medio": (
            actions_medio,
            False
        ),

        "bajo": (
            actions_bajo,
            False
        )
    }
}

# =========================
# GENERATION
# =========================

rows = []

severity_levels = [
    "bajo",
    "medio",
    "alto",
    "critico"
]

for severity in severity_levels:

    for _ in range(2500):

        category = random.choice(
            list(categories.keys())
        )

        actions, use_weapon = categories[
            category
        ][severity]

        sentence = (
            f"{random.choice(subjects)} "
            f"{random.choice(actions)} "
        )

        if use_weapon:

            sentence += (
                f"{random.choice(weapons)} "
            )

        sentence += (
            f"{random.choice(victims)} "
            f"{random.choice(places)}"
        )

        # =========================
        # RANDOM REAL ZONE
        # =========================

        selected_zone = zones_gdf.sample(
            1
        ).iloc[0]

        zone_name = selected_zone[
            "name"
        ]

        polygon = selected_zone.geometry

        point = random_point_in_polygon(
            polygon
        )

        timestamp = (
            datetime.now()
            - timedelta(
                hours=random.randint(0, 720)
            )
        ).isoformat()

        rows.append({

            "category": category,

            "description": sentence,

            "severity": severity,

            "latitude": point.y,

            "longitude": point.x,

            "timestamp": timestamp,

            "zone": zone_name
        })

# =========================
# SAVE
# =========================

df = pd.DataFrame(rows)

df.to_csv(
    "synthetic_chia_reports.csv",
    index=False,
    encoding="utf-8"
)

print("Dataset generated!")
print(df.head())