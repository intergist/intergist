import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/app/app.dart';
import 'package:scifionly/app/bootstrap/bootstrap.dart';

void main() async {
  await bootstrap();

  runApp(
    const ProviderScope(
      child: SciFiOnlyApp(),
    ),
  );
}
