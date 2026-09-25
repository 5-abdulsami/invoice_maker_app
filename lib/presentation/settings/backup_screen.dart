import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/data/models/backup_bundle.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/services/backup_service.dart';
import 'package:invoicemaker/state/business_controller.dart';
import 'package:invoicemaker/state/catalog_controller.dart';
import 'package:invoicemaker/state/customer_controller.dart';
import 'package:invoicemaker/state/document_controller.dart';
import 'package:invoicemaker/state/settings_controller.dart';
import 'package:provider/provider.dart';

/// Export, restore and delete-everything.
///
/// Because nothing is synced, this screen is the user's only safety net, so
/// it explains what it does rather than hiding behind two icons.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> with AsyncAction {
  Future<void> _export() async {
    final service = context.read<BackupService>();

    await run(
      () async {
        final bundle = await service.exportAndShare();
        if (!mounted) return;
        context.showMessage(
          '${AppCopy.backupExportedMessage} · '
          '${bundle.recordCount} records',
        );
      },
    );
  }

  Future<void> _restore() async {
    final service = context.read<BackupService>();

    final bundle = await run(service.pickBundle);
    if (bundle == null || !mounted) return;

    final mode = await _askRestoreMode(bundle);
    if (mode == null || !mounted) return;

    await run(
      () async {
        await service.restore(bundle, mode: mode);
        if (!mounted) return;
        _refreshControllers();
        context.showMessage(AppCopy.backupImportedMessage);
      },
    );
  }

  Future<RestoreMode?> _askRestoreMode(BackupBundle bundle) {
    return AppSheet.actions<RestoreMode>(
      context,
      title: AppCopy.importMergeTitle,
      subtitle: '${AppCopy.count(bundle.invoiceCount, 'invoice')}, '
          '${AppCopy.count(bundle.estimateCount, 'estimate')} and '
          '${AppCopy.count(bundle.customers.length, 'customer')} in this '
          'file. ${AppCopy.importMergeBody}',
      actions: const [
        SheetAction(
          value: RestoreMode.merge,
          label: AppCopy.importMerge,
          icon: Icons.merge_outlined,
          description: 'Keep what is here and add what is missing',
        ),
        SheetAction(
          value: RestoreMode.replace,
          label: AppCopy.importReplace,
          icon: Icons.swap_horiz,
          description: 'Delete everything here first',
          isDestructive: true,
        ),
      ],
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await AppSheet.confirm(
      context,
      title: AppStrings.clearAllData,
      message: AppCopy.clearAllDataBody,
      confirmLabel: 'Delete everything',
    );
    if (!confirmed || !mounted) return;

    final service = context.read<BackupService>();
    await run(
      () async {
        await service.clearAll();
        if (!mounted) return;
        _refreshControllers();
        context.showMessage(AppCopy.dataClearedMessage);
      },
    );
  }

  /// Tells every controller its repository changed underneath it.
  void _refreshControllers() {
    context.read<SettingsController>().refresh();
    context.read<CustomerController>().refresh();
    context.read<CatalogController>().refresh();
    context.read<DocumentController>().refresh();
    // Images may have been replaced on disk, so re-read their bytes.
    unawaited(context.read<BusinessController>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final documents = context.watch<DocumentController>();
    final customers = context.watch<CustomerController>();
    final catalog = context.watch<CatalogController>();

    return AppScaffold(
      title: AppStrings.dataAndBackup,
      body: LoadingOverlay(
        isLoading: isBusy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Insets.gutter,
            Insets.lg,
            Insets.gutter,
            Insets.xl,
          ),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android_outlined,
                        size: IconSizes.md,
                        color: context.palette.primary,
                      ),
                      Gap.w8,
                      Expanded(
                        child: Text(
                          'On this device',
                          style: context.text.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  Gap.h8,
                  Text(
                    [
                      AppCopy.count(
                        documents.countOfKind(DocumentKind.invoice),
                        'invoice',
                      ),
                      AppCopy.count(
                        documents.countOfKind(DocumentKind.estimate),
                        'estimate',
                      ),
                      AppCopy.count(customers.count, 'customer'),
                      AppCopy.count(catalog.count, 'item'),
                    ].join(' · '),
                    style: context.text.bodyMedium,
                  ),
                  Gap.h12,
                  Text(AppCopy.backupExplainer, style: context.text.bodySmall),
                ],
              ),
            ),
            Gap.h20,
            const SectionHeader(title: AppStrings.exportBackup),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppCopy.exportBackupBody,
                    style: context.text.bodyMedium,
                  ),
                  Gap.h16,
                  AppButton(
                    label: 'Export a backup file',
                    icon: Icons.ios_share,
                    onPressed: isBusy ? null : _export,
                  ),
                ],
              ),
            ),
            Gap.h20,
            const SectionHeader(title: AppStrings.importBackup),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppCopy.importBackupBody,
                    style: context.text.bodyMedium,
                  ),
                  Gap.h16,
                  AppButton.secondary(
                    label: 'Choose a backup file',
                    icon: Icons.folder_open_outlined,
                    onPressed: isBusy ? null : _restore,
                  ),
                ],
              ),
            ),
            Gap.h28,
            const SectionHeader(title: 'Danger zone'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppCopy.clearAllDataBody,
                    style: context.text.bodyMedium,
                  ),
                  Gap.h16,
                  AppButton.danger(
                    label: AppStrings.clearAllData,
                    icon: Icons.delete_forever_outlined,
                    onPressed: isBusy ? null : _clearAll,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
