import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:log_assistant/models/log_entry.dart';
import 'package:log_assistant/widgets/log_card.dart';

void main() {
  testWidgets('LogCard wyświetla opis błędu i poziom ważności',
      (WidgetTester tester) async {
    final log = LogEntry(
      id: 1,
      maszynaNazwa: 'srv-prod-01',
      opisBledu: 'Połączenie z bazą danych zostało zerwane.',
      rekomendacjaAI: 'Sprawdź pulę połączeń.',
      poziomWaznosci: PoziomWaznosci.critical,
      dataWpisu: DateTime(2026, 5, 30, 12, 0),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: LogCard(log: log))),
    );

    expect(find.text('CRITICAL'), findsOneWidget);
    expect(find.text('srv-prod-01'), findsOneWidget);
    expect(
      find.text('Połączenie z bazą danych zostało zerwane.'),
      findsOneWidget,
    );
  });
}
