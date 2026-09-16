import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/validators.dart';
import 'package:invoicemaker/navigation/app_navigator.dart';
import 'package:invoicemaker/presentation/common/async_action.dart';
import 'package:invoicemaker/presentation/common/layout/app_scaffold.dart';
import 'package:invoicemaker/presentation/common/sheets/app_sheet.dart';
import 'package:invoicemaker/presentation/common/widgets/app_button.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/app_tile.dart';
import 'package:invoicemaker/presentation/common/widgets/section_header.dart';
import 'package:invoicemaker/presentation/common/widgets/state_views.dart';
import 'package:invoicemaker/services/photo_picker_service.dart';
import 'package:invoicemaker/state/business_controller.dart';
import 'package:provider/provider.dart';

/// The user's own business details, printed on every document.
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
    with AsyncAction {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PhotoPickerService _photoPicker = PhotoPickerService();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _taxNumber;
  late final TextEditingController _website;

  @override
  void initState() {
    super.initState();
    final profile = context.read<BusinessController>().profile;

    _name = TextEditingController(text: profile.name);
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phone);
    _address = TextEditingController(text: profile.address);
    _taxNumber = TextEditingController(text: profile.taxNumber);
    _website = TextEditingController(text: profile.website);
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _address,
      _taxNumber,
      _website,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final business = context.read<BusinessController>();
    var didSave = false;

    await run(
      () async {
        await business.save(
          business.profile.copyWith(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            taxNumber: _taxNumber.text.trim(),
            website: _website.text.trim(),
          ),
        );
        didSave = true;
      },
      successMessage: AppCopy.savedMessage,
    );
    if (!didSave || !mounted) return;

    Navigator.of(context).pop();
  }

  Future<void> _changeLogo() async {
    final business = context.read<BusinessController>();

    if (business.profile.hasLogo) {
      final action = await AppSheet.actions<_LogoAction>(
        context,
        title: AppStrings.logo,
        actions: const [
          SheetAction(
            value: _LogoAction.replace,
            label: 'Choose a different image',
            icon: Icons.image_outlined,
          ),
          SheetAction(
            value: _LogoAction.remove,
            label: 'Remove logo',
            icon: Icons.delete_outline,
            isDestructive: true,
          ),
        ],
      );
      if (action == null || !mounted) return;

      if (action == _LogoAction.remove) {
        await run(business.removeLogo);
        return;
      }
    }

    await run(() async {
      final path = await _photoPicker.pickImage();
      if (path == null) return;
      await business.setLogo(path);
    });
  }

  Future<void> _openSignature() async {
    await AppNavigator.openSignatureCapture(context);
  }

  Future<void> _removeSignature() async {
    await run(context.read<BusinessController>().removeSignature);
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessController>();
    final profile = business.profile;

    return AppScaffold(
      title: AppStrings.businessProfile,
      bottomBar: BottomActionBar(
        children: [
          AppButton(
            label: AppStrings.save,
            icon: Icons.check,
            isBusy: isBusy,
            onPressed: _save,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.gutter,
              Insets.lg,
              Insets.gutter,
              Insets.xl,
            ),
            children: [
              CardColumn(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: _LogoPicker(
                            bytes: business.logoBytes,
                            onTap: _changeLogo,
                          ),
                        ),
                        Gap.h20,
                        AppTextField(
                          controller: _name,
                          label: AppStrings.businessName,
                          hint: 'Your name or company name',
                          validator: Validators.required,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap.h16,
                        AppTextField(
                          controller: _email,
                          label: AppStrings.email,
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                          validator: Validators.optionalEmail,
                        ),
                        Gap.h16,
                        AppTextField(
                          controller: _phone,
                          label: AppStrings.phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap.h16,
                        AppTextField.multiline(
                          controller: _address,
                          label: AppStrings.address,
                          hint: 'Street, city, postcode',
                          minLines: 2,
                          maxLines: 4,
                        ),
                        Gap.h16,
                        AppTextField(
                          controller: _website,
                          label: AppStrings.website,
                          keyboardType: TextInputType.url,
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap.h16,
                        AppTextField(
                          controller: _taxNumber,
                          label: AppStrings.taxNumber,
                          helper: 'Printed on documents when set',
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],
                    ),
                  ),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: Insets.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            Insets.lg,
                            Insets.xs,
                            Insets.lg,
                            0,
                          ),
                          child: SectionHeader(title: AppStrings.signature),
                        ),
                        AppTile(
                          title: profile.hasSignature
                              ? 'Signature saved'
                              : 'Add a signature',
                          subtitle: profile.hasSignature
                              ? 'Choose per document whether to print it'
                              : 'Sign once and reuse it',
                          onTap: _openSignature,
                          trailing: business.signatureBytes == null
                              ? null
                              : SizedBox(
                                  height: 28,
                                  width: 72,
                                  child: Image.memory(
                                    business.signatureBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                        if (profile.hasSignature)
                          AppTile(
                            title: 'Remove signature',
                            icon: Icons.delete_outline,
                            isDestructive: true,
                            showChevron: false,
                            onTap: _removeSignature,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LogoAction { replace, remove }

/// The tappable logo, or a prompt to add one.
class _LogoPicker extends StatelessWidget {
  const _LogoPicker({required this.bytes, required this.onTap});

  final Uint8List? bytes;
  final VoidCallback onTap;

  static const double _size = 96;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        Material(
          color: palette.surfaceMuted,
          borderRadius: Radii.mdAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: _size,
              child: bytes == null
                  ? Icon(
                      Icons.add_photo_alternate_outlined,
                      size: IconSizes.lg,
                      color: palette.textTertiary,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(Insets.sm),
                      child: Image.memory(bytes!, fit: BoxFit.contain),
                    ),
            ),
          ),
        ),
        Gap.h8,
        AppButton.quiet(
          label: bytes == null ? 'Add logo' : 'Change logo',
          onPressed: onTap,
        ),
      ],
    );
  }
}
