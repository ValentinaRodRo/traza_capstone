import geopandas as gpd
from shapely.geometry import Point

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

zones = gpd.read_file(
    BASE_DIR / "chia_zones.geojson"
)

print(zones.head())
print(zones.crs)


def classify_zone(latitude, longitude):

    point = Point(longitude, latitude)

    print("\nPOINT:")
    print(point)

    for _, zone in zones.iterrows():

        print("Checking zone:")
        print(zone["name"])

        if zone.geometry.contains(point):

            print("MATCH FOUND")

            return zone["name"]

    return "Desconocida"