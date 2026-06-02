import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/log_entry.dart';
import '../services/api_service.dart';

/// Ekran szczegółów pojedynczego wpisu logu.
///
/// Diagnoza AI prezentowana jest w wyróżnionej, zielonej karcie.
class LogDetailScreen extends StatefulWidget {
  final int logId;
  final ApiService apiService;

  /// Wstępne dane logu z listy — pozwalają wyświetlić treść natychmiast,
  /// zanim dotrze pełna odpowiedź z backendu.
  final LogEntry? wstepnyLog;

  const LogDetailScreen({
    super.key,
    required this.logId,
    required this.apiService,
    this.wstepnyLog,
  });

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  late Future<LogEntry> _przyszlyLog;

  @override
  void initState() {
    super.initState();
    _przyszlyLog = widget.apiService.pobierzSzczegoly(widget.logId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły logu')),
      body: FutureBuilder<LogEntry>(
        future: _przyszlyLog,
        builder: (context, snapshot) {
          final log = snapshot.data ?? widget.wstepnyLog;

          if (snapshot.connectionState == ConnectionState.waiting &&
              log == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && log == null) {
            return _BladSzczegolow(
              komunikat: snapshot.error.toString(),
              onRetry: () => setState(() {
                _przyszlyLog = widget.apiService.pobierzSzczegoly(widget.logId);
              }),
            );
          }
          // W najgorszym razie mamy dane wstępne z listy.
          return _TrescSzczegolow(log: log!);
        },
      ),
    );
  }
}

class _TrescSzczegolow extends StatelessWidget {
  final LogEntry log;

  const _TrescSzczegolow({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatDaty = DateFormat('dd.MM.yyyy HH:mm:ss');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Nagłówek z poziomem ważności.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: log.poziomWaznosci.kolor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: log.poziomWaznosci.kolor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(log.poziomWaznosci.ikona,
                  color: log.poziomWaznosci.kolor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.poziomWaznosci.etykieta,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: log.poziomWaznosci.kolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Wpis #${log.id}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _SekcjaInfo(
          ikona: Icons.dns_outlined,
          etykieta: 'Maszyna',
          wartosc: log.maszynaNazwa,
        ),
        _SekcjaInfo(
          ikona: Icons.schedule,
          etykieta: 'Data wpisu',
          wartosc: formatDaty.format(log.dataWpisu),
        ),
        const SizedBox(height: 8),

        // Opis błędu.
        Text('Opis błędu', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              log.opisBledu.isEmpty ? 'Brak opisu.' : log.opisBledu,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Wyróżniona zielona karta z diagnozą AI.
        _DiagnozaAI(rekomendacja: log.rekomendacjaAI),
      ],
    );
  }
}

/// Pojedynczy wiersz „etykieta + wartość” z ikoną.
class _SekcjaInfo extends StatelessWidget {
  final IconData ikona;
  final String etykieta;
  final String wartosc;

  const _SekcjaInfo({
    required this.ikona,
    required this.etykieta,
    required this.wartosc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikona, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text('$etykieta: ',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              wartosc.isEmpty ? '—' : wartosc,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// Zielona karta prezentująca diagnozę / rekomendację wygenerowaną przez AI.
class _DiagnozaAI extends StatelessWidget {
  final String rekomendacja;

  const _DiagnozaAI({required this.rekomendacja});

  static const Color _zielony = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: _zielony.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _zielony.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: _zielony),
                const SizedBox(width: 8),
                Text(
                  'Diagnoza AI',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _zielony,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rekomendacja.isEmpty
                  ? 'Brak rekomendacji AI dla tego wpisu.'
                  : rekomendacja,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BladSzczegolow extends StatelessWidget {
  final String komunikat;
  final VoidCallback onRetry;

  const _BladSzczegolow({required this.komunikat, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(komunikat, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}
