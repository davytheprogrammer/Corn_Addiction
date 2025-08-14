import 'package:flutter/material.dart';
import 'package:corn_addiction/core/constants/dimensions.dart';

class AppStyles {
  // Text styles
  static TextStyle headline1(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeHeading),
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static TextStyle headline2(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeExtraLarge),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );
  
  static TextStyle headline3(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, 20.0),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );
  
  static TextStyle subtitle1(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeMedium),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static TextStyle subtitle2(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeRegular),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static TextStyle bodyText1(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeMedium),
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );
  
  static TextStyle bodyText2(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeRegular),
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );
  
  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeRegular),
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );
  
  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeSmall),
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
  
  static TextStyle overline(BuildContext context) => TextStyle(
    fontSize: AppDimensions.getResponsiveFontSize(context, AppDimensions.fontSizeExtraSmall),
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
  
  // Card styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration cardDecorationFlatBorder = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
    border: Border.all(color: Colors.grey.shade200, width: 1),
  );
  
  // Button styles
  static ButtonStyle primaryButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingLarge,
        horizontal: AppDimensions.spacingExtraLarge,
      ),
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
    ),
  );
  
  static ButtonStyle secondaryButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingLarge,
        horizontal: AppDimensions.spacingExtraLarge,
      ),
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
    ),
  );
  
  static ButtonStyle textButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingMedium,
        horizontal: AppDimensions.spacingLarge,
      ),
    ),
  );
  
  // Input decoration
  static InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLarge,
        vertical: AppDimensions.spacingLarge,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputFieldBorderRadius),
        borderSide: const BorderSide(
          width: AppDimensions.inputFieldBorderWidth,
          color: Colors.grey,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputFieldBorderRadius),
        borderSide: BorderSide(
          width: AppDimensions.inputFieldBorderWidth,
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputFieldBorderRadius),
        borderSide: const BorderSide(
          width: AppDimensions.inputFieldBorderWidth * 2,
          color: Colors.green,
        ),
      ),
    );
  }
  
  // Containers
  static BoxDecoration roundedContainer = BoxDecoration(
    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
    color: Colors.white,
  );
  
  static BoxDecoration gradientContainer = BoxDecoration(
    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
    gradient: const LinearGradient(
      colors: [Colors.green, Colors.green],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  
  // Divider style
  static const Divider divider = Divider(
    height: 1,
    thickness: 1,
  );
  
  // Animation curves
  static const Curve animationCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  
  // Icon styles
  static BoxDecoration circularIconContainer(Color color) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.1),
    );
  }
}
