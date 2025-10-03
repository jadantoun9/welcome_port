import 'package:dartz/dartz.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:welcome_port/features/notifications/models/notification_model.dart';

class NotificationsService {
  Future<Either<String, List<NotificationModel>>> getNotifications({
    required String limit,
    required String page,
  }) async {
    try {
      final response = await Singletons.dio.get(
        '/notifications/limit/$limit/page/$page',
      );
      final notifications =
          (response.data['data']['notifications'] as List<dynamic>)
              .map((notification) => NotificationModel.fromJson(notification))
              .toList();

      return Right(notifications);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
