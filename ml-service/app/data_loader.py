import requests

BACKEND_URL = "http://127.0.0.1:8000/reports"

def fetch_reports():
    response = requests.get(BACKEND_URL)

    if response.status_code != 200:
        raise Exception(f"Failed to fetch reports {response.text}")
    return response.json()