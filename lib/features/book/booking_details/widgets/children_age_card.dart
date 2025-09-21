import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/features/book/booking_details/booking_details_provider.dart';
import 'package:welcome_port/features/book/booking_details/utils/utils.dart';
import 'package:welcome_port/features/book/booking_details/widgets/reusable/booking_dropdown.dart';

class ChildrenAgeCard extends StatelessWidget {
  final BookingDetailsProvider provider;

  const ChildrenAgeCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final infants = provider.preBookRequirementsResponse.passengers.infants;
    final children = provider.preBookRequirementsResponse.passengers.children;

    if (infants == 0 && children == 0) {
      return const SizedBox.shrink();
    }

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
                  child: Icon(
                    Icons.child_care,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Children & Infants Ages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Please specify ages for each child and infant',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Infants Section
            if (infants > 0) ...[
              _buildAgeSection(
                title: 'Infants',
                count: infants,
                ageRange: '0-2 years',
                icon: Icons.child_care,
                items: getInfantPossibleAges(),
                onChanged: (age, index) => provider.updateInfantAge(index, age),
                getCurrentValue: (index) => provider.getInfantAge(index),
                unitName: 'Infant',
              ),
              const SizedBox(height: 20),
            ],

            // Children Section
            if (children > 0) ...[
              _buildAgeSection(
                title: 'Children',
                count: children,
                ageRange: '3-15 years',
                icon: Icons.person,
                items: getChildPossibleAges(),
                onChanged: (age, index) => provider.updateChildAge(index, age),
                getCurrentValue: (index) => provider.getChildAge(index),
                unitName: 'Child',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAgeSection({
    required String title,
    required int count,
    required String ageRange,
    required IconData icon,
    required List<String> items,
    required Function(String?, int) onChanged,
    required String? Function(int) getCurrentValue,
    required String unitName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.grey[800]!, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  '$count $title ($ageRange)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Age Dropdowns
            ...List.generate(count, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index < count - 1 ? 12 : 0),
                child: BookingDropdown<String>(
                  value: getCurrentValue(index) ?? 'Select age',
                  items: ['Select age', ...items],
                  itemBuilder: (age) => age,
                  onChanged:
                      (age) =>
                          onChanged(age == 'Select age' ? null : age, index),
                  label: '$unitName ${index + 1} Age',
                  backgroundColor: Colors.white,
                  validator:
                      (value) => provider.validateAgeSelection(
                        value == 'Select age' ? null : value,
                        '$unitName ${index + 1}',
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
