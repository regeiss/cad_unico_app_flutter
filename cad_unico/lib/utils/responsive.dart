// ignore_for_file: deprecated_member_use, avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

class Responsive {
  static late BuildContext _context;
  static late MediaQueryData _mediaQuery;
  static late Size _screenSize;
  
  // Initialize responsive utilities
  static void init(BuildContext context) {
    _context = context;
    _mediaQuery = MediaQuery.of(context);
    _screenSize = _mediaQuery.size;
  }
  
  // Breakpoints
  static const double mobileMaxWidth = 768;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;
  
  // Screen width
  static double get screenWidth => _screenSize.width;
  
  // Screen height
  static double get screenHeight => _screenSize.height;
  
  // Device type checks
  static bool get isMobile => _screenSize.width < mobileMaxWidth;
  static bool get isTablet => 
      _screenSize.width >= mobileMaxWidth && _screenSize.width < desktopMinWidth;
  static bool get isDesktop => _screenSize.width >= desktopMinWidth;
  
  // Responsive values
  static T responsive<T>({
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet ?? desktop;
    return mobile;
  }
  
  // Width percentage
  static double wp(double percentage) => screenWidth * percentage / 100;
  
  // Height percentage
  static double hp(double percentage) => screenHeight * percentage / 100;
  
  // Responsive font size
  static double fontSize({
    required double mobile,
    double? tablet,
    required double desktop,
  }) {
    return responsive<double>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // Responsive padding
  static EdgeInsets padding({
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    required EdgeInsets desktop,
  }) {
    return responsive<EdgeInsets>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // Responsive margin
  static EdgeInsets margin({
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    required EdgeInsets desktop,
  }) {
    return responsive<EdgeInsets>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // Get columns count for grids
  static int getColumns({
    int mobile = 1,
    int? tablet,
    int desktop = 2,
  }) {
    return responsive<int>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // Get card width
  static double getCardWidth({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive<double>(
      mobile: mobile ?? screenWidth * 0.9,
      tablet: tablet ?? 400,
      desktop: desktop ?? 320,
    );
  }
  
  // Get sidebar width
  static double getSidebarWidth() {
    return responsive<double>(
      mobile: screenWidth * 0.8,
      tablet: 300,
      desktop: 280,
    );
  }
  
  // Check if screen is small (mobile or small tablet)
  static bool get isSmallScreen => screenWidth < 900;
  
  // Check if screen is large (desktop or large tablet)
  static bool get isLargeScreen => screenWidth >= 900;
  
  // Responsive AppBar height
  static double get appBarHeight {
    return responsive<double>(
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }
  
  // Get bottom sheet height
  static double getBottomSheetHeight({double factor = 0.9}) {
    return screenHeight * factor;
  }
  
  // Check if device is in portrait mode
  static bool get isPortrait => 
      _mediaQuery.orientation == Orientation.portrait;
  
  // Check if device is in landscape mode
  static bool get isLandscape => 
      _mediaQuery.orientation == Orientation.landscape;
  
  // Get safe area padding
  static EdgeInsets get safeAreaPadding => _mediaQuery.padding;
  
  // Get keyboard height
  static double get keyboardHeight => _mediaQuery.viewInsets.bottom;
  
  // Check if keyboard is open
  static bool get isKeyboardOpen => keyboardHeight > 0;
  
  // Get text scale factor
  static double get textScaleFactor => _mediaQuery.textScaleFactor;
  
  // Get device pixel ratio
  static double get devicePixelRatio => _mediaQuery.devicePixelRatio;
  
  // Responsive dialog width
  static double getDialogWidth() {
    return responsive<double>(
      mobile: screenWidth * 0.9,
      tablet: 500,
      desktop: 600,
    );
  }
  
  // Get max content width
  static double getMaxContentWidth() {
    return responsive<double>(
      mobile: screenWidth,
      tablet: 800,
      desktop: 1200,
    );
  }
  
  // Responsive grid crossAxisCount
  static int getGridColumns({
    int mobile = 1,
    int? tablet,
    int desktop = 3,
  }) {
    return responsive<int>(
      mobile: mobile,
      tablet: tablet ?? (mobile + desktop) ~/ 2,
      desktop: desktop,
    );
  }
  
  // Responsive grid childAspectRatio
  static double getGridAspectRatio({
    double mobile = 1.0,
    double? tablet,
    double desktop = 1.2,
  }) {
    return responsive<double>(
      mobile: mobile,
      tablet: tablet ?? (mobile + desktop) / 2,
      desktop: desktop,
    );
  }
  
  // Get navigation type
  static NavigationType get navigationType {
    if (isMobile) return NavigationType.bottom;
    if (isTablet) return NavigationType.rail;
    return NavigationType.drawer;
  }
  
  // Calculate responsive size based on screen width
  static double responsiveSize(double size) {
    // Base width for calculations (typically design width)
    const double baseWidth = 375;
    return (screenWidth / baseWidth) * size;
  }
  
  // Adaptive spacing
  static double spacing({
    double mobile = 8.0,
    double? tablet,
    double desktop = 16.0,
  }) {
    return responsive<double>(
      mobile: mobile,
      tablet: tablet ?? (mobile + desktop) / 2,
      desktop: desktop,
    );
  }
  
  // Adaptive border radius
  static BorderRadius borderRadius({
    double mobile = 8.0,
    double? tablet,
    double desktop = 12.0,
  }) {
    final radius = responsive<double>(
      mobile: mobile,
      tablet: tablet ?? (mobile + desktop) / 2,
      desktop: desktop,
    );
    return BorderRadius.circular(radius);
  }
  
  // Show different layouts based on screen size
  static Widget adaptiveLayout({
    required Widget mobile,
    Widget? tablet,
    required Widget desktop,
  }) {
    return responsive<Widget>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // Get icon size based on screen
  static double getIconSize({
    double mobile = 24.0,
    double? tablet,
    double desktop = 28.0,
  }) {
    return responsive<double>(
      mobile: mobile,
      tablet: tablet ?? (mobile + desktop) / 2,
      desktop: desktop,
    );
  }
  
  // Get button height
  static double getButtonHeight({
    double mobile = 48.0,
    double? tablet,
    double desktop = 52.0,
  }) {
    return responsive<double>(
      mobile: mobile,
      tablet: tablet ?? (mobile + desktop) / 2,
      desktop: desktop,
    );
  }
  
  // Get container constraints
  static BoxConstraints getContainerConstraints({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxWidth ?? getMaxContentWidth(),
      minHeight: minHeight ?? 0,
      maxHeight: maxHeight ?? double.infinity,
    );
  }
}

// Navigation type enum
enum NavigationType {
  bottom,
  rail,
  drawer,
}

// Responsive breakpoints widget
class ResponsiveBreakpoints extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  
  const ResponsiveBreakpoints({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Responsive.init(context);
        
        return Responsive.adaptiveLayout(
          mobile: mobile,
          tablet: tablet,
          desktop: desktop,
        );
      },
    );
  }
}

// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;
  
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Responsive.padding(
        mobile: mobile ?? const EdgeInsets.all(16),
        tablet: tablet,
        desktop: desktop ?? const EdgeInsets.all(24),
      ),
      child: child,
    );
  }
}

// Responsive container widget
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.responsive<double?>(
        mobile: mobileWidth,
        tablet: tabletWidth,
        desktop: desktopWidth,
      ),
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}

// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? spacing;
  final double? aspectRatio;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: Responsive.getGridColumns(
        mobile: mobileColumns ?? 1,
        tablet: tabletColumns,
        desktop: desktopColumns ?? 3,
      ),
      crossAxisSpacing: spacing ?? 16,
      mainAxisSpacing: spacing ?? 16,
      childAspectRatio: aspectRatio ?? 1.0,
      children: children,
    );
  }
}

// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive.fontSize(
      mobile: mobileFontSize ?? 14,
      tablet: tabletFontSize,
      desktop: desktopFontSize ?? 16,
    );
    
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}