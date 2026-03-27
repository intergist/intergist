import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/features/sync/sync_state.dart';

final syncStateProvider = StateProvider<SyncStateData>((ref) {
  return SyncStateData(
    state: SyncState.unlocked,
    confidence: 0.0,
    estimatedPositionMs: 0,
    driftMs: 0,
    lastUpdateTime: DateTime.now(),
  );
});

final syncConfidenceProvider = Provider<double>((ref) {
  return ref.watch(syncStateProvider).confidence;
});

final isSyncLockedProvider = Provider<bool>((ref) {
  return ref.watch(syncStateProvider).state == SyncState.locked;
});
