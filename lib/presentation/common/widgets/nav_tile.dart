import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_text_styles.dart';

/// A tappable settings-style row: icon, title, optional value, chevron.
///
/// Replaces the many hand-built `ListTile`s that each rebuilt this layout with
/// a fixed-width trailing `SizedBox`.
class NavTile extends StatelessWidget {
  const NavTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.leadingWidget,
    this.trailingWidget,
    this.titleStyle = AppTextStyles.tileTitle,
    this.onTap,
  });

  final String title;
  final IconData? icon;

  /// Secondary line under the title.
  final String? subtitle;

  /// Right-aligned value shown before the chevron, e.g. `PKR Rs`.
  final String? value;

  /// Overrides the leading icon entirely.
  final Widget? leadingWidget;

  /// Extra widget shown before the chevron, e.g. a signature thumbnail.
  final Widget? trailingWidget;
  final TextStyle titleStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: leadingWidget ??
          (icon == null ? null : Icon(icon, color: AppColors.primaryDark)),
      title: Text(title, style: titleStyle),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tileSubtitle,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 15,
                ),
              ),
            ),
          if (trailingWidget != null) trailingWidget!,
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.sm),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
