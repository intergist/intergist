/// Elevation (shadow depth) tokens for the SciFiOnly design system.
///
/// Material 3 uses elevation levels 0–5. These constants map to those
/// levels and can be passed to [Material.elevation], [PhysicalModel],
/// or custom [BoxShadow] builders.
abstract final class AppElevation {
  /// 0 dp — flat / no shadow (background surfaces).
  static const double level0 = 0;

  /// 1 dp — subtle lift (cards resting on surface).
  static const double level1 = 1;

  /// 2 dp — raised (hovered cards, top-app-bar at scroll).
  static const double level2 = 2;

  /// 3 dp — prominent (navigation rail, FAB resting).
  static const double level3 = 3;

  /// 4 dp — elevated (menus, dialogs backdrop).
  static const double level4 = 4;

  /// 6 dp — highest (modal sheets, dragged elements).
  static const double level5 = 6;

  /// 8 dp — extreme emphasis (spotlight overlays).
  static const double level6 = 8;
}
