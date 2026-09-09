import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/enums/estimate_status.dart';
import 'package:invoicemaker/core/enums/invoice_status.dart';

/// Background and label colours for a status chip.
typedef BadgeColors = ({Color background, Color foreground});

/// The pill showing an invoice's payment state.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.onTap});

  final InvoiceStatus status;

  /// Tapping opens the "Mark as" dialog; omit it for a read-only badge.
  final VoidCallback? onTap;

  static BadgeColors colorsFor(InvoiceStatus status) => switch (status) {
        InvoiceStatus.unpaid => (
            background: AppColors.buttonLightBlue,
            foreground: AppColors.lightBlueText,
          ),
        InvoiceStatus.paid => (
            background: AppColors.buttonLightGreen,
            foreground: AppColors.lightGreenText,
          ),
        InvoiceStatus.partiallyPaid => (
            background: AppColors.buttonLightOrange,
            foreground: AppColors.lightOrangeText,
          ),
        InvoiceStatus.overdue => (
            background: AppColors.buttonLightOrange,
            foreground: AppColors.red,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final colors = colorsFor(status);
    return _BadgeShell(
      label: status.label,
      colors: colors,
      onTap: onTap,
    );
  }
}

/// The pill showing an estimate's state.
class EstimateStatusBadge extends StatelessWidget {
  const EstimateStatusBadge({super.key, required this.status, this.onTap});

  final EstimateStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      EstimateStatus.pending => (
          background: AppColors.buttonLightBlue,
          foreground: AppColors.lightBlueText,
        ),
      EstimateStatus.approved => (
          background: AppColors.buttonLightGreen,
          foreground: AppColors.lightGreenText,
        ),
      EstimateStatus.cancelled => (
          background: AppColors.buttonLightOrange,
          foreground: AppColors.lightOrangeText,
        ),
    };

    return _BadgeShell(label: status.label, colors: colors, onTap: onTap);
  }
}

class _BadgeShell extends StatelessWidget {
  const _BadgeShell({
    required this.label,
    required this.colors,
    this.onTap,
  });

  final String label;
  final BadgeColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: colors.foreground),
          ),
        ),
      ),
    );
  }
}
