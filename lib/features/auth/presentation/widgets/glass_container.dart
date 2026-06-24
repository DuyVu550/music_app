import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;
  final Color color;

  const GlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 24.0,
    this.blur = 15.0,
    this.color = Colors.white10,
  });

  @override
  Widget build(BuildContext context) {
    final innerContainer = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: kDebugMode
          ? innerContainer
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: innerContainer,
            ),
    );
  }
}
