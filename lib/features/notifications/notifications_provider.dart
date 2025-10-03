import 'package:flutter/material.dart';
import 'package:welcome_port/features/notifications/models/notification_model.dart';
import 'package:welcome_port/features/notifications/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _notificationsService = NotificationsService();

  List<NotificationModel> notifications = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  final int limit = 40;
  String? error;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      currentPage = 1;
      notifications.clear();
      hasMoreData = true;
    }

    isLoading = true;
    error = null;
    print("is loading: $isLoading");
    notifyListeners();

    final result = await _notificationsService.getNotifications(
      limit: limit.toString(),
      page: currentPage.toString(),
    );

    result.fold(
      (error) {
        this.error = error;
        isLoading = false;
        notifyListeners();
      },
      (newNotifications) {
        if (refresh) {
          notifications = newNotifications;
        } else {
          notifications.addAll(newNotifications);
        }

        hasMoreData = newNotifications.length == limit;
        currentPage++;
        isLoading = false;
        print("is loading: $isLoading");
        this.error = null;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreNotifications() async {
    if (!hasMoreData || isLoading) return;
    await loadNotifications();
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }
}
