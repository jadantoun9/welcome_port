import 'dart:io';

import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/success_message.dart';
import 'package:welcome_port/features/company_info/company_info_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/features/company_info/service/file_service.dart';
import 'package:welcome_port/features/company_info/utils/utils.dart';

class CompanyInfoProvider extends ChangeNotifier {
  final service = CompanyInfoService();
  final CustomerModel customer;

  CompanyInfoProvider({required this.customer}) {
    loadData();
  }

  final formKey = GlobalKey<FormState>();
  final companyNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyTelephoneController = TextEditingController();
  final companyEmailController = TextEditingController();
  final companyLogoController = TextEditingController();

  final companyNameFocusNode = FocusNode();
  final companyAddressFocusNode = FocusNode();
  final companyTelephoneFocusNode = FocusNode();
  final companyEmailFocusNode = FocusNode();
  final companyLogoFocusNode = FocusNode();

  File? uploadedImage;
  String? uploadImageError;
  bool uploadImageLoading = false;
  bool showInitialImage = true;

  bool updateCompanyInfoLoading = false;
  String? updateCompanyInfoError;
  String? uploadedImageCode;

  void setUpdateCompanyInfoLoading(bool value) {
    updateCompanyInfoLoading = value;
    notifyListeners();
  }

  void setUpdateCompanyInfoError(String? value) {
    updateCompanyInfoError = value;
    notifyListeners();
  }

  void setUploadedImageCode(String code) {
    uploadedImageCode = code;
    notifyListeners();
  }

  void loadData() {
    companyNameController.text = customer.companyName ?? '';
    companyAddressController.text = customer.companyAddress ?? '';
    companyTelephoneController.text = customer.companyTelephone ?? '';
    companyEmailController.text = customer.companyEmail ?? '';
    companyLogoController.text = customer.companyLogo ?? '';
  }

  void setUploadedImage(File? image) {
    uploadedImage = image;
    notifyListeners();
  }

  void setUploadImageError(String error) {
    uploadImageError = error;
    notifyListeners();
  }

  void setUploadImageLoading(bool value) {
    uploadImageLoading = value;
    notifyListeners();
  }

  void clearUploadedImage() {
    uploadedImage = null;
    uploadedImageCode = null;
    uploadImageError = null;
    showInitialImage = false; // Hide the initial image when cleared
    notifyListeners();
  }

  // Validation methods
  String? validateCompanyName(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l.companyNameRequired;
    }
    if (value.trim().length < 2) {
      return l.companyNameTooShort;
    }
    return null;
  }

  String? validateCompanyAddress(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l.companyAddressRequired;
    }
    if (value.trim().length < 10) {
      return l.companyAddressTooShort;
    }
    return null;
  }

  String? validateCompanyTelephone(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l.companyTelephoneRequired;
    }
    if (value.trim().length < 10) {
      return l.companyTelephoneTooShort;
    }
    return null;
  }

  String? validateCompanyEmail(String? value, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return l.pleaseEnterValidEmail;
    }
    return null;
  }

  Future<void> updateCompanyInfo({
    required BuildContext context,
    required SharedProvider sharedProvider,
  }) async {
    final l = AppLocalizations.of(context)!;

    // Check if form is valid
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Get current values from controllers
    final currentCompanyName = companyNameController.text.trim();
    final currentCompanyAddress = companyAddressController.text.trim();
    final currentCompanyTelephone = companyTelephoneController.text.trim();
    final currentCompanyEmail = companyEmailController.text.trim();

    // Check if anything changed
    final companyNameChanged =
        currentCompanyName != (customer.companyName ?? '');
    final companyAddressChanged =
        currentCompanyAddress != (customer.companyAddress ?? '');
    final companyTelephoneChanged =
        currentCompanyTelephone != (customer.companyTelephone ?? '');
    final companyEmailChanged =
        currentCompanyEmail != (customer.companyEmail ?? '');

    // If nothing changed, stop function
    if (!companyNameChanged &&
        !companyAddressChanged &&
        !companyTelephoneChanged &&
        !companyEmailChanged &&
        uploadedImageCode == null) {
      NavigationUtils.pop(context);
      return;
    }

    setUpdateCompanyInfoLoading(true);
    setUpdateCompanyInfoError(null);

    final result = await service.updateCompanyInfo(
      companyName: companyNameChanged ? currentCompanyName : null,
      companyAddress: companyAddressChanged ? currentCompanyAddress : null,
      companyTelephone:
          companyTelephoneChanged ? currentCompanyTelephone : null,
      email: companyEmailChanged ? currentCompanyEmail : null,
      logo: uploadedImageCode,
    );

    result.fold((error) => setUpdateCompanyInfoError(error), (customer) {
      sharedProvider.setCustomer(customer);
      showSuccessMessage(
        context: context,
        message: l.companyInfoUpdatedSuccessfully,
      );
      Navigator.of(context).pop();
    });
    setUpdateCompanyInfoLoading(false);
  }

  Future handleImageUpload(BuildContext context) async {
    try {
      final image = await selectImage(context: context);
      if (image != null) {
        setUploadedImage(image);
        await _uploadImage(image);
      }
    } catch (e) {
      setUploadImageError(
        AppLocalizations.of(context)!.failedSelectImageDifferentFormat,
      );
      debugPrint('Error in handleImageUpload: $e');
    }
  }

  Future _uploadImage(File file) async {
    setUploadImageLoading(true);
    setUploadImageError('');

    final result = await FileService().uploadImage(file);
    result.fold(
      (error) => setUploadImageError(error),
      (code) => setUploadedImageCode(code),
    );
    setUploadImageLoading(false);
  }

  @override
  void dispose() {
    companyNameController.dispose();
    companyAddressController.dispose();
    companyTelephoneController.dispose();
    companyEmailController.dispose();
    companyLogoController.dispose();
    companyNameFocusNode.dispose();
    companyAddressFocusNode.dispose();
    companyTelephoneFocusNode.dispose();
    companyEmailFocusNode.dispose();
    companyLogoFocusNode.dispose();
    super.dispose();
  }
}
