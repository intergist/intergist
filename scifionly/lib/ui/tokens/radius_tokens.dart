import 'package:flutter/painting.dart';

/// Corner-radius tokens for the SciFiOnly design system.
///
/// Provides both raw [Radius] values and pre-built [BorderRadius] instances
/// for convenience.
abstract final class AppRadius {
  // ── Radius values ─────────────────────────────────────────────────────

  /// 0 px – sharp corners (panels, data tables).
  static const Radius none = Radius.circular(0);

  /// 4 px – subtle rounding (chips, small controls).
  static const Radius xs = Radius.circular(4);

  /// 8 px – cards, input fields.
  static const Radius sm = Radius.circular(8);

  /// 12 px – modals, prominent cards.
  static const Radius md = Radius.circular(12);

  /// 16 px – floating action elements, large cards.
  static const Radius lg = Radius.circular(16);

  /// 20 px – hero cards, onboarding panels.
  static const Radius xl = Radius.circular(20);

  /// 24 px – extra large containers.
  static const Radius xxl = Radius.circular(24);

  /// 9999 px – full / pill shape.
  static const Radius full = Radius.circular(9999);

  // ── BorderRadius convenience getters ──────────────────────────────────

  static BorderRadius get borderNone => const BorderRadius.all(none);
  static BorderRadius get borderXs => const BorderRadius.all(xs);
  static BorderRadius get borderSm => const BorderRadius.all(sm);
  static BorderRadius get borderMd => const BorderRadius.all(md);
  static BorderRadius get borderLg => const BorderRadius.all(lg);
  static BorderRadius get borderXl => const BorderRadius.all(xl);
  static BorderRadius get borderXxl => const BorderRadius.all(xxl);
  static BorderRadius get borderFull => const BorderRadius.all(full);
}
