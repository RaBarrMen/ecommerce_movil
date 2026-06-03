import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Muestra [mobile] en teléfonos y [desktop] en escritorio/tablet.
/// Si no se provee [desktop], usa [mobile] para todos.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (ResponsiveHelper.isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}

/// Centra el contenido con ancho máximo para escritorio
class CenteredContent extends StatelessWidget {
  const CenteredContent({super.key, required this.child, this.maxWidth = 1200});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}