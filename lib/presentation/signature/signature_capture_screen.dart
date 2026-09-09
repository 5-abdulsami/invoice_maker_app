import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/utils/pdf_asset_loader.dart';
import 'package:invoicemaker/presentation/common/async_action_mixin.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/providers/signature_provider.dart';
import 'package:invoicemaker/services/signature_service.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

/// Draws and saves the signature printed on invoices.
class SignatureCaptureScreen extends StatefulWidget {
  const SignatureCaptureScreen({super.key});

  @override
  State<SignatureCaptureScreen> createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen>
    with AsyncActionMixin {
  static const SignatureService _service = SignatureService();

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 8,
    penColor: Colors.teal,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Confirms before discarding an unsaved drawing.
  Future<void> _onPopInvoked(bool didPop, Uint8List? result) async {
    if (didPop) return;

    if (_controller.isEmpty) {
      if (mounted) Navigator.of(context).pop(PdfAssetLoader.transparentPixel);
      return;
    }

    final discard = await ConfirmDialog.show(
      context,
      title: 'Discard changes?',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      cancelLabel: 'Cancel',
    );
    if (!discard || !mounted) return;
    Navigator.of(context).pop(PdfAssetLoader.transparentPixel);
  }

  Future<void> _save() async {
    if (_controller.isEmpty) {
      Navigator.of(context).pop(PdfAssetLoader.transparentPixel);
      return;
    }

    final signature = await runGuarded(() => _service.export(_controller));
    if (signature == null || !mounted) return;

    context.read<SignatureProvider>().saveSignature(signature);
    Navigator.of(context).pop(signature);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Uint8List?>(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: const Text('Signature Capture')),
        body: Column(
          children: [
            Expanded(
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppStrings.clear,
                      variant: AppButtonVariant.outline,
                      onPressed: _controller.clear,
                    ),
                  ),
                  Gap.wMd,
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: AppStrings.save,
                      isBusy: isBusy,
                      onPressed: _save,
                    ),
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
