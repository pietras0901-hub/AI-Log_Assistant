"""AI Log Assistant — backend FastAPI.

Udostępnia endpointy konsumowane przez aplikację Flutter:
    GET /logs               — lista logów (opcjonalny filtr poziomu)
    GET /logs/{id}          — szczegóły pojedynczego wpisu

Uruchomienie (z katalogu backend/):
    uvicorn main:app --reload --host 0.0.0.0 --port 8000

Dokumentacja interaktywna: http://localhost:8000/docs
"""

from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from models import LogEntry, NowyLog, PoziomWaznosci
from sample_data import PRZYKLADOWE_LOGI

# Rejestr zdarzeń w pamięci procesu. Startuje od danych przykładowych,
# a wpisy przychodzące z workflow n8n są do niego dopisywane.
LOGI: list[LogEntry] = list(PRZYKLADOWE_LOGI)

app = FastAPI(
    title="AI Log Assistant API",
    description="Backend do monitorowania logów systemowych z analizą AI "
    "(CyberTech Solutions).",
    version="1.0.0",
)

# CORS — pozwala na połączenia z aplikacji mobilnej / webowej w czasie dev.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", tags=["meta"])
def root() -> dict:
    """Prosty health-check oraz spis dostępnych endpointów."""
    return {
        "service": "AI Log Assistant API",
        "status": "ok",
        "endpoints": ["/logs", "/logs/{id}", "/docs"],
    }


@app.get("/logs", response_model=list[LogEntry], tags=["logs"])
def lista_logow(
    poziom_waznosci: PoziomWaznosci | None = Query(
        default=None,
        description="Opcjonalny filtr poziomu ważności.",
    ),
) -> list[LogEntry]:
    """Zwraca listę logów, opcjonalnie przefiltrowaną po poziomie ważności.

    Wyniki są posortowane malejąco po dacie wpisu (najnowsze na górze).
    """
    logi = LOGI
    if poziom_waznosci is not None:
        logi = [log for log in logi if log.poziom_waznosci == poziom_waznosci]
    return sorted(logi, key=lambda log: log.data_wpisu, reverse=True)


@app.get("/logs/{log_id}", response_model=LogEntry, tags=["logs"])
def szczegoly_logu(log_id: int) -> LogEntry:
    """Zwraca szczegóły pojedynczego wpisu lub 404, gdy nie istnieje."""
    for log in LOGI:
        if log.id == log_id:
            return log
    raise HTTPException(
        status_code=404,
        detail=f"Log o id={log_id} nie został znaleziony.",
    )

@app.post("/logs", response_model=LogEntry, status_code=201, tags=["logs"])
def dodaj_log(nowy: NowyLog) -> LogEntry:
    """Przyjmuje zdarzenie wraz z diagnozą AI przesłane przez workflow n8n.

    Identyfikator nadawany jest automatycznie, a brak znacznika czasu
    oznacza chwilę przyjęcia wpisu przez backend.
    """
    wpis = LogEntry(
        id=max((log.id for log in LOGI), default=0) + 1,
        maszyna_nazwa=nowy.maszyna_nazwa,
        opis_bledu=nowy.opis_bledu,
        rekomendacja_ai=nowy.rekomendacja_ai,
        poziom_waznosci=nowy.poziom_waznosci,
        data_wpisu=nowy.data_wpisu or datetime.now(timezone.utc),
    )
    LOGI.append(wpis)
    return wpis
