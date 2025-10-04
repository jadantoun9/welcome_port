import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/models/setting.dart';
import 'package:welcome_port/core/widgets/custom_cached_image.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final VoidCallback onPayPressed;
  final Function(PaymentMethod) onPaymentMethodSelected;
  final ValueNotifier<bool> isLoadingNotifier;

  const PaymentMethodBottomSheet({
    super.key,
    required this.paymentMethods,
    required this.onPayPressed,
    required this.onPaymentMethodSelected,
    required this.isLoadingNotifier,
  });

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  PaymentMethod? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l?.selectPaymentMethod ?? 'Select Payment Method',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment methods list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children:
                      widget.paymentMethods.map((paymentMethod) {
                        final isSelected =
                            selectedPaymentMethod?.code == paymentMethod.code;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedPaymentMethod = paymentMethod;
                            });
                            widget.onPaymentMethodSelected(paymentMethod);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primaryColor.withOpacity(.1)
                                      : Colors.white,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primaryColor
                                        : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Payment method image
                                if (paymentMethod.image.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CustomCachedImage(
                                        imageUrl: paymentMethod.image,
                                        contain: true,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 16),

                                // Payment method name
                                Expanded(
                                  child: Text(
                                    paymentMethod.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isSelected
                                              ? AppColors.primaryColor
                                              : Colors.black87,
                                    ),
                                  ),
                                ),

                                // Radio button
                                Radio<String>(
                                  value: paymentMethod.code,
                                  groupValue: selectedPaymentMethod?.code,
                                  activeColor: AppColors.primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPaymentMethod = paymentMethod;
                                    });
                                    widget.onPaymentMethodSelected(
                                      paymentMethod,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pay button
            ValueListenableBuilder<bool>(
              valueListenable: widget.isLoadingNotifier,
              builder: (context, isLoading, child) {
                return WideButton(
                  text: l?.pay ?? 'Pay',
                  onPressed: widget.onPayPressed,
                  isLoading: isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
