import 'package:flutter/material.dart';

class AppDimensions {
  // Screen edge insets
  static const double screenMargin = 16.0;
  static const double screenPaddingSmall = 8.0;
  static const double screenPaddingMedium = 16.0;
  static const double screenPaddingLarge = 24.0;
  
  // Font sizes
  static const double fontSizeExtraSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeExtraLarge = 24.0;
  static const double fontSizeHeading = 30.0;
  static const double fontSizeSplash = 40.0;
  
  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;
  static const double borderRadiusRound = 24.0;
  static const double borderRadiusCircular = 100.0; // For circular elements
  
  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationExtraLarge = 12.0;
  
  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;
  
  // Button sizes
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // Card sizes
  static const double cardPadding = 16.0;
  static const double cardMargin = 8.0;
  static const double cardBorderRadius = 16.0;
  static const double cardElevation = 2.0;
  
  // Spacing
  static const double spacingExtraSmall = 2.0;
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 8.0;
  static const double spacingLarge = 16.0;
  static const double spacingExtraLarge = 24.0;
  static const double spacingHuge = 32.0;
  
  // Bottom navigation bar
  static const double navBarHeight = 64.0;
  static const double navBarIconSize = 24.0;
  
  // App bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  
  // Form fields
  static const double inputFieldHeight = 56.0;
  static const double inputFieldBorderWidth = 1.0;
  static const double inputFieldBorderRadius = 12.0;
  
  // Progress indicators
  static const double progressIndicatorSmall = 16.0;
  static const double progressIndicatorMedium = 24.0;
  static const double progressIndicatorLarge = 32.0;
  static const double progressIndicatorStrokeWidth = 2.0;
  
  // Avatar sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeExtraLarge = 96.0;
  
  // Animations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // Responsive breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  
  // Returns appropriate values based on screen size
  static double getResponsiveFontSize(BuildContext context, double fontSize) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < breakpointMobile) {
      return fontSize * 0.9;
    } else if (screenWidth < breakpointTablet) {
      return fontSize;
    } else {
      return fontSize * 1.1;
    }
  }
  
  // Returns appropriate padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < breakpointMobile) {
      return const EdgeInsets.all(screenPaddingSmall);
    } else if (screenWidth < breakpointTablet) {
      return const EdgeInsets.all(screenPaddingMedium);
    } else {
      return const EdgeInsets.all(screenPaddingLarge);
    }
  }
  
  // Returns appropriate spacing based on screen size
  static double getResponsiveSpacing(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < breakpointMobile) {
      return spacingSmall;
    } else if (screenWidth < breakpointTablet) {
      return spacingMedium;
    } else {
      return spacingLarge;
    }
  }
  
  // Returns number of grid columns based on screen size
  static int getResponsiveGridColumns(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < breakpointMobile) {
      return 2; // 2 columns for mobile
    } else if (screenWidth < breakpointTablet) {
      return 3; // 3 columns for tablet
    } else {
      return 4; // 4 columns for desktop
    }
  }
}
