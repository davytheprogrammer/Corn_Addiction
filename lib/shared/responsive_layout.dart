import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool useScaffold;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const ResponsiveLayout({
    Key? key,
    required this.child,
    this.padding,
    this.useScaffold = true,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getScreenPadding(context);
    
    Widget content = Padding(
      padding: responsivePadding,
      child: child,
    );

    if (!useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardPadding = padding ?? ResponsiveUtils.getScreenPadding(context);
    final cardMargin = margin ?? EdgeInsets.symmetric(
      vertical: ResponsiveUtils.isDesktop(context) ? 8 : 4,
    );

    return Container(
      margin: cardMargin,
      child: Material(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: ResponsiveUtils.getCardBorderRadius(context),
        elevation: ResponsiveUtils.getElevation(context, elevation ?? 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: ResponsiveUtils.getCardBorderRadius(context),
          child: Padding(
            padding: cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.baseFontSize = 16,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = ResponsiveUtils.getFontSize(context, baseFontSize);
    
    return Text(
      text,
      style: style?.copyWith(
        fontSize: responsiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ) ?? TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsets? padding;
  final double baseFontSize;
  final bool isLoading;
  final Widget? icon;

  const ResponsiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.baseFontSize = 16,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    final buttonPadding = padding ?? EdgeInsets.symmetric(
      horizontal: isDesktop ? 32 : isTablet ? 24 : 16,
      vertical: isDesktop ? 16 : isTablet ? 14 : 12,
    );

    Widget buttonChild = isLoading
        ? SizedBox(
            width: ResponsiveUtils.getIconSize(context, 20),
            height: ResponsiveUtils.getIconSize(context, 20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ?? Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                SizedBox(width: isDesktop ? 12 : isTablet ? 10 : 8),
              ],
              ResponsiveText(
                text,
                baseFontSize: baseFontSize,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ],
          );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: ResponsiveUtils.getElevation(context, elevation ?? 2),
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getCardBorderRadius(context),
        ),
      ),
      child: buttonChild,
    );
  }
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;

  const ResponsiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: ResponsiveText(
        title,
        baseFontSize: 20,
        fontWeight: FontWeight.w600,
        color: foregroundColor,
      ),
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: ResponsiveUtils.getElevation(context, elevation ?? 0),
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ResponsiveModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsets? padding;
  final bool isScrollable;

  const ResponsiveModal({
    Key? key,
    required this.child,
    this.title,
    this.padding,
    this.isScrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modalPadding = padding ?? ResponsiveUtils.getModalPadding(context);
    final modalWidth = ResponsiveUtils.getModalWidth(context);

    Widget content = Container(
      width: modalWidth,
      padding: modalPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: ResponsiveUtils.getCardBorderRadius(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            ResponsiveText(
              title!,
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            ResponsiveUtils.getVerticalSpacing(context, 16),
          ],
          if (isScrollable)
            Flexible(
              child: SingleChildScrollView(child: child),
            )
          else
            child,
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: content,
    );
  }
}

class ResponsiveListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? contentPadding;

  const ResponsiveListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = contentPadding ?? ResponsiveUtils.getScreenPadding(context);

    return ListTile(
      leading: leading,
      title: ResponsiveText(
        title,
        baseFontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitle: subtitle != null
          ? ResponsiveText(
              subtitle!,
              baseFontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: padding,
    );
  }
}
