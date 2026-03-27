/// Helpers for working with [ParticipationWindowModel].
///
/// Provides the [WindowState] enum and utility functions for determining
/// window state at a given playback position.
library;

import 'package:scifionly/models/participation_window_model.dart';

/// Visual / behavioural state of a participation window.
enum WindowState {
  /// The window is closed — no user participation allowed.
  closed,

  /// The window is about to open or close (yellow indicator, 1.5 s lead).
  warning,

  /// The window is open — user may participate (green indicator).
  open,
}

/// Default lead-in / lead-out duration for the warning state (ms).
const int kWindowWarningMs = 1500;

/// Determine the [WindowState] for [window] at [currentMs].
///
/// The warning state activates [kWindowWarningMs] before the open edge
/// and [kWindowWarningMs] before the close edge.
WindowState getWindowState(
  ParticipationWindowModel window,
  int currentMs,
) {
  final openMs = window.startMs;
  final closeMs = window.endMs;

  // Inside the open range.
  if (currentMs >= openMs && currentMs < closeMs) {
    // About to close?
    if (currentMs >= closeMs - kWindowWarningMs) {
      return WindowState.warning;
    }
    return WindowState.open;
  }

  // Lead-in warning before opening.
  if (currentMs >= openMs - kWindowWarningMs && currentMs < openMs) {
    return WindowState.warning;
  }

  return WindowState.closed;
}

/// Whether the given [window] allows participation at [currentMs].
bool isWindowOpen(ParticipationWindowModel window, int currentMs) {
  return currentMs >= window.startMs && currentMs < window.endMs;
}

/// Returns the window from [windows] that is open at [currentMs], or null.
ParticipationWindowModel? activeWindow(
  List<ParticipationWindowModel> windows,
  int currentMs,
) {
  for (final w in windows) {
    if (currentMs >= w.startMs && currentMs < w.endMs) {
      return w;
    }
  }
  return null;
}

/// Returns the next upcoming window after [currentMs], or null.
ParticipationWindowModel? nextWindow(
  List<ParticipationWindowModel> windows,
  int currentMs,
) {
  for (final w in windows) {
    if (w.startMs > currentMs) return w;
  }
  return null;
}

/// Calculate the remaining open time (ms) for a window at [currentMs].
/// Returns 0 if the window is not open.
int remainingOpenMs(ParticipationWindowModel window, int currentMs) {
  if (currentMs < window.startMs || currentMs >= window.endMs) return 0;
  return window.endMs - currentMs;
}
