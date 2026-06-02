# AI Log Assistant — Backend (FastAPI)

Backend dla aplikacji mobilnej **AI Log Assistant** (CyberTech Solutions).
Udostępnia logi systemowe wraz z diagnozą AI dla klienta Flutter.

## Wymagania

- Python 3.11+ (testowane na 3.13)

## Uruchomienie

```powershell
cd backend

# 1. Środowisko wirtualne
python -m venv .venv
.\.venv\Scripts\Activate.ps1        # Windows PowerShell
# source .venv/bin/activate         # Linux / macOS

# 2. Zależności
pip install -r requirements.txt

# 3. Start serwera
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- Dokumentacja interaktywna (Swagger): http://localhost:8000/docs
- `--host 0.0.0.0` jest istotne, aby serwer był dostępny dla emulatora/urządzenia.

## Endpointy

| Metoda | Ścieżka | Opis |
|---|---|---|
| `GET` | `/` | Health-check |
| `GET` | `/logs` | Lista logów. Filtr: `?poziom_waznosci=CRITICAL` |
| `GET` | `/logs/{id}` | Szczegóły wpisu (404, gdy brak) |

Wartości `poziom_waznosci`: `INFO`, `WARNING`, `ERROR`, `CRITICAL`.
Lista jest sortowana malejąco po `data_wpisu` (najnowsze na górze).

### Przykładowa odpowiedź

```json
[
  {
    "id": 1,
    "maszyna_nazwa": "srv-prod-db-01",
    "opis_bledu": "Połączenie z bazą danych PostgreSQL zostało zerwane.",
    "rekomendacja_ai": "Pula połączeń osiągnęła limit. Zwiększ max_connections...",
    "poziom_waznosci": "CRITICAL",
    "data_wpisu": "2026-05-30T08:12:00Z"
  }
]
```

## Połączenie z aplikacją Flutter

Domyślny adres w aplikacji: `http://10.0.2.2:8000` (localhost hosta w emulatorze Androida).

| Środowisko | Adres API |
|---|---|
| Emulator Android | `http://10.0.2.2:8000` (domyślny) |
| Symulator iOS | `http://localhost:8000` |
| Fizyczne urządzenie | `http://<IP-komputera>:8000` (ta sama sieć Wi-Fi) |

Nadpisanie adresu bez zmiany kodu:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8000
```

## Struktura

```
backend/
├── main.py            # Aplikacja FastAPI i endpointy
├── models.py          # Modele Pydantic (LogEntry, PoziomWaznosci)
├── sample_data.py     # Przykładowe dane (8 wpisów, w pamięci)
├── requirements.txt   # Zależności
└── README.md
```

> Dane przechowywane są w pamięci (`sample_data.py`). W docelowym wdrożeniu
> należałoby podpiąć bazę danych (np. PostgreSQL + SQLAlchemy).
