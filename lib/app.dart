import 'package:flutter/material.dart';

/// Root application widget.
///
/// GoRouter and theming will be configured in Phase 06+.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('MemoCare'),
        ),
      ),
    );
  }
}
