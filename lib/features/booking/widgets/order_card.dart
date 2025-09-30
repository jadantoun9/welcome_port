import 'package:flutter/material.dart';
import 'package:welcome_port/core/constant/colors.dart';
import 'package:welcome_port/core/helpers/navigation_utils.dart';
import 'package:welcome_port/core/widgets/custom_cached_image.dart';
import 'package:welcome_port/core/widgets/inkwell_with_opacity.dart';
import 'package:welcome_port/features/book/home/home_provider.dart';
import 'package:welcome_port/features/order_details/booking_details_screen.dart';
import 'package:welcome_port/features/booking/models/order.dart';

class BookingCard extends StatelessWidget {
  final OrderModel order;

  const BookingCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkwellWithOpacity(
      onTap: () {
        NavigationUtils.push(
          context,
          BookingDetailsScreen(orderReference: order.reference),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: CustomCachedImage(
                imageUrl: order.vehicle.image,
                contain: true,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("#${order.reference}"),
                Text(
                  "${order.from} ${order.tripType == TripType.roundTrip ? "⇆" : "➝"} ${order.to}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      order.outwardDate,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (order.tripType == TripType.roundTrip) ...[
                      const SizedBox(width: 5),
                      Text(
                        order.returnDate,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 2),
                Text(
                  order.tripTypeFormatted.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Text(
                        order.statusFormatted.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              order.statusFormatted.toLowerCase() == "confirmed"
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      InkwellWithOpacity(
                        onTap: () {
                          NavigationUtils.push(
                            context,
                            BookingDetailsScreen(
                              orderReference: order.reference,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: AppColors.primaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          child: Text(
                            "View",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
