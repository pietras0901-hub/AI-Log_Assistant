"""Modele danych (Pydantic) dla AI Log Assistant.

Kontrakt JSON jest zgodny z oczekiwaniami aplikacji Flutter:
pola w konwencji snake_case oraz pole `poziom_waznosci` o wartościach
INFO / WARNING / ERROR / CRITICAL.
"""

from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class PoziomWaznosci(str, Enum):
    """Poziom ważności wpisu w logu."""

    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class LogEntry(BaseModel):
    """Pojedynczy wpis logu systemowego wraz z diagnozą AI."""

    id: int = Field(..., description="Unikalny identyfikator wpisu")
    maszyna_nazwa: str = Field(..., description="Nazwa maszyny/serwera")
    opis_bledu: str = Field(..., description="Opis zdarzenia / błędu")
    rekomendacja_ai: str = Field(..., description="Diagnoza i rekomendacja AI")
    poziom_waznosci: PoziomWaznosci = Field(..., description="Poziom ważności")
    data_wpisu: datetime = Field(..., description="Data i czas wpisu (UTC)")

class NowyLog(BaseModel):
    """Zdarzenie wraz z diagnozą AI przesyłane przez workflow n8n.

    W odróżnieniu od LogEntry nie zawiera identyfikatora ani znacznika czasu —
    oba są nadawane po stronie backendu w momencie przyjęcia wpisu.
    """

    maszyna_nazwa: str = Field(..., description="Nazwa maszyny/serwera")
    opis_bledu: str = Field(..., description="Opis zdarzenia / błędu")
    rekomendacja_ai: str = Field(..., description="Diagnoza wygenerowana przez model")
    poziom_waznosci: PoziomWaznosci = Field(..., description="Poziom ważności")
    data_wpisu: datetime | None = Field(
        default=None,
        description="Znacznik czasu (UTC); domyślnie czas odebrania wpisu",
    )

