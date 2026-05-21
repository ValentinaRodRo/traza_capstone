from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


# =========================
# TEST HOME
# =========================

def test_home():

    response = client.get("/")

    assert response.status_code == 200

    assert response.json() == {
        "message": "TRAZA backend funcionando"
    }


# =========================
# TEST LOGIN
# =========================

def test_login():

    response = client.post(
        "/auth/login",
        json={
            "email": "admin@traza.com",
            "password": "123456"
        }
    )

    assert response.status_code == 200

    data = response.json()

    assert "access_token" in data


# =========================
# TEST NOTIFICATIONS
# =========================

def test_get_notifications():

    login = client.post(
        "/auth/login",
        json={
            "email": "vale@prueba.com",
            "password": "123456"
        }
    )

    token = login.json()["access_token"]

    response = client.get(
        "/notifications/",
        headers={
            "Authorization": f"Bearer {token}"
        }
    )

    assert response.status_code == 200


# =========================
# TEST CREATE REPORT
# =========================

def test_create_report():

    # Login ciudadano
    login = client.post(
        "/auth/login",
        json={
            "email": "vale@prueba.com",
            "password": "123456"
        }
    )

    token = login.json()["access_token"]

    # Crear reporte
    response = client.post(
        "/reports/",
        headers={
            "Authorization": f"Bearer {token}"
        },
        json={
            "incident_type": "Robo",
            "description": "Intento de robo en parque",
            "latitude": 4.8600,
            "longitude": -74.0320,
            "anonymous": True
        }
    )

    assert response.status_code == 200

    data = response.json()

    assert "tracking_code" in data
    assert data["incident_type"] == "Robo"


# =========================
# TEST GET MY REPORTS
# =========================

def test_get_my_reports():

    login = client.post(
        "/auth/login",
        json={
            "email": "vale@prueba.com",
            "password": "123456"
        }
    )

    token = login.json()["access_token"]

    response = client.get(
        "/reports/my-reports",
        headers={
            "Authorization": f"Bearer {token}"
        }
    )

    assert response.status_code == 200

    data = response.json()

    assert isinstance(data, list)


# =========================
# TEST UPDATE REPORT STATUS
# =========================

def test_update_report_status():

    # Login admin
    login = client.post(
        "/auth/login",
        json={
            "email": "admin@traza.com",
            "password": "123456"
        }
    )

    token = login.json()["access_token"]

    response = client.put(
        "/reports/CHI-2026-0013/status",
        headers={
            "Authorization": f"Bearer {token}"
        },
        json={
            "status": "EN_REVISION",
            "comment": "La autoridad está revisando el caso"
        }
    )

    print(response.json())

    assert response.status_code == 200

# =========================
# TEST REPORT HISTORY
# =========================

def test_report_history():

    login = client.post(
        "/auth/login",
        json={
            "email": "vale@prueba.com",
            "password": "123456"
        }
    )

    token = login.json()["access_token"]

    response = client.get(
        "/reports/CHI-2026-0013/history",
        headers={
            "Authorization": f"Bearer {token}"
        }
    )

    assert response.status_code == 200