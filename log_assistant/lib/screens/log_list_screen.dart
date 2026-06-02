import 'package:flutter/material.dart';

import '../models/log_entry.dart';
import '../services/api_service.dart';
import '../widgets/log_card.dart';
import 'log_detail_screen.dart';

/// Ekran główny — lista logów z filtrowaniem i pull-to-refresh.
class LogListScreen extends StatefulWidget {
  final ApiService apiService;

  const LogListScreen({super.key, required this.apiService});

  @override
  State<LogListScreen> createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  late Future<List<LogEntry>> _przyszleLogi;

  /// Aktywny filtr poziomu ważności (`null` = wszystkie).
  PoziomWaznosci? _filtr;

  @override
  void initState() {
    super.initState();
    _zaladuj();
  }

  void _zaladuj() {
    _przyszleLogi = widget.apiService.pobierzLogi(poziom: _filtr);
  }

  Future<void> _odswiez() async {
    setState(_zaladuj);
    // Czekamy na zakończenie, aby wskaźnik pull-to-refresh zniknął w odpowiednim
    // momencie. Błędy są obsługiwane w buildzie przez FutureBuilder.
    await _przyszleLogi.catchError((_) => <LogEntry>[]);
  }

  void _ustawFiltr(PoziomWaznosci? poziom) {
    setState(() {
      _filtr = poziom;
      _zaladuj();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Log Assistant'),
        actions: [
          PopupMenuButton<PoziomWaznosci?>(
            tooltip: 'Filtruj po poziomie',
            icon: Badge(
              isLabelVisible: _filtr != null,
              child: const Icon(Icons.filter_list),
            ),
            onSelected: _ustawFiltr,
            itemBuilder: (context) => [
              const PopupMenuItem<PoziomWaznosci?>(
                value: null,
                child: Text('Wszystkie'),
              ),
              const PopupMenuDivider(),
              ...PoziomWaznosci.values.map(
                (p) => PopupMenuItem<PoziomWaznosci?>(
                  value: p,
                  child: Row(
                    children: [
                      Icon(p.ikona, color: p.kolor, size: 18),
                      const SizedBox(width: 8),
                      Text(p.etykieta),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filtr != null) _AktywnyFiltrPasek(poziom: _filtr!, onClear: () => _ustawFiltr(null)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _odswiez,
              child: FutureBuilder<List<LogEntry>>(
                future: _przyszleLogi,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _StanBledu(
                      komunikat: snapshot.error.toString(),
                      onRetry: _odswiez,
                    );
                  }
                  final logi = snapshot.data ?? const [];
                  if (logi.isEmpty) {
                    return const _StanPusty();
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: logi.length,
                    itemBuilder: (context, index) {
                      final log = logi[index];
                      return LogCard(
                        log: log,
                        onTap: () => _otworzSzczegoly(log),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _otworzSzczegoly(LogEntry log) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LogDetailScreen(
          logId: log.id,
          apiService: widget.apiService,
          wstepnyLog: log,
        ),
      ),
    );
  }
}

/// Pasek pokazujący aktywny filtr z możliwością jego wyczyszczenia.
class _AktywnyFiltrPasek extends StatelessWidget {
  final PoziomWaznosci poziom;
  final VoidCallback onClear;

  const _AktywnyFiltrPasek({required this.poziom, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: poziom.kolor.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(poziom.ikona, size: 16, color: poziom.kolor),
          const SizedBox(width: 8),
          Text('Filtr: ${poziom.etykieta}'),
          const Spacer(),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Wyczyść'),
          ),
        ],
      ),
    );
  }
}

/// Widok prezentowany, gdy wystąpił błąd pobierania danych.
class _StanBledu extends StatelessWidget {
  final String komunikat;
  final Future<void> Function() onRetry;

  const _StanBledu({required this.komunikat, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // ListView zapewnia działanie pull-to-refresh nawet w stanie błędu.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
          child: Column(
            children: [
              Icon(Icons.cloud_off,
                  size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Nie udało się pobrać logów',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                komunikat,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widok prezentowany, gdy lista logów jest pusta.
class _StanPusty extends StatelessWidget {
  const _StanPusty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 100, 32, 32),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Brak logów do wyświetlenia',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pociągnij w dół, aby odświeżyć.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
