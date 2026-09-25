import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/presentation/documents/widgets/document_card.dart';
import 'package:invoicemaker/presentation/home/widgets/summary_section.dart';
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

    final recent = documents.recent();

    return AppScaffold(
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            business.isConfigured ? business.profile.name : AppStrings.appName,
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
          SummarySection(
            summaries: documents.summaries,
            moneyFor: settings.moneyFormatFor,
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
                onTap: () => AppNavigator.openDocumentDetail(context, document),
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
