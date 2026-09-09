import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';

/// A Font Awesome glyph sized and coloured to match the Material icons here.
///
/// Font Awesome icons are a distinct `FaIconData` type and must be rendered by
/// [FaIcon] rather than [Icon], so they cannot go through the usual `icon:`
/// parameters.
class AppFaIcon extends StatelessWidget {
  const AppFaIcon(this.icon, {super.key, this.size = 20, this.color});

  final FaIconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => FaIcon(
        icon,
        size: size,
        color: color ?? AppColors.primaryDark,
      );
}
