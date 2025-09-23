import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/phone_number_field.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_provider.dart';
import 'package:welcome_port/features/book/booking_details/widgets/reusable/booking_textfield.dart';
import 'package:welcome_port/features/book/booking_details/widgets/reusable/booking_dropdown.dart';

class CustomerInfoCard extends StatelessWidget {
  final BookingDetailsProvider provider;

  const CustomerInfoCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = provider.sharedProvider.customer != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/profile.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.customerInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form Fields
            BookingDropdown<String>(
              value: provider.selectedTitle,
              items: provider.titleOptions,
              itemBuilder: (title) => title,
              onChanged: (title) => provider.updateTitle(title ?? 'Mr'),
              label: '',
              validator: provider.validateTitle,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: BookingTextfield(
                    controller: provider.firstNameController,
                    label: AppLocalizations.of(context)!.firstName,
                    validator:
                        (value) => provider.validateRequired(
                          value,
                          AppLocalizations.of(context)!.firstName,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BookingTextfield(
                    controller: provider.lastNameController,
                    label: AppLocalizations.of(context)!.lastName,
                    validator:
                        (value) => provider.validateRequired(
                          value,
                          AppLocalizations.of(context)!.lastName,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            PhoneNumberField(
              focusNode: provider.phoneFocusNode,
              onPhoneNumberChanged: (phoneNumber) {
                provider.updatePhoneNumber(phoneNumber);
              },
              placeholder: AppLocalizations.of(context)!.phoneNumber,
              value:
                  provider.phoneController.text.isNotEmpty
                      ? provider.phoneController.text
                      : null,
            ),
            const SizedBox(height: 16),

            BookingTextfield(
              controller: provider.emailController,
              label: AppLocalizations.of(context)!.email,
              readOnly: isLoggedIn,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: provider.validateEmail,
            ),
          ],
        ),
      ),
    );
  }
}
