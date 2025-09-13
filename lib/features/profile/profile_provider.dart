import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/providers/shared_provider.dart';
import 'package:welcome_port/core/widgets/success_message.dart';
import 'package:welcome_port/features/otp/otp_screen.dart';
import 'package:welcome_port/features/profile/profile_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileProvider extends ChangeNotifier {
  final CustomerModel customer;

  ProfileProvider({required this.customer}) {
    loadData();
  }

  final service = ProfileService();

  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();

  bool updateProfileLoading = false;
  String? updateProfileError;

  void setUpdateProfileLoading(bool value) {
    updateProfileLoading = value;
    notifyListeners();
  }

  void setUpdateProfileError(String? value) {
    updateProfileError = value;
    notifyListeners();
  }

  void loadData() {
    firstNameController.text = customer.firstName;
    lastNameController.text = customer.lastName;
    emailController.text = customer.email;
    phoneController.text = customer.phone;
  }

  Future<void> updateProfile({
    required BuildContext context,
    required SharedProvider sharedProvider,
  }) async {
    final l = AppLocalizations.of(context)!;

    // Check if form is valid
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Get current values from controllers
    final currentFirstName = firstNameController.text.trim();
    final currentLastName = lastNameController.text.trim();
    final currentEmail = emailController.text.trim();
    final currentPhone = phoneController.text.trim();

    // Check if anything changed
    final firstNameChanged = currentFirstName != customer.firstName;
    final lastNameChanged = currentLastName != customer.lastName;
    final emailChanged = currentEmail != customer.email;
    final phoneChanged = currentPhone != customer.phone;

    // If nothing changed, stop function
    if (!firstNameChanged &&
        !lastNameChanged &&
        !emailChanged &&
        !phoneChanged) {
      NavigationUtils.pop(context);

      return;
    }

    setUpdateProfileLoading(true);
    setUpdateProfileError(null);

    final result = await service.updateProfile(
      firstName: firstNameChanged ? currentFirstName : null,
      lastName: lastNameChanged ? currentLastName : null,
      email: emailChanged ? currentEmail : null, // Don't update email
      phone: phoneChanged ? currentPhone : null,
    );

    result.fold((error) => setUpdateProfileError(error), (customer) {
      sharedProvider.setCustomer(customer);
      if (emailChanged) {
        NavigationUtils.push(
          context,
          OTPScreen(email: currentEmail, isEditProfile: true),
        );
      } else {
        showSuccessMessage(
          context: context,
          message: l.profileUpdatedSuccessfully,
        );
        Navigator.of(context).pop();
      }
    });
    setUpdateProfileLoading(false);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }
}
