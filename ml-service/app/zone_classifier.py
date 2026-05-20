import geopandas as gpd
from shapely.geometry import Point

zones = gpd.read_file(
    "app/zones/chia_zones.geojson"
)


def classify_zone(latitude, longitude):

    point = Point(
        longitude,
        latitude
    )

    for _, zone in zones.iterrows():

        if zone.geometry.contains(point):

            return zone["name"]

    return "Desconocida"