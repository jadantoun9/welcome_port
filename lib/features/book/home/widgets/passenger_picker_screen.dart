import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/widgets/wide_button.dart';

class PassengerData {
  final int adults;
  final int children;
  final int infants;

  PassengerData({
    required this.adults,
    required this.children,
    required this.infants,
  });
}

class PassengerPickerScreen extends StatefulWidget {
  final int initialAdults;
  final int initialChildren;
  final int initialInfants;

  const PassengerPickerScreen({
    super.key,
    this.initialAdults = 1,
    this.initialChildren = 0,
    this.initialInfants = 0,
  });

  @override
  State<PassengerPickerScreen> createState() => _PassengerPickerScreenState();
}

class _PassengerPickerScreenState extends State<PassengerPickerScreen> {
  late int adults;
  late int children;
  late int infants;

  @override
  void initState() {
    super.initState();
    adults = widget.initialAdults;
    children = widget.initialChildren;
    infants = widget.initialInfants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        leading: Container(),
        title: Text(
          AppLocalizations.of(context)!.passengers,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPassengerCounter(
                  AppLocalizations.of(context)!.adults,
                  AppLocalizations.of(context)!.adultsAge,
                  adults,
                  (count) => setState(() => adults = count),
                  isAdults: true,
                ),
                const SizedBox(height: 24),
                _buildPassengerCounter(
                  AppLocalizations.of(context)!.children,
                  AppLocalizations.of(context)!.childrenAge,
                  children,
                  (count) => setState(() => children = count),
                ),
                const SizedBox(height: 24),
                _buildPassengerCounter(
                  AppLocalizations.of(context)!.infants,
                  AppLocalizations.of(context)!.infantsAge,
                  infants,
                  (count) => setState(() => infants = count),
                ),
                Spacer(),
                WideButton(
                  text: AppLocalizations.of(context)!.done,
                  onPressed: () {
                    Navigator.of(context).pop(
                      PassengerData(
                        adults: adults,
                        children: children,
                        infants: infants,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerCounter(
    String label,
    String subtitle,
    int count,
    Function(int) onChanged, {
    bool isAdults = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    if (isAdults && count > 1) {
                      onChanged(count - 1);
                    } else if (!isAdults && count > 0) {
                      onChanged(count - 1);
                    }
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color:
                          (isAdults && count <= 1) || (!isAdults && count <= 0)
                              ? Colors.grey[300]
                              : AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.remove,
                      color:
                          (isAdults && count <= 1) || (!isAdults && count <= 0)
                              ? Colors.grey[500]
                              : Colors.white,
                      size: 23,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onChanged(count + 1);
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 23),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: Colors.grey[200]!),
      ],
    );
  }
}
