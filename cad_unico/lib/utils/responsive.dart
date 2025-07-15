// ignore_for_file: avoid_classes_with_only_static_members
import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  // Métodos para verificar o tipo de dispositivo
  static bool isMobile(double width) => width < mobileBreakpoint;
  static bool isTablet(double width) => width >= mobileBreakpoint && width < desktopBreakpoint;
  static bool isDesktop(double width) => width >= desktopBreakpoint;

  // Métodos para obter dimensões responsivas
  static double getResponsiveWidth(BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isDesktop(screenWidth)) {
      return screenWidth * desktop;
    } else if (isTablet(screenWidth)) {
      return screenWidth * tablet;
    } else {
      return screenWidth * mobile;
    }
  }

  // Métodos para obter padding responsivo
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isDesktop(screenWidth)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(screenWidth)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Métodos para obter número de colunas em grid
  static int getGridColumns(double width, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 4,
  }) {
    if (isDesktop(width)) {
      return desktop;
    } else if (isTablet(width)) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Métodos para obter font size responsivo
  static double getResponsiveFontSize(double width, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    if (isDesktop(width)) {
      return desktop;
    } else if (isTablet(width)) {
      return tablet;
    } else {
      return mobile;
    }
  }
}