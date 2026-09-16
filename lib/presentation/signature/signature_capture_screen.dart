import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/services/signature_exporter.dart';
import 'package:invoicemaker/state/business_controller.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

/// Draws the signature kept in the business profile.
class SignatureCaptureScreen extends StatefulWidget {
  const SignatureCaptureScreen({super.key});

  @override
  State<SignatureCaptureScreen> createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen>
    with AsyncAction {
  static const SignatureExporter _exporter = SignatureExporter();

  late final SignatureController _controller = SignatureController(
    penStrokeWidth: _penWidth,
    penColor: _penColor,
    // Exported on white: the signature is printed onto paper.
    exportBackgroundColor: Colors.white,
  );

  static const double _penWidth = 3.5;
  static const Color _penColor = Color(0xFF15233A);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStrokesChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStrokesChanged)
      ..dispose();
    super.dispose();
  }

  /// Rebuilds so the save and clear buttons enable as soon as there is ink.
  void _onStrokesChanged() => setState(() {});

  Future<void> _save() async {
    final business = context.read<BusinessController>();
    var didSave = false;

    await run(
      () async {
        final bytes = await _exporter.export(_controller);
        if (bytes == null) return;
        await business.setSignature(bytes);
        didSave = true;
      },
      successMessage: AppCopy.savedMessage,
    );
    if (!didSave || !mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasInk = _controller.isNotEmpty;

    return AppScaffold(
      title: AppStrings.signature,
      maxContentWidth: Layout.listWidth,
      bottomBar: BottomActionBar(
        children: [
          AppButton.secondary(
            label: AppStrings.clear,
            onPressed: hasInk ? _controller.clear : null,
          ),
          AppButton(
            label: AppStrings.save,
            icon: Icons.check,
            isBusy: isBusy,
            onPressed: hasInk ? _save : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Insets.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign inside the box with your finger.',
              style: context.text.bodyMedium,
            ),
            Gap.h12,
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: Radii.mdAll,
                  border: Border.all(color: palette.borderStrong),
                ),
                child: ClipRRect(
                  borderRadius: Radii.mdAll,
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            Gap.h12,
            Text(
              'Your signature stays on this device and is only printed when '
              'you choose to include it.',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
