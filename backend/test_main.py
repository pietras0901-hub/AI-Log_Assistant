"""Testy jednostkowe backendu AI Log Assistant.

Wykorzystują klasę TestClient z FastAPI, która wykonuje żądania HTTP
do aplikacji bez uruchamiania serwera Uvicorn.

Uruchomienie (z katalogu backend/):
    pytest -v
"""

import pytest
from fastapi.testclient import TestClient

import main
from sample_data import PRZYKLADOWE_LOGI

client = TestClient(main.app)


@pytest.fixture(autouse=True)
def czysty_rejestr():
    """Przywraca rejestr do stanu początkowego przed i po każdym teście.

    Rejestr LOGI jest wspólny dla całej aplikacji, więc test dodający wpis
    wpływałby na kolejne testy.
    """
    main.LOGI[:] = list(PRZYKLADOWE_LOGI)
    yield
    main.LOGI[:] = list(PRZYKLADOWE_LOGI)


def test_health_check_zwraca_status_ok():
    odpowiedz = client.get("/")

    assert odpowiedz.status_code == 200
    assert odpowiedz.json()["status"] == "ok"


def test_lista_zwraca_wszystkie_wpisy():
    odpowiedz = client.get("/logs")

    assert odpowiedz.status_code == 200
    assert len(odpowiedz.json()) == len(PRZYKLADOWE_LOGI)


def test_lista_jest_posortowana_malejaco_po_dacie():
    daty = [wpis["data_wpisu"] for wpis in client.get("/logs").json()]

    assert daty == sorted(daty, reverse=True)


def test_filtr_zwraca_wylacznie_wskazany_poziom():
    odpowiedz = client.get("/logs", params={"poziom_waznosci": "CRITICAL"})

    assert odpowiedz.status_code == 200
    wpisy = odpowiedz.json()
    assert wpisy, "Dane przykładowe powinny zawierać wpisy CRITICAL."
    assert all(wpis["poziom_waznosci"] == "CRITICAL" for wpis in wpisy)


def test_filtr_odrzuca_nieznany_poziom_waznosci():
    odpowiedz = client.get("/logs", params={"poziom_waznosci": "FATAL"})

    assert odpowiedz.status_code == 422


def test_szczegoly_istniejacego_wpisu():
    odpowiedz = client.get("/logs/1")

    assert odpowiedz.status_code == 200
    assert odpowiedz.json()["id"] == 1


def test_szczegoly_nieistniejacego_wpisu_zwracaja_404():
    odpowiedz = client.get("/logs/9999")

    assert odpowiedz.status_code == 404
    assert "9999" in odpowiedz.json()["detail"]


def test_dodanie_wpisu_przez_workflow_n8n():
    zdarzenie = {
        "maszyna_nazwa": "srv-test-01",
        "opis_bledu": "Przekroczono czas oczekiwania na połączenie z bazą danych.",
        "rekomendacja_ai": "Sprawdź pulę połączeń i obciążenie serwera bazy danych.",
        "poziom_waznosci": "ERROR",
    }

    odpowiedz = client.post("/logs", json=zdarzenie)

    assert odpowiedz.status_code == 201
    wpis = odpowiedz.json()
    assert wpis["id"] == max(log.id for log in PRZYKLADOWE_LOGI) + 1
    assert wpis["maszyna_nazwa"] == "srv-test-01"
    # Znacznik czasu nadawany jest po stronie backendu, gdy nie przyszedł w żądaniu.
    assert wpis["data_wpisu"] is not None


def test_dodany_wpis_jest_widoczny_na_liscie():
    zdarzenie = {
        "maszyna_nazwa": "srv-test-02",
        "opis_bledu": "Przepełnienie pamięci podręcznej.",
        "rekomendacja_ai": "Zwiększ limit pamięci lub skróć czas życia kluczy.",
        "poziom_waznosci": "CRITICAL",
    }
    nowy_id = client.post("/logs", json=zdarzenie).json()["id"]

    identyfikatory = [wpis["id"] for wpis in client.get("/logs").json()]

    assert nowy_id in identyfikatory


def test_dodanie_wpisu_bez_wymaganego_pola_zwraca_422():
    odpowiedz = client.post("/logs", json={"maszyna_nazwa": "srv-test-03"})

    assert odpowiedz.status_code == 422
