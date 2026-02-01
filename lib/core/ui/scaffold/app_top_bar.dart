import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_sizes.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.onLeadingTap,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = true,
  });

  final String title;
  final String? subtitle;

  /// If you want a custom leading widget, pass it here.
  final Widget? leading;

  /// If you want a simple icon leading (back/close), pass this.
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;

  /// Trailing actions (icons/buttons). Use small widgets; AppBar will constrain.
  final List<Widget>? actions;

  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(
    (subtitle != null && subtitle!.trim().isNotEmpty)
        ? (AppSizes.topBarHeight + 16)
        : AppSizes.topBarHeight,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? AppColors.textLight : AppColors.navy;
    final subColor = isDark
        ? AppColors.textMutedLight
        : AppColors.textMutedDark;

    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    final Widget? effectiveLeading =
        leading ??
        (leadingIcon == null
            ? null
            : InkWell(
                onTap: onLeadingTap ?? () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(AppSizes.minTap / 2),
                child: SizedBox(
                  height: AppSizes.minTap,
                  width: AppSizes.minTap,
                  child: Icon(leadingIcon, color: titleColor, size: 20),
                ),
              ));

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      titleSpacing: 0,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      backgroundColor: backgroundColor ?? Colors.transparent,
      surfaceTintColor: Colors.transparent,

      // ✅ Put leading in the REAL leading slot (no overflow)
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.screenH),
        child: effectiveLeading,
      ),
      leadingWidth: (effectiveLeading == null)
          ? 0
          : (AppSizes.minTap + AppSpacing.screenH),

      // ✅ Put actions in the REAL actions slot (no overflow)
      actions: (actions == null || actions!.isEmpty)
          ? null
          : [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.screenH),
                child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
              ),
            ],

      // ✅ Title is only text/column, so it can always ellipsis safely
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: centerTitle
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            if (hasSubtitle)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s2),
                child: Text(
                  subtitle!.trim(),
                  textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
