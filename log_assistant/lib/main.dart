import 'package:flutter/material.dart';

import 'screens/log_list_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const LogAssistantApp());
}

/// Punkt wejścia aplikacji AI Log Assistant (CyberTech Solutions).
class LogAssistantApp extends StatefulWidget {
  const LogAssistantApp({super.key});

  @override
  State<LogAssistantApp> createState() => _LogAssistantAppState();
}

class _LogAssistantAppState extends State<LogAssistantApp> {
  // Pojedyncza instancja serwisu współdzielona między ekranami.
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Log Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
      ),
      home: LogListScreen(apiService: _apiService),
    );
  }
}
