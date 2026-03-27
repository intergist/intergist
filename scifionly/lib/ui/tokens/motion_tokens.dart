import 'package:flutter/animation.dart';

/// Motion / animation tokens for the SciFiOnly design system.
///
/// Durations use a logarithmic ramp that feels snappy for micro-interactions
/// and smooth for full-panel transitions. Curves are tuned for a sci-fi
/// aesthetic — slightly overshooting on enter, quick-decel on exit.
abstract final class AppMotion {
  // ── Durations ─────────────────────────────────────────────────────────

  /// 100 ms — instant feedback (button press, icon swap).
  static const Duration instant = Duration(milliseconds: 100);

  /// 150 ms — fast micro-interactions (chip toggle, ripple).
  static const Duration fast = Duration(milliseconds: 150);

  /// 200 ms — standard transitions (opacity fade, color change).
  static const Duration standard = Duration(milliseconds: 200);

  /// 300 ms — medium transitions (panel slide, card expand).
  static const Duration medium = Duration(milliseconds: 300);

  /// 400 ms — deliberate transitions (modal entry, page cross-fade).
  static const Duration slow = Duration(milliseconds: 400);

  /// 600 ms — dramatic transitions (full-screen hero, onboarding).
  static const Duration dramatic = Duration(milliseconds: 600);

  /// 1000 ms — ambient / looping effects (glow pulse, scan line).
  static const Duration ambient = Duration(milliseconds: 1000);

  // ── Curves ────────────────────────────────────────────────────────────

  /// Standard ease-in-out for most transitions.
  static const Curve defaultCurve = Curves.easeInOutCubic;

  /// Enter / appear — starts slow, accelerates, slight overshoot.
  static const Curve enter = Curves.easeOutBack;

  /// Exit / disappear — quick deceleration.
  static const Curve exit = Curves.easeInCubic;

  /// Shared-element / hero transitions.
  static const Curve hero = Curves.fastOutSlowIn;

  /// Bounce for playful confirmations.
  static const Curve bounce = Curves.bounceOut;

  /// Linear for looping ambient effects.
  static const Curve linear = Curves.linear;
}
