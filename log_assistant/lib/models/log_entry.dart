import 'package:flutter/material.dart';

/// Poziom ważności wpisu w logu.
///
/// Kolejność enum odpowiada rosnącej istotności — dzięki temu można
/// porównywać i sortować poziomy (np. `info.index < critical.index`).
enum PoziomWaznosci {
  info,
  warning,
  error,
  critical;

  /// Etykieta wyświetlana w interfejsie użytkownika.
  String get etykieta {
    switch (this) {
      case PoziomWaznosci.info:
        return 'INFO';
      case PoziomWaznosci.warning:
        return 'WARNING';
      case PoziomWaznosci.error:
        return 'ERROR';
      case PoziomWaznosci.critical:
        return 'CRITICAL';
    }
  }

  /// Kolor przypisany do poziomu ważności.
  ///
  /// CRITICAL = czerwony, ERROR = pomarańczowy — zgodnie z wymaganiami.
  Color get kolor {
    switch (this) {
      case PoziomWaznosci.info:
        return const Color(0xFF1976D2); // niebieski
      case PoziomWaznosci.warning:
        return const Color(0xFFFBC02D); // żółty
      case PoziomWaznosci.error:
        return const Color(0xFFF57C00); // pomarańczowy
      case PoziomWaznosci.critical:
        return const Color(0xFFD32F2F); // czerwony
    }
  }

  /// Ikona reprezentująca poziom ważności.
  IconData get ikona {
    switch (this) {
      case PoziomWaznosci.info:
        return Icons.info_outline;
      case PoziomWaznosci.warning:
        return Icons.warning_amber_outlined;
      case PoziomWaznosci.error:
        return Icons.error_outline;
      case PoziomWaznosci.critical:
        return Icons.dangerous_outlined;
    }
  }

  /// Tworzy [PoziomWaznosci] z tekstu zwróconego przez backend.
  ///
  /// Odporne na wielkość liter i nieznane wartości (domyślnie [info]).
  static PoziomWaznosci fromString(String? wartosc) {
    switch (wartosc?.toUpperCase().trim()) {
      case 'CRITICAL':
        return PoziomWaznosci.critical;
      case 'ERROR':
        return PoziomWaznosci.error;
      case 'WARNING':
        return PoziomWaznosci.warning;
      case 'INFO':
      default:
        return PoziomWaznosci.info;
    }
  }
}

/// Pojedynczy wpis logu systemowego wraz z diagnozą AI.
@immutable
class LogEntry {
  final int id;
  final String maszynaNazwa;
  final String opisBledu;
  final String rekomendacjaAI;
  final PoziomWaznosci poziomWaznosci;
  final DateTime dataWpisu;

  const LogEntry({
    required this.id,
    required this.maszynaNazwa,
    required this.opisBledu,
    required this.rekomendacjaAI,
    required this.poziomWaznosci,
    required this.dataWpisu,
  });

  /// Deserializacja z odpowiedzi JSON backendu FastAPI.
  ///
  /// Obsługuje zarówno `snake_case` (typowe dla FastAPI/Pythona), jak i
  /// nazwy zgodne z polami modelu — dzięki temu kontrakt API jest elastyczny.
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      maszynaNazwa:
          (json['maszyna_nazwa'] ?? json['maszynaNazwa'] ?? '') as String,
      opisBledu: (json['opis_bledu'] ?? json['opisBledu'] ?? '') as String,
      rekomendacjaAI: (json['rekomendacja_ai'] ??
          json['rekomendacjaAI'] ??
          json['rekomendacja'] ??
          '') as String,
      poziomWaznosci: PoziomWaznosci.fromString(
        (json['poziom_waznosci'] ?? json['poziomWaznosci']) as String?,
      ),
      dataWpisu: DateTime.tryParse(
            (json['data_wpisu'] ?? json['dataWpisu'] ?? '') as String,
          )?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Serializacja do JSON (np. przy wysyłaniu wpisu na backend).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maszyna_nazwa': maszynaNazwa,
      'opis_bledu': opisBledu,
      'rekomendacja_ai': rekomendacjaAI,
      'poziom_waznosci': poziomWaznosci.etykieta,
      'data_wpisu': dataWpisu.toUtc().toIso8601String(),
    };
  }
}
