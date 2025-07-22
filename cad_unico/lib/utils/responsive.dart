// lib/utils/responsive.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppConstants.desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    if (size.width >= AppConstants.desktopBreakpoint) {
      return desktop;
    } else if (size.width >= AppConstants.mobileBreakpoint && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

// Extensões para facilitar o uso
extension ResponsiveExtension on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Helpers para padding e spacing responsivos
  double get responsivePadding {
    if (isDesktop) return 24.0;
    if (isTablet) return 16.0;
    return 12.0;
  }
  
  double get responsiveSpacing {
    if (isDesktop) return 16.0;
    if (isTablet) return 12.0;
    return 8.0;
  }
  
  // Helper para número de colunas em grids
  int getGridColumns({int mobile = 1, int tablet = 2, int desktop = 4}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }
  
  // Helper para aspectRatio responsivo
  double getAspectRatio({
    double mobile = 1.0,
    double tablet = 1.2,
    double desktop = 1.5,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }
}

// Widget para valores responsivos
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  T getValue(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop;
    } else if (Responsive.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

// Widget builder responsivo
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: builder,
    );
}

// Classe para breakpoints customizados
class BreakPoint {
  final double mobile;
  final double tablet;
  final double desktop;

  const BreakPoint({
    this.mobile = AppConstants.mobileBreakpoint,
    this.tablet = AppConstants.tabletBreakpoint,
    this.desktop = AppConstants.desktopBreakpoint,
  });

  bool isMobile(double width) => width < mobile;
  bool isTablet(double width) => width >= mobile && width < desktop;
  bool isDesktop(double width) => width >= desktop;
}

// Widget para layout responsivo avançado
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final BreakPoint? breakPoints;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.breakPoints,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        final breakPoint = breakPoints ?? const BreakPoint();
        final width = constraints.maxWidth;

        if (breakPoint.isDesktop(width)) {
          return desktop;
        } else if (breakPoint.isTablet(width) && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
}

// Mixin para widgets que precisam de comportamento responsivo
mixin ResponsiveMixin<T extends StatefulWidget> on State<T> {
  bool get isMobile => Responsive.isMobile(context);
  bool get isTablet => Responsive.isTablet(context);
  bool get isDesktop => Responsive.isDesktop(context);
  
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  
  void onScreenSizeChanged() {
    // Override este método para reagir a mudanças de tamanho de tela
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onScreenSizeChanged();
  }
}