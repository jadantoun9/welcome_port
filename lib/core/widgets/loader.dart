import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color? color;
  final double? size;

  const Loader({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
              height: size ?? 25,
              width: size ?? 25,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(color ?? Colors.white),
              ),
            ),
    );
  }
}
