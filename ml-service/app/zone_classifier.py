import geopandas as gpd
from shapely.geometry import Point

zones = gpd.read_file(
    "chia_zones.geojson"
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