import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/extensions/context_extensions.dart';
import 'package:invoicemaker/presentation/common/async_action_mixin.dart';
import 'package:invoicemaker/presentation/common/widgets/app_text_field.dart';
import 'package:invoicemaker/presentation/common/widgets/loading_overlay.dart';
import 'package:invoicemaker/presentation/common/widgets/section_card.dart';
import 'package:invoicemaker/providers/business_provider.dart';
import 'package:invoicemaker/providers/invoice_provider.dart';
import 'package:invoicemaker/services/image_picker_service.dart';
import 'package:provider/provider.dart';

/// Edits the user's own business details and logo.
class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen>
    with AsyncActionMixin {
  final ImagePickerService _imagePicker = ImagePickerService();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _websiteController;

  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final business = context.read<BusinessProvider>().business;
    _nameController = TextEditingController(text: business.businessName);
    _emailController = TextEditingController(text: business.emailAddress);
    _phoneController = TextEditingController(text: business.phone);
    _addressController = TextEditingController(text: business.billingAddress);
    _websiteController = TextEditingController(text: business.website);
    _logoPath = business.logoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _save() {
    final business = context.read<BusinessProvider>();
    business.save(
      business.business.copyWith(
        businessName: _nameController.text.trim(),
        emailAddress: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        billingAddress: _addressController.text.trim(),
        website: _websiteController.text.trim(),
        logoPath: _logoPath,
        clearLogo: _logoPath == null,
      ),
    );

    // The invoice's "From" line always mirrors the business name.
    context
        .read<InvoiceProvider>()
        .updateDraft((draft) => draft.copyWith(from: _nameController.text.trim()));

    Navigator.of(context).pop();
  }

  Future<void> _pickLogo() async {
    final source = await showModalBottomSheet<_LogoSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Business Logo')),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(_LogoSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(context).pop(_LogoSource.camera),
            ),
            if (_logoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove Logo'),
                onTap: () => Navigator.of(context).pop(_LogoSource.remove),
              ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    if (source == _LogoSource.remove) {
      setState(() => _logoPath = null);
      return;
    }

    final path = await runGuarded(
      () => source == _LogoSource.gallery
          ? _imagePicker.pickFromGallery()
          : _imagePicker.pickFromCamera(),
    );
    if (path == null || !mounted) return;
    setState(() => _logoPath = path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.businessInfo),
        actions: [
          IconButton(
            tooltip: AppStrings.save,
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
          Gap.wSm,
        ],
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: _LogoPicker(
                          logoPath: _logoPath,
                          onTap: _pickLogo,
                        ),
                      ),
                      LabeledField(
                        label: 'Business Name',
                        child: AppTextField(
                          controller: _nameController,
                          hintText: 'Enter business name',
                        ),
                      ),
                      LabeledField(
                        label: 'Email Address',
                        child: AppTextField(
                          controller: _emailController,
                          hintText: 'Enter business email address',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      LabeledField(
                        label: 'Phone',
                        child: AppTextField(
                          controller: _phoneController,
                          hintText: 'Enter business phone number',
                          keyboardType: TextInputType.phone,
                          maxLength: 15,
                        ),
                      ),
                      LabeledField(
                        label: 'Billing Address',
                        child: AppTextField(
                          controller: _addressController,
                          hintText: 'Enter address',
                        ),
                      ),
                      LabeledField(
                        label: 'Business Website',
                        child: AppTextField(
                          controller: _websiteController,
                          hintText: 'Enter business website',
                          keyboardType: TextInputType.url,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _LogoSource { gallery, camera, remove }

/// The tappable logo thumbnail, or an add button when no logo is set.
class _LogoPicker extends StatelessWidget {
  const _LogoPicker({required this.logoPath, required this.onTap});

  final String? logoPath;
  final VoidCallback onTap;

  static const double _size = 80;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            child: logoPath == null
                ? Container(
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      border: Border.all(color: AppColors.darkGrey, width: 1.5),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 40,
                      color: AppColors.darkGrey,
                    ),
                  )
                : Image.file(
                    File(logoPath!),
                    width: _size,
                    height: _size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      size: _size,
                      color: AppColors.darkGrey,
                    ),
                  ),
          ),
        ),
        const Text(
          'Business Logo',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkGrey,
            height: 2.5,
          ),
        ),
      ],
    );
  }
}
