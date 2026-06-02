import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/log_entry.dart';

/// Wyjątek opisujący błąd komunikacji z API w przyjaznej dla UI formie.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Serwis odpowiedzialny za komunikację z backendem FastAPI.
///
/// Hermetyzuje budowanie żądań HTTP, parsowanie odpowiedzi oraz mapowanie
/// błędów sieciowych na czytelne komunikaty ([ApiException]).
class ApiService {
  /// Adres bazowy backendu.
  ///
  /// Uwaga: w emulatorze Androida `localhost` hosta to `10.0.2.2`.
  /// Wartość można nadpisać przy kompilacji:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8000`
  static const String _domyslnyBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  ApiService({
    String? baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  })  : baseUrl = baseUrl ?? _domyslnyBaseUrl,
        _client = client ?? http.Client();

  /// Pobiera listę logów. Opcjonalnie filtruje po poziomie ważności.
  Future<List<LogEntry>> pobierzLogi({PoziomWaznosci? poziom}) async {
    final queryParams = <String, String>{
      if (poziom != null) 'poziom_waznosci': poziom.etykieta,
    };
    final uri = Uri.parse('$baseUrl/logs').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final json = await _get(uri);
    if (json is! List) {
      throw const ApiException('Nieprawidłowy format odpowiedzi serwera.');
    }
    return json
        .whereType<Map<String, dynamic>>()
        .map(LogEntry.fromJson)
        .toList();
  }

  /// Pobiera szczegóły pojedynczego wpisu po jego identyfikatorze.
  Future<LogEntry> pobierzSzczegoly(int id) async {
    final uri = Uri.parse('$baseUrl/logs/$id');
    final json = await _get(uri);
    if (json is! Map<String, dynamic>) {
      throw const ApiException('Nieprawidłowy format odpowiedzi serwera.');
    }
    return LogEntry.fromJson(json);
  }

  /// Wykonuje żądanie GET i zwraca zdekodowane ciało odpowiedzi.
  ///
  /// Centralizuje obsługę błędów: timeouty, brak sieci, błędne kody HTTP
  /// oraz nieparsowalny JSON są tłumaczone na [ApiException].
  Future<dynamic> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(utf8.decode(response.bodyBytes));
      }

      throw ApiException(
        _komunikatDlaKodu(response.statusCode),
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'Brak połączenia z serwerem. Sprawdź sieć i adres API.',
      );
    } on TimeoutException {
      throw const ApiException('Przekroczono czas oczekiwania na odpowiedź.');
    } on FormatException {
      throw const ApiException('Otrzymano nieprawidłowe dane z serwera.');
    } catch (e) {
      throw ApiException('Nieoczekiwany błąd: $e');
    }
  }

  String _komunikatDlaKodu(int kod) {
    if (kod == 404) return 'Nie znaleziono żądanego zasobu (404).';
    if (kod == 401 || kod == 403) return 'Brak autoryzacji ($kod).';
    if (kod >= 500) return 'Błąd serwera ($kod). Spróbuj ponownie później.';
    return 'Żądanie zakończone błędem (kod $kod).';
  }

  /// Zwalnia zasoby klienta HTTP.
  void dispose() => _client.close();
}
