import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/models/quote.dart';
import 'package:welcome_port/core/widgets/custom_cached_image.dart';
import 'package:welcome_port/core/widgets/loader.dart';

class QuoteBox extends StatefulWidget {
  final Quote quote;
  final Future<void> Function(Quote) onBookNow;

  const QuoteBox({super.key, required this.quote, required this.onBookNow});

  @override
  State<QuoteBox> createState() => _QuoteBoxState();
}

class _QuoteBoxState extends State<QuoteBox> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomCachedImage(
                    imageUrl: widget.quote.vehicle.image,
                    contain: true,
                  ),
                ),
              ),
            ),
          ),

          // Car details section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating and capacity in a more modern layout
                Row(
                  children: [
                    // Duration
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey[600],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(widget.quote.durationInMinutes / 60).round()}h ${widget.quote.durationInMinutes % 60}m',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildCapacityChip(
                          icon: Icons.person_outline,
                          text: '1-${widget.quote.vehicle.maxPassengers}',
                          color: Colors.amber[600]!,
                        ),
                        const SizedBox(width: 8),
                        _buildCapacityChip(
                          icon: Icons.work_outline_rounded,
                          text: '${widget.quote.vehicle.maxLuggage}',
                          color: AppColors.primaryColor,
                        ),
                        if (widget.quote.vehicle.isShared) ...[
                          const SizedBox(width: 8),
                          _buildCapacityChip(
                            icon: Icons.people_outline,
                            text: AppLocalizations.of(context)!.shared,
                            color: Colors.orange[600]!,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Vehicle name with accent
                Text(
                  widget.quote.vehicle.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.quote.vehicle.description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with gradient
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey[300]!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Simple price row
                Row(
                  children: [
                    // Price label and amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.totalPrice,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.quote.priceDiscounted == null)
                          Text(
                            widget.quote.priceFormatted,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        if (widget.quote.priceDiscounted != null)
                          Row(
                            children: [
                              Text(
                                widget.quote.priceDiscountedFormatted,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.quote.priceFormatted,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600]!,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Book Now button with gradient
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await widget.onBookNow(widget.quote);
                      setState(() {
                        isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        isLoading
                            ? const Loader()
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.bookThisVehicle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
