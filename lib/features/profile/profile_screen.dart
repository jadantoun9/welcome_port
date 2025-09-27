import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/auth_header.dart';
import 'package:welcome_port/core/widgets/custom_textfield.dart';
import 'package:welcome_port/core/widgets/error_dialog.dart';
import 'package:welcome_port/core/widgets/phone_number_field.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';
import 'package:welcome_port/features/profile/profile_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);

    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(customer: sharedProvider.customer!),
      child: _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileContent> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    final l = AppLocalizations.of(context)!;
    final isAgent = sharedProvider.customer?.type == CustomerType.agent;

    if (provider.updateProfileError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(
          context: context,
          message: provider.updateProfileError!,
        ).then((_) {
          provider.setUpdateProfileError(null);
        });
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: provider.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Personal Information title
                      Text(
                        l.personalInformation,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.updatePersonalDetails,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      if (isAgent) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l.profileReadOnlyForAgents,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              readOnly: isAgent,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l.pleaseEnterFirstName;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: provider.lastNameController,
                              focusNode: provider.lastNameFocusNode,
                              hintText: l.lastName,
                              icon: Icons.person,
                              readOnly: isAgent,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l.pleaseEnterLastName;
                                }
                                return null;
                              },
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
                        readOnly: isAgent,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return l.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      PhoneNumberField(
                        onPhoneNumberChanged: (value) {
                          // Convert PhoneNumber to proper string format
                          provider.phoneController.text = value.completeNumber;
                        },
                        value: provider.phoneController.text,
                        focusNode: provider.phoneFocusNode,
                        placeholder: l.phoneNumber,
                        readOnly: isAgent,
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
                      Expanded(child: Container()),
                      // Save button - hidden for agents
                      if (!isAgent) ...[
                        WideButton(
                          text: l.saveChanges,
                          isLoading: provider.updateProfileLoading,
                          onPressed:
                              () => provider.updateProfile(
                                context: context,
                                sharedProvider: sharedProvider,
                              ),
                        ),
                        const SizedBox(height: 10),
                        WideButton(
                          text: l.deleteAccount,
                          bgColor: Colors.red,
                          onPressed:
                              () => provider.deleteProfile(
                                context: context,
                                sharedProvider: sharedProvider,
                              ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
