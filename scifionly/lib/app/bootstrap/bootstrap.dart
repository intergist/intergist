import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scifionly/utils/logger.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0F14),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  AppLogger.info(LogTag.ui, 'Bootstrap complete');
}
