import 'package:flutter/material.dart';

class InkwellWithOpacity extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double clickedOpacity;
  final BorderRadius? borderRadius;

  const InkwellWithOpacity({
    super.key,
    required this.child,
    required this.onTap,
    this.clickedOpacity = 0.6,
    this.borderRadius,
  });

  @override
  State<InkwellWithOpacity> createState() => _InkwellWithOpacityState();
}

class _InkwellWithOpacityState extends State<InkwellWithOpacity> {
  double opacity = 1;

  setOpacity(double value) {
    if (mounted) {
      setState(() {
        opacity = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: widget.borderRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTapCancel: () {
        setOpacity(1);
      },
      onTapDown: (_) {
        setOpacity(widget.clickedOpacity);
      },
      onTapUp: (_) {
        setState(() {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() {
                opacity = 1.0;
              });
            }
          });
        });
      },
      onTap: widget.onTap,
      child: Opacity(opacity: opacity, child: widget.child),
    );
  }
}
