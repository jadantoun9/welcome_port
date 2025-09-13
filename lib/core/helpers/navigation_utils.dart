import 'package:flutter/material.dart';

class NavigationUtils {
  static Future<T?> push<T>(BuildContext context, Widget page) async {
    return await Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<T?> clearAndPush<T>(BuildContext context, Widget page) async {
    // Use pushAndRemoveUntil as the primary method which is safer
    // as it doesn't depend on the state of the navigation stack
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false, // This removes all previous routes
    );
    return null;
  }

  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void pushVertically(BuildContext context, Widget page) {
    Navigator.of(context).push(_createRoute(page));
  }

  static Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(
        milliseconds: 300,
      ), // Adjusted duration
    );
  }
}
