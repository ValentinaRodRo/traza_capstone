import requests

BACKEND_URL = "http://127.0.0.1:8000/reports"

TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyLCJlbWFpbCI6ImFkbWluQHRyYXphLmNvbSIsInJvbGUiOiJhdXRob3JpdHkiLCJleHAiOjE3Nzk0NTMzNTZ9.x--LxiDoD58qTtep4tPc14tb-GaNgzad3rB2r52y0VY"

def fetch_reports():

    headers = {
        "Authorization":
        f"Bearer {TOKEN}"
    }

    response = requests.get(
        BACKEND_URL,
        headers=headers
    )

    if response.status_code != 200:

        raise Exception(
            f"Failed to fetch reports "
            f"{response.text}"
        )

    return response.json()