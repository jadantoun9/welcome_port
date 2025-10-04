import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';

class AmountInputBottomSheet extends StatefulWidget {
  final Function(double) onNextPressed;

  const AmountInputBottomSheet({super.key, required this.onNextPressed});

  @override
  State<AmountInputBottomSheet> createState() => _AmountInputBottomSheetState();
}

class _AmountInputBottomSheetState extends State<AmountInputBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Auto-focus the input field when the bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    final l = AppLocalizations.of(context)!;
    final text = _amountController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorText = l.pleaseEnterAmount;
      });
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorText = l.pleaseEnterValidAmount;
      });
      return;
    }

    if (amount < 1) {
      setState(() {
        _errorText = l.minimumTopUpAmount;
      });
      return;
    }

    // Clear error and proceed
    setState(() {
      _errorText = null;
    });
    widget.onNextPressed(amount);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

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
                  l.topUpAmount,
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
            const SizedBox(height: 24),

            // Amount Input Field
            TextField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (value) {
                // Clear error when user types
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              onSubmitted: (_) => _validateAndProceed(),
              decoration: InputDecoration(
                labelText: l.amount,
                hintText: l.enterAmount,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, top: 14),
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),
            const SizedBox(height: 24),

            // Next button
            WideButton(
              text: l.next,
              onPressed: _validateAndProceed,
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}
