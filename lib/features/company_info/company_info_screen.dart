import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/auth_header.dart';
import 'package:welcome_port/core/widgets/custom_textfield.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/core/widgets/phone_number_field.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/features/company_info/company_info_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/features/company_info/widgets/file_upload_box.dart';

class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);

    return ChangeNotifierProvider(
      create:
          (context) => CompanyInfoProvider(customer: sharedProvider.customer!),
      child: _CompanyInfoContent(sharedProvider: sharedProvider),
    );
  }
}

class _CompanyInfoContent extends StatefulWidget {
  final SharedProvider sharedProvider;

  const _CompanyInfoContent({required this.sharedProvider});

  @override
  State<_CompanyInfoContent> createState() => _CompanyInfoContentState();
}

class _CompanyInfoContentState extends State<_CompanyInfoContent> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompanyInfoProvider>(context);
    final l = AppLocalizations.of(context)!;

    if (provider.updateCompanyInfoError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(
          context: context,
          message: provider.updateCompanyInfoError!,
        ).then((_) {
          provider.setUpdateCompanyInfoError(null);
        });
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Form(
              key: provider.formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add padding at top to account for header
                    const SizedBox(height: 175),
                    const SizedBox(height: 10),
                    // Company Information title
                    Text(
                      l.companyInformation,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.enterCompanyDetails,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    // Company Name field
                    Text(
                      l.companyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: provider.companyNameController,
                      focusNode: provider.companyNameFocusNode,
                      hintText: l.companyName,
                      icon: Icons.business,
                      validator:
                          (value) =>
                              provider.validateCompanyName(value, context),
                    ),
                    const SizedBox(height: 20),
                    // Company Address field
                    Text(
                      l.address,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: provider.companyAddressController,
                      focusNode: provider.companyAddressFocusNode,
                      hintText: l.companyAddress,
                      icon: Icons.location_on,
                      maxLines: 3,
                      validator:
                          (value) =>
                              provider.validateCompanyAddress(value, context),
                    ),
                    const SizedBox(height: 20),
                    // Company Telephone field
                    Text(
                      l.telephone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PhoneNumberField(
                      onPhoneNumberChanged: (value) {
                        // Convert PhoneNumber to proper string format
                        provider.companyTelephoneController.text =
                            value.completeNumber;
                      },
                      value: provider.companyTelephoneController.text,
                      focusNode: provider.companyTelephoneFocusNode,
                      placeholder: l.companyTelephone,
                      validator: (value) {
                        // Company telephone is required, validate it
                        if (value == null || value.number.isEmpty) {
                          return l.companyTelephoneRequired;
                        }

                        // Use the library's validation method
                        if (!value.isValidNumber()) {
                          return l.pleaseEnterValidPhoneNumber;
                        }

                        return null; // Valid phone number
                      },
                    ),
                    const SizedBox(height: 20),
                    // Company Email field (optional)
                    Text(
                      l.email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: provider.companyEmailController,
                      focusNode: provider.companyEmailFocusNode,
                      hintText: l.companyEmail,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
                              provider.validateCompanyEmail(value, context),
                    ),
                    const SizedBox(height: 20),
                    // Company Logo field (optional)
                    Text(
                      l.logo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FileUploadBox(
                      title: l.tapToUploadPhoto,
                      onTap: () => provider.handleImageUpload(context),
                      isLoading: provider.uploadImageLoading,
                      code: provider.uploadedImageCode,
                      imagePath: provider.uploadedImage?.path,
                      initialImageUrl: provider.customer.companyLogo,
                      showInitialImage: provider.showInitialImage,
                      onClear: () => provider.clearUploadedImage(),
                      errorText: provider.uploadImageError,
                    ),
                    const SizedBox(height: 30),
                    // Save button
                    WideButton(
                      text: l.updateCompanyInfo,
                      isLoading: provider.updateCompanyInfoLoading,
                      onPressed:
                          () => provider.updateCompanyInfo(
                            context: context,
                            sharedProvider: widget.sharedProvider,
                          ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          // Header overlay
          Positioned(top: 0, left: 0, right: 0, child: AuthHeader()),
        ],
      ),
    );
  }
}
