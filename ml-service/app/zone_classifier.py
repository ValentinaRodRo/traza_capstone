import logging
import geopandas as gpd
from shapely.geometry import Point
from pathlib import Path

logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parent

zones = gpd.read_file(BASE_DIR / "chia_zones.geojson")

def classify_zone(latitude, longitude):
    point = Point(longitude, latitude)
    for _, zone in zones.iterrows():
        if zone.geometry.contains(point):
            logger.debug("Zona encontrada: %s para punto %s", zone["name"], point)
            return zone["name"]
    return "Desconocida"