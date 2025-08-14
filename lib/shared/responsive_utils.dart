import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 768) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (width < 1024) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  static double getCardWidth(BuildContext context, {int columns = 1}) {
    final screenWidth = getScreenWidth(context);
    final padding = getScreenPadding(context);
    final availableWidth = screenWidth - (padding.horizontal);
    
    if (columns == 1) return availableWidth;
    
    final spacing = 16.0 * (columns - 1);
    return (availableWidth - spacing) / columns;
  }

  static int getGridColumns(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 768) return 1;
    if (width < 1024) return 2;
    return 3;
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    final width = getScreenWidth(context);
    if (width < 768) return baseFontSize;
    if (width < 1024) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  static double getIconSize(BuildContext context, double baseIconSize) {
    final width = getScreenWidth(context);
    if (width < 768) return baseIconSize;
    if (width < 1024) return baseIconSize * 1.1;
    return baseIconSize * 1.2;
  }

  static SizedBox getVerticalSpacing(BuildContext context, double baseSpacing) {
    final width = getScreenWidth(context);
    if (width < 768) return SizedBox(height: baseSpacing);
    if (width < 1024) return SizedBox(height: baseSpacing * 1.2);
    return SizedBox(height: baseSpacing * 1.4);
  }

  static SizedBox getHorizontalSpacing(BuildContext context, double baseSpacing) {
    final width = getScreenWidth(context);
    if (width < 768) return SizedBox(width: baseSpacing);
    if (width < 1024) return SizedBox(width: baseSpacing * 1.2);
    return SizedBox(width: baseSpacing * 1.4);
  }

  static double getAppBarHeight(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 768) return kToolbarHeight;
    if (width < 1024) return kToolbarHeight * 1.1;
    return kToolbarHeight * 1.2;
  }

  static double getBottomNavHeight(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 768) return kBottomNavigationBarHeight;
    if (width < 1024) return kBottomNavigationBarHeight * 1.1;
    return kBottomNavigationBarHeight * 1.2;
  }

  static EdgeInsets getModalPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 768) {
      return const EdgeInsets.all(16);
    } else if (width < 1024) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static double getModalWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 768) return width * 0.95;
    if (width < 1024) return width * 0.8;
    return width * 0.6;
  }

  static BorderRadius getCardBorderRadius(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 768) return BorderRadius.circular(12);
    if (width < 1024) return BorderRadius.circular(16);
    return BorderRadius.circular(20);
  }

  static double getElevation(BuildContext context, double baseElevation) {
    final width = getScreenWidth(context);
    if (width < 768) return baseElevation;
    if (width < 1024) return baseElevation * 1.2;
    return baseElevation * 1.4;
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveUtils.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? elevation;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? ResponsiveUtils.getScreenPadding(context),
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? ResponsiveUtils.getCardBorderRadius(context),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: ResponsiveUtils.getElevation(context, elevation!),
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
