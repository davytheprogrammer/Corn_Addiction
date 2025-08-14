import 'package:flutter/material.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:corn_addiction/core/constants/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.padding,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonLarge,
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 12),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.textColor,
    this.borderColor,
    this.padding,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          side: BorderSide(color: borderColor ?? AppColors.primary, width: 1.5),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: textColor ?? AppColors.primary,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: textColor ?? AppColors.primary,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 12),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

class TextActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final TextStyle? style;

  const TextActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: style ??
            AppTextStyles.buttonMedium.copyWith(
              color: textColor ?? AppColors.primary,
            ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool enabled;
  final bool showTogglePasswordVisibility;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.enabled = true,
    this.showTogglePasswordVisibility = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _isOwningController = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isOwningController = true;
      _controller = TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void dispose() {
    if (_isOwningController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.showTogglePasswordVisibility
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final Gradient? gradient;

  const CustomCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
    this.border,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        gradient: gradient,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        elevation: elevation,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: cardContent,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      elevation: elevation,
      child: cardContent,
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final List<Color> gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
    this.gradientColors = const [
      AppColors.primary,
      AppColors.primaryLight,
    ],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      elevation: elevation,
      borderRadius: borderRadius,
      onTap: onTap,
      gradient: LinearGradient(
        colors: gradientColors,
        begin: begin,
        end: end,
      ),
      child: child,
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    Key? key,
    this.size = 36,
    this.color,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingIndicator(
                    color: Colors.white,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final double iconSize;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    this.message,
    this.icon = Icons.hourglass_empty_rounded,
    this.onActionPressed,
    this.actionText,
    this.iconSize = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: actionText!,
                onPressed: onActionPressed!,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StreakCounterBadge extends StatelessWidget {
  final int days;
  final String? label;
  final double size;
  final bool showProgress;

  const StreakCounterBadge({
    Key? key,
    required this.days,
    this.label,
    this.size = 120,
    this.showProgress = true,
  }) : super(key: key);

  Color _getStreakColor() {
    if (days < 7) {
      return AppColors.streak7days;
    } else if (days < 30) {
      return AppColors.streak30days;
    } else if (days < 90) {
      return AppColors.streak90days;
    } else if (days < 180) {
      return AppColors.streak180days;
    } else {
      return AppColors.streak365days;
    }
  }

  @override
  Widget build(BuildContext context) {
    final streakColor = _getStreakColor();
    final milestone = days >= 365
        ? 365
        : days >= 180
            ? 180
            : days >= 90
                ? 90
                : days >= 30
                    ? 30
                    : days >= 7
                        ? 7
                        : 1;
    final progress = days / milestone;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showProgress)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress > 1 ? 1 : progress,
                strokeWidth: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(streakColor),
              ),
            ),
          Container(
            width: size - 24,
            height: size - 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: streakColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days.toString(),
                  style: AppTextStyles.streakCounter,
                ),
                Text(
                  label ?? 'DAYS',
                  style: AppTextStyles.streakLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementBadge extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final double size;

  const AchievementBadge({
    Key? key,
    required this.title,
    required this.icon,
    this.color,
    this.isUnlocked = true,
    this.onTap,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.achievement;

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? badgeColor : AppColors.surfaceDark,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                icon,
                color: isUnlocked ? Colors.white : AppColors.textHint,
                size: size / 2.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
