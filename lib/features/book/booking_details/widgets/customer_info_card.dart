import 'package:flutter/material.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.leaderPassenger,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 24),

        // Form Fields
        Row(
          children: [
            Expanded(
              flex: 1,
              child: BookingDropdown(
                value: provider.selectedTitle,
                items: provider.titleOptions,
                itemBuilder: (title) => title,
                onChanged: (title) => provider.updateTitle(title ?? 'Mr'),
                label: '',
                validator: (value) => provider.validateTitle(value, context),
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
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
          ],
        ),

        const SizedBox(height: 16),

        BookingTextfield(
          controller: provider.lastNameController,
          label: AppLocalizations.of(context)!.lastName,
          validator:
              (value) => provider.validateRequired(
                value,
                AppLocalizations.of(context)!.lastName,
              ),
        ),
        const SizedBox(height: 16),

        PhoneNumberField(
          focusNode: provider.phoneFocusNode,
          bgColor: Colors.white,
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
          validator: (value) => provider.validateEmail(value, context),
        ),
      ],
    );
  }
}
