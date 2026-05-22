import os
import requests

from dotenv import load_dotenv

load_dotenv()

BACKEND_URL = os.getenv(
    "BACKEND_URL"
)

API_KEY = os.getenv(
    "ML_SERVICE_API_KEY"
)


def fetch_reports():

    headers = {
        "x-api-key": API_KEY
    }

    response = requests.get(
        BACKEND_URL,
        headers=headers,
        timeout=10
    )

    if response.status_code != 200:

        raise Exception(
            f"Failed to fetch reports: "
            f"{response.text}"
        )

    return response.json()