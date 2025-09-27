import 'package:flutter/material.dart';
// import 'package:welcome_port/core/constant/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/constant/colors.dart';
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
              child: CustomCachedImage(
                imageUrl: widget.quote.vehicle.image,
                contain: true,
              ),
            ),
          ),

          // Car details section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.quote.vehicle.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people_alt,
                              size: 18,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '1-${widget.quote.vehicle.maxPassengers}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.work_outline_rounded,
                                  size: 18,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.quote.vehicle.maxLuggage}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.quote.isOneWay
                              ? AppLocalizations.of(context)!.totalOneWayPrice
                              : AppLocalizations.of(
                                context,
                              )!.totalRoundTripPrice,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.quote.priceDiscounted == null
                              ? widget.quote.priceFormatted
                              : widget.quote.priceDiscountedFormatted,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            // color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 22,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              AppLocalizations.of(context)!.freeCancellation,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.grey[500],
                              size: 22,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              AppLocalizations.of(context)!.taxesIncluded,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
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
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(16),
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

  // removed unused chip builder
}
