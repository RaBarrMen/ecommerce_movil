import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Número de columnas para grid de productos
  static int productGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 4;
    if (width >= tabletBreakpoint) return 3;
    if (width >= mobileBreakpoint) return 2;
    return 2;
  }

  /// Padding lateral según pantalla
  static EdgeInsets horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return const EdgeInsets.symmetric(horizontal: 80);
    if (width >= tabletBreakpoint) return const EdgeInsets.symmetric(horizontal: 40);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  /// Ancho máximo del contenido central
  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 1200;
    return width;
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }
}