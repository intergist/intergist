// Poker Sharp — App Entry Point

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseService.database;

  runApp(
    const ProviderScope(
      child: PokerSharpApp(),
    ),
  );
}
