// ignore_for_file: deprecated_member_use, avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import '../constants/constants.dart';

class Responsive {
  // Verifica se a tela é mobile
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

  // Verifica se a tela é tablet
  static bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint && 
           width < AppConstants.tabletBreakpoint;
  }

  // Verifica se a tela é desktop
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

  // Verifica se a tela é grande (desktop)
  static bool isLargeDesktop(BuildContext context) => MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;

  // Retorna o tipo de dispositivo
  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    
    if (width < AppConstants.mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < AppConstants.tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < AppConstants.desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  // Retorna padding responsivo
  static EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppConstants.defaultPadding);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppConstants.largePadding);
    } else {
      return const EdgeInsets.all(AppConstants.extraLargePadding);
    }
  }

  // Retorna número de colunas para grid responsivo
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else if (isDesktop(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  // Retorna largura máxima do conteúdo
  static double getMaxContentWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return screenWidth * 0.9;
    } else {
      return 1200.0; // Largura máxima para desktop
    }
  }

  // Widget responsivo que retorna diferentes widgets baseado no tamanho da tela
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  // Retorna valor responsivo baseado no tipo de tela
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  // Retorna altura responsiva baseada na porcentagem da tela
  static double getHeight(BuildContext context, double percentage) => MediaQuery.of(context).size.height * percentage;

  // Retorna largura responsiva baseada na porcentagem da tela
  static double getWidth(BuildContext context, double percentage) => MediaQuery.of(context).size.width * percentage;

  // Retorna fonte responsiva
  static double getFontSize(BuildContext context, double baseFontSize) {
    double scaleFactor = MediaQuery.of(context).textScaleFactor;
    
    if (isMobile(context)) {
      return baseFontSize * scaleFactor;
    } else if (isTablet(context)) {
      return (baseFontSize * 1.1) * scaleFactor;
    } else {
      return (baseFontSize * 1.2) * scaleFactor;
    }
  }

  // Retorna espaçamento responsivo
  static double getSpacing(BuildContext context, {
    double mobile = AppConstants.defaultPadding,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.5;
    } else {
      return desktop ?? tablet ?? mobile * 2;
    }
  }

  // Verifica se deve mostrar drawer ou sidebar
  static bool shouldShowDrawer(BuildContext context) => isMobile(context);

  // Verifica se deve mostrar sidebar permanente
  static bool shouldShowSidebar(BuildContext context) => !isMobile(context);

  // Retorna orientação da tela
  static Orientation getOrientation(BuildContext context) => MediaQuery.of(context).orientation;

  // Verifica se está em modo paisagem
  static bool isLandscape(BuildContext context) => getOrientation(context) == Orientation.landscape;

  // Verifica se está em modo retrato
  static bool isPortrait(BuildContext context) => getOrientation(context) == Orientation.portrait;

  // Retorna densidade de pixels
  static double getPixelRatio(BuildContext context) => MediaQuery.of(context).devicePixelRatio;

  // Verifica se é uma tela de alta densidade
  static bool isHighDensity(BuildContext context) => getPixelRatio(context) > 2.0;

  // Retorna padding seguro (evita notch e barras do sistema)
  static EdgeInsets getSafePadding(BuildContext context) => MediaQuery.of(context).padding;

  // Widget que centraliza conteúdo com largura máxima
  static Widget centeredContent({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxContentWidth(context),
        ),
        child: child,
      ),
    );
}

// Enum para tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

// Widget wrapper responsivo
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) => Responsive.responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
}

// Layout responsivo com sidebar
class ResponsiveLayout extends StatelessWidget {
  final Widget? drawer;
  final Widget body;
  final Widget? sidebar;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool showSidebarOnDesktop;

  const ResponsiveLayout({
    super.key,
    this.drawer,
    required this.body,
    this.sidebar,
    this.appBar,
    this.floatingActionButton,
    this.showSidebarOnDesktop = true,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: appBar,
      drawer: Responsive.shouldShowDrawer(context) ? drawer : null,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          // Sidebar para desktop
          if (Responsive.shouldShowSidebar(context) && 
              showSidebarOnDesktop && 
              sidebar != null)
            sidebar!,
          
          // Conteúdo principal
          Expanded(
            child: body,
          ),
        ],
      ),
    );
}

// Mixin para widgets responsivos
mixin ResponsiveMixin {
  bool isMobile(BuildContext context) => Responsive.isMobile(context);
  bool isTablet(BuildContext context) => Responsive.isTablet(context);
  bool isDesktop(BuildContext context) => Responsive.isDesktop(context);
  
  DeviceType getDeviceType(BuildContext context) => 
      Responsive.getDeviceType(context);
  
  EdgeInsets getPadding(BuildContext context) => 
      Responsive.getPadding(context);
  
  int getGridColumns(BuildContext context) => 
      Responsive.getGridColumns(context);
}