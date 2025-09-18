import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/widgets/auth_header.dart';
import 'package:welcome_port/core/widgets/custom_textfield.dart';
import 'package:welcome_port/core/widgets/error_display.dart';
import 'package:welcome_port/core/widgets/phone_number_field.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/features/become_an_agent/become_an_agent_provider.dart';

class BecomeAnAgentScreen extends StatelessWidget {
  const BecomeAnAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BecomeAnAgentProvider(),
      child: BecomeAnAgentContent(),
    );
  }
}

class BecomeAnAgentContent extends StatefulWidget {
  const BecomeAnAgentContent({super.key});

  @override
  State<BecomeAnAgentContent> createState() => _BecomeAnAgentContentState();
}

class _BecomeAnAgentContentState extends State<BecomeAnAgentContent> {
  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes to trigger rebuild when focus changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BecomeAnAgentProvider>(
        context,
        listen: false,
      );
      provider.firstNameFocusNode.addListener(() => setState(() {}));
      provider.lastNameFocusNode.addListener(() => setState(() {}));
      provider.emailFocusNode.addListener(() => setState(() {}));
      provider.phoneFocusNode.addListener(() => setState(() {}));
      provider.passwordFocusNode.addListener(() => setState(() {}));
      provider.confirmPasswordFocusNode.addListener(() => setState(() {}));
      provider.companyNameFocusNode.addListener(() => setState(() {}));
      provider.companyAddressFocusNode.addListener(() => setState(() {}));
      provider.companyTelephoneFocusNode.addListener(() => setState(() {}));
      provider.instagramUsernameFocusNode.addListener(() => setState(() {}));
      provider.websiteFocusNode.addListener(() => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BecomeAnAgentProvider>(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: provider.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Main Title
                      Text(
                        l.becomeAgent,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.joinOurNetworkOfTrustedAgents,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),

                      // Personal Information Section
                      Text(
                        l.personalInformation,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.enterPersonalDetails,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),

                      // First Name and Last Name row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: provider.firstNameController,
                              focusNode: provider.firstNameFocusNode,
                              hintText: l.firstName,
                              icon: Icons.person,
                              errorText: provider.firstNameError,
                              validator:
                                  (value) => provider.validateFirstName(
                                    value,
                                    context,
                                  ),
                              onChanged:
                                  (value) => provider.setFirstName(value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: provider.lastNameController,
                              focusNode: provider.lastNameFocusNode,
                              hintText: l.lastName,
                              icon: Icons.person,
                              errorText: provider.lastNameError,
                              validator:
                                  (value) =>
                                      provider.validateLastName(value, context),
                              onChanged: (value) => provider.setLastName(value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email field
                      CustomTextField(
                        controller: provider.emailController,
                        focusNode: provider.emailFocusNode,
                        hintText: l.email,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        errorText: provider.emailError,
                        validator:
                            (value) => provider.validateEmail(value, context),
                        onChanged: (value) => provider.setEmail(value),
                      ),
                      const SizedBox(height: 20),

                      // Phone field
                      PhoneNumberField(
                        onPhoneNumberChanged: (value) {
                          // Convert PhoneNumber to proper string format
                          provider.phoneController.text = value.completeNumber;
                        },
                        value: provider.phoneController.text,
                        focusNode: provider.phoneFocusNode,
                        placeholder: l.phoneNumber,
                        validator: (value) {
                          // Phone number is optional, but if provided, validate it
                          if (value == null || value.number.isEmpty) {
                            return null; // Optional field, no error
                          }

                          // Use the library's validation method
                          if (!value.isValidNumber()) {
                            return l.pleaseEnterValidPhoneNumber;
                          }

                          return null; // Valid phone number
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      CustomTextField(
                        controller: provider.passwordController,
                        focusNode: provider.passwordFocusNode,
                        hintText: l.password,
                        icon: Icons.lock_outline,
                        obscureText: provider.obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            provider.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: provider.togglePasswordVisibility,
                        ),
                        errorText: provider.passwordError,
                        validator:
                            (value) =>
                                provider.validatePassword(value, context),
                        onChanged: (value) => provider.setPassword(value),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password field
                      CustomTextField(
                        controller: provider.confirmPasswordController,
                        focusNode: provider.confirmPasswordFocusNode,
                        hintText: l.confirmPassword,
                        icon: Icons.lock_outline,
                        obscureText: provider.obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            provider.obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: provider.toggleConfirmPasswordVisibility,
                        ),
                        errorText: provider.confirmPasswordError,
                        validator:
                            (value) => provider.validateConfirmPassword(
                              value,
                              context,
                            ),
                        onChanged:
                            (value) => provider.setConfirmPassword(value),
                      ),
                      const SizedBox(height: 40),

                      // Company Information Section
                      Text(
                        l.companyInformation,
                        style: const TextStyle(
                          fontSize: 19,
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
                      CustomTextField(
                        controller: provider.companyNameController,
                        focusNode: provider.companyNameFocusNode,
                        hintText: l.companyName,
                        icon: Icons.business,
                        errorText: provider.companyNameError,
                        validator:
                            (value) =>
                                provider.validateCompanyName(value, context),
                        onChanged: (value) => provider.setCompanyName(value),
                      ),
                      const SizedBox(height: 20),

                      // Website field
                      CustomTextField(
                        controller: provider.websiteController,
                        focusNode: provider.websiteFocusNode,
                        hintText: l.companyWebsite,
                        icon: Icons.language,
                        keyboardType: TextInputType.url,
                        errorText: provider.websiteError,
                        validator:
                            (value) => provider.validateWebsite(value, context),
                        onChanged: (value) => provider.setWebsite(value),
                      ),
                      const SizedBox(height: 20),

                      // Instagram Username field
                      CustomTextField(
                        controller: provider.instagramUsernameController,
                        focusNode: provider.instagramUsernameFocusNode,
                        hintText: l.instagramUsername,
                        icon: Icons.photo_camera,
                        errorText: provider.instagramUsernameError,
                        validator:
                            (value) => provider.validateInstagramUsername(
                              value,
                              context,
                            ),
                        onChanged:
                            (value) => provider.setInstagramUsername(value),
                      ),
                      const SizedBox(height: 20),

                      // Company Address field
                      CustomTextField(
                        controller: provider.companyAddressController,
                        focusNode: provider.companyAddressFocusNode,
                        hintText: l.companyAddress,
                        icon: Icons.location_on,
                        maxLines: 3,
                        errorText: provider.companyAddressError,
                        validator:
                            (value) =>
                                provider.validateCompanyAddress(value, context),
                        onChanged: (value) => provider.setCompanyAddress(value),
                      ),
                      const SizedBox(height: 20),

                      // Company Telephone field
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
                      const SizedBox(height: 40),
                      // Show API error message if any
                      if (provider.registerError.isNotEmpty)
                        ErrorDisplay(
                          message: provider.registerError,
                          margin: const EdgeInsets.only(bottom: 20),
                        ),
                      const SizedBox(height: 10),

                      // Register button
                      WideButton(
                        text: l.registerAsAgent,
                        isLoading: provider.isLoading,
                        onPressed: () => provider.register(context),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
