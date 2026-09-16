import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/palette.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/presentation/documents/widgets/document_card.dart';
import 'package:invoicemaker/state/business_controller.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// The landing screen.
///
/// One obvious primary action, three figures worth knowing, and the documents
/// most likely to be reopened. No charts: a person billing by phone wants to
/// send an invoice, not study a dashboard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onBrowseInvoices});

  /// Switches the shell to the invoices tab.
  final VoidCallback onBrowseInvoices;

  @override
  Widget build(BuildContext context) {
    final documents = context.watch<DocumentController>();
    final business = context.watch<BusinessController>();
    final settings = context.watch<SettingsController>();

    final summary = documents.summary;
    final money = settings.moneyFormat;
    final recent = documents.recent();

    return AppScaffold(
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            business.isConfigured
                ? business.profile.name
                : AppStrings.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleLarge,
          ),
          Text(AppCopy.homeGreeting, style: context.text.bodySmall),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => AppNavigator.openSettings(context),
          icon: const Icon(Icons.settings_outlined),
          tooltip: AppStrings.settings,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.gutter,
          Insets.lg,
          Insets.gutter,
          Insets.scrollBottom,
        ),
        children: [
          if (!business.isConfigured) ...[
            _SetUpBusinessCard(
              onSetUp: () => AppNavigator.openBusinessProfile(context),
            ),
            Gap.h16,
          ],
          AppHeroButton(
            label: AppCopy.homePrimaryAction,
            description: AppCopy.homePrimaryHint,
            icon: Icons.note_add_outlined,
            onPressed: () => AppNavigator.openEditor(
              context,
              kind: DocumentKind.invoice,
            ),
          ),
          Gap.h20,
          _SummaryRow(summary: summary, money: money),
          Gap.h20,
          _QuickActions(
            onNewEstimate: () => AppNavigator.openEditor(
              context,
              kind: DocumentKind.estimate,
            ),
            onCustomers: () => AppNavigator.openCustomerList(context),
            onItems: () => AppNavigator.openCatalogList(context),
          ),
          if (recent.isNotEmpty) ...[
            Gap.h28,
            SectionHeader(
              title: AppCopy.recentActivity,
              actionLabel: AppCopy.viewAll,
              onAction: onBrowseInvoices,
            ),
            for (final document in recent) ...[
              DocumentCard(
                document: document,
                money: settings.moneyFormatFor(document.currency),
                dateFormat: settings.dateFormat,
                onTap: () =>
                    AppNavigator.openDocumentDetail(context, document),
              ),
              Gap.h12,
            ],
          ],
        ],
      ),
    );
  }
}

/// Prompts for the business details on first run, without blocking anything.
class _SetUpBusinessCard extends StatelessWidget {
  const _SetUpBusinessCard({required this.onSetUp});

  final VoidCallback onSetUp;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: IconSizes.md,
                color: context.palette.primary,
              ),
              Gap.w8,
              Expanded(
                child: Text(
                  AppCopy.setUpBusinessTitle,
                  style: context.text.titleMedium,
                ),
              ),
            ],
          ),
          Gap.h8,
          Text(AppCopy.setUpBusinessBody, style: context.text.bodyMedium),
          Gap.h16,
          AppButton.secondary(
            label: AppCopy.setUpBusinessAction,
            onPressed: onSetUp,
          ),
        ],
      ),
    );
  }
}

/// Outstanding, overdue and collected, side by side.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary, required this.money});

  final DocumentSummary summary;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _SummaryTile(
        label: AppCopy.outstandingLabel,
        value: money.format(summary.outstanding),
        tone: AppStatusTone.neutral,
      ),
      _SummaryTile(
        label: AppCopy.overdueLabel,
        value: money.format(summary.overdue),
        tone: AppStatusTone.critical,
        badge: summary.overdueCount > 0 ? '${summary.overdueCount}' : null,
      ),
      _SummaryTile(
        label: AppCopy.paidLabel,
        value: money.format(summary.collected),
        tone: AppStatusTone.positive,
      ),
    ];

    // Stacks on the narrowest phones, where three figures side by side would
    // each be squeezed to a few characters.
    if (context.isCompactWidth) {
      return Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) Gap.h8,
            tiles[i],
          ],
        ],
      );
    }

    // IntrinsicHeight bounds the row's height, which is what lets the tiles
    // stretch to match each other inside the page's scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) Gap.w8,
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.tone,
    this.badge,
  });

  final String label;
  final String value;
  final AppStatusTone tone;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.palette.statusColors(tone);

    return AppCard(
      padding: const EdgeInsets.all(Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.text.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.xs,
                    vertical: Insets.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: Radii.pillAll,
                  ),
                  child: Text(
                    badge!,
                    style: context.text.labelSmall?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Gap.h8,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: context.textRoles.amountLarge),
          ),
        ],
      ),
    );
  }
}

/// Secondary destinations, as one row of equal buttons.
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onNewEstimate,
    required this.onCustomers,
    required this.onItems,
  });

  final VoidCallback onNewEstimate;
  final VoidCallback onCustomers;
  final VoidCallback onItems;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            label: AppStrings.newEstimate,
            icon: Icons.description_outlined,
            onTap: onNewEstimate,
          ),
        ),
        Gap.w8,
        Expanded(
          child: _QuickAction(
            label: AppStrings.customers,
            icon: Icons.people_outline,
            onTap: onCustomers,
          ),
        ),
        Gap.w8,
        Expanded(
          child: _QuickAction(
            label: AppStrings.catalog,
            icon: Icons.inventory_2_outlined,
            onTap: onItems,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.sm,
        vertical: Insets.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: IconSizes.md, color: context.palette.primary),
          Gap.h8,
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelMedium,
          ),
        ],
      ),
    );
  }
}
