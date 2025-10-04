import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:welcome_port/core/widgets/error_card.dart';
import 'package:welcome_port/core/widgets/loader.dart';
import 'package:welcome_port/features/notifications/notifications_provider.dart';
import 'package:welcome_port/features/notifications/widgets/notification_card.dart';

class NotificationsList extends StatelessWidget {
  final NotificationsProvider provider;

  const NotificationsList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.error != null) {
      return _buildErrorWidget();
    }

    if (provider.notifications.isEmpty && !provider.isLoading) {
      return _buildEmptyWidget();
    }

    // Show skeleton when loading and no notifications yet
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const NotificationsSkeleton(itemCount: 5);
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.notifications.length,
          itemBuilder: (context, index) {
            final notification = provider.notifications[index];
            return NotificationCard(notification: notification);
          },
        ),
        // Show loader when loading more (not initial load)
        if (provider.isLoading && provider.notifications.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Loader(color: Colors.black),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ErrorCard(
                title: l10n.failedToLoadNotifications,
                message: provider.error ?? 'Unknown error',
                onRetry: () => provider.refreshNotifications(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Container(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 48,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noNotificationsYet,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.yourNotificationsWillAppearHere,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NotificationsSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationsSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => _buildSkeletonItem()),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon skeleton
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                // Description skeleton
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                // Date skeleton
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
