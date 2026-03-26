import 'package:flutter/material.dart';

/// Seuils de breakpoints
/// - Mobile  : < 600dp
/// - Tablette: >= 600dp
/// - Grande tablette : >= 900dp
class R {
  R._();

  static double _w(BuildContext ctx) => MediaQuery.of(ctx).size.width;

  static bool isTablet(BuildContext ctx) => _w(ctx) >= 600;
  static bool isLargeTablet(BuildContext ctx) => _w(ctx) >= 900;

  /// Padding horizontal des pages
  static double hPad(BuildContext ctx) {
    final w = _w(ctx);
    if (w >= 900) return 56;
    if (w >= 600) return 36;
    return 20;
  }

  /// Padding vertical des sections
  static double vPad(BuildContext ctx) => isTablet(ctx) ? 28 : 20;

  /// Largeur max du contenu (centré sur grands écrans)
  static double maxW(BuildContext ctx) {
    final w = _w(ctx);
    if (w >= 1200) return 960;
    if (w >= 900) return 820;
    if (w >= 600) return double.infinity;
    return double.infinity;
  }

  /// Taille de fonte responsive
  static double fs(BuildContext ctx, double base) {
    final w = _w(ctx);
    if (w >= 900) return base * 1.35;
    if (w >= 600) return base * 1.18;
    return base;
  }

  /// Taille des icônes
  static double icon(BuildContext ctx, double base) {
    final w = _w(ctx);
    if (w >= 900) return base * 1.3;
    if (w >= 600) return base * 1.15;
    return base;
  }

  /// Hauteur des boutons principaux
  static double btnH(BuildContext ctx) => isTablet(ctx) ? 64 : 54;

  /// Border radius des cartes
  static double radius(BuildContext ctx) => isTablet(ctx) ? 16 : 12;

  /// Espacement vertical entre éléments
  static double gap(BuildContext ctx) => isTablet(ctx) ? 20 : 14;

  /// Nombre de colonnes pour les grilles
  static int cols(BuildContext ctx) {
    final w = _w(ctx);
    if (w >= 1100) return 3;
    if (w >= 600) return 2;
    return 1;
  }

  /// Wrapper qui centre et limite la largeur du contenu
  static Widget centered(BuildContext ctx, {required Widget child}) {
    final max = maxW(ctx);
    if (max == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }
}
