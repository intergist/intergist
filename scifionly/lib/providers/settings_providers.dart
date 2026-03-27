import 'package:flutter_riverpod/flutter_riverpod.dart';

final spokenCuesEnabledProvider = StateProvider<bool>((ref) => true);

final hapticFeedbackEnabledProvider = StateProvider<bool>((ref) => true);

final reducedMotionProvider = StateProvider<bool>((ref) => false);

final highContrastProvider = StateProvider<bool>((ref) => false);

final minimalEffectsProvider = StateProvider<bool>((ref) => false);

final autoSaveRiffsProvider = StateProvider<bool>((ref) => true);

final transcriptPreviewProvider = StateProvider<bool>((ref) => true);

final syncSensitivityProvider = StateProvider<double>((ref) => 0.85);

final spokenCueVolumeProvider = StateProvider<double>((ref) => 1.0);

final maxCaptureDurationProvider = StateProvider<int>((ref) => 7000);

final diagnosticsEnabledProvider = StateProvider<bool>((ref) => false);
