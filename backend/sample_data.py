"""Przykładowe dane logów dla środowiska deweloperskiego.

Dane są w pamięci — w realnym wdrożeniu zostałyby zastąpione bazą danych.
Daty zapisane są w UTC (sufiks Z po stronie JSON).
"""

from datetime import datetime, timezone

from models import LogEntry, PoziomWaznosci


def _dt(year, month, day, hour, minute) -> datetime:
    return datetime(year, month, day, hour, minute, tzinfo=timezone.utc)


PRZYKLADOWE_LOGI: list[LogEntry] = [
    LogEntry(
        id=1,
        maszyna_nazwa="srv-prod-db-01",
        opis_bledu="Połączenie z bazą danych PostgreSQL zostało zerwane "
        "(connection pool exhausted).",
        rekomendacja_ai="Pula połączeń osiągnęła limit. Zwiększ "
        "max_connections w postgresql.conf oraz skonfiguruj pgBouncer w "
        "trybie transaction pooling. Sprawdź też zapytania bez COMMIT, "
        "które mogą blokować połączenia.",
        poziom_waznosci=PoziomWaznosci.CRITICAL,
        data_wpisu=_dt(2026, 5, 30, 8, 12),
    ),
    LogEntry(
        id=2,
        maszyna_nazwa="srv-prod-api-02",
        opis_bledu="Wysokie zużycie pamięci RAM (94%) przez proces uvicorn.",
        rekomendacja_ai="Prawdopodobny wyciek pamięci w warstwie aplikacji. "
        "Przeanalizuj obiekty trzymane w cache bez TTL. Rozważ restart "
        "rolling-update oraz dodanie limitu pamięci w konfiguracji "
        "kontenera (memory limit).",
        poziom_waznosci=PoziomWaznosci.ERROR,
        data_wpisu=_dt(2026, 5, 30, 7, 45),
    ),
    LogEntry(
        id=3,
        maszyna_nazwa="srv-prod-web-01",
        opis_bledu="Certyfikat SSL wygaśnie za 7 dni.",
        rekomendacja_ai="Odnów certyfikat przed wygaśnięciem. Jeśli używasz "
        "Let's Encrypt, zweryfikuj działanie automatycznego odnawiania "
        "(certbot renew --dry-run) oraz cron/systemd timer.",
        poziom_waznosci=PoziomWaznosci.WARNING,
        data_wpisu=_dt(2026, 5, 29, 22, 30),
    ),
    LogEntry(
        id=4,
        maszyna_nazwa="srv-prod-api-01",
        opis_bledu="Wdrożenie wersji v2.4.1 zakończone pomyślnie.",
        rekomendacja_ai="Brak wymaganych działań. Wdrożenie przebiegło bez "
        "błędów; metryki w normie. Monitoruj wskaźnik błędów 5xx przez "
        "kolejną godzinę.",
        poziom_waznosci=PoziomWaznosci.INFO,
        data_wpisu=_dt(2026, 5, 29, 18, 5),
    ),
    LogEntry(
        id=5,
        maszyna_nazwa="srv-prod-cache-01",
        opis_bledu="Redis: przekroczono limit maxmemory, klucze są usuwane "
        "(evicted_keys rośnie).",
        rekomendacja_ai="Polityka eviction usuwa dane. Zwiększ maxmemory lub "
        "zmień politykę na allkeys-lru, jeśli cache jest ulotny. Zweryfikuj, "
        "czy nie są cache'owane zbyt duże obiekty.",
        poziom_waznosci=PoziomWaznosci.ERROR,
        data_wpisu=_dt(2026, 5, 29, 14, 50),
    ),
    LogEntry(
        id=6,
        maszyna_nazwa="srv-prod-db-02",
        opis_bledu="Wykryto wiele nieudanych prób logowania SSH z jednego IP "
        "(możliwy atak brute-force).",
        rekomendacja_ai="Zablokuj adres IP na firewallu i włącz fail2ban. "
        "Wyłącz logowanie hasłem na rzecz kluczy SSH. Rozważ ograniczenie "
        "dostępu SSH do sieci VPN.",
        poziom_waznosci=PoziomWaznosci.CRITICAL,
        data_wpisu=_dt(2026, 5, 29, 3, 17),
    ),
    LogEntry(
        id=7,
        maszyna_nazwa="srv-prod-worker-03",
        opis_bledu="Kolejka zadań Celery rośnie — opóźnienie przetwarzania "
        "ponad 5 minut.",
        rekomendacja_ai="Liczba workerów jest niewystarczająca względem "
        "napływu zadań. Zwiększ liczbę workerów lub concurrency. Sprawdź "
        "zadania zawieszone (long-running) blokujące pulę.",
        poziom_waznosci=PoziomWaznosci.WARNING,
        data_wpisu=_dt(2026, 5, 28, 19, 40),
    ),
    LogEntry(
        id=8,
        maszyna_nazwa="srv-prod-storage-01",
        opis_bledu="Zajętość dysku /var osiągnęła 88%.",
        rekomendacja_ai="Rotuj i kompresuj logi (logrotate), wyczyść stare "
        "artefakty i pliki tymczasowe. Skonfiguruj alert przy 80% oraz "
        "automatyczne czyszczenie /tmp.",
        poziom_waznosci=PoziomWaznosci.WARNING,
        data_wpisu=_dt(2026, 5, 28, 11, 5),
    ),
]
