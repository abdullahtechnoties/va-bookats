// lib/widgets/app_touchable.dart

import 'package:flutter/material.dart';

/// Visual-only press feedback: scales the child down while a pointer is down
/// and restores it on release. Does not consume taps, so the child keeps its
/// own tap handling (fields, GestureDetectors, InkWell, etc.).
class AppTouchable extends StatefulWidget {
  const AppTouchable({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 90),
  });

  final Widget child;
  final double pressedScale;
  final Duration duration;

  @override
  State<AppTouchable> createState() => _AppTouchableState();
}

class _AppTouchableState extends State<AppTouchable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    reverseDuration: widget.duration,
  );

  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
      );

  void _pressDown(_) {
    if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  void _pressUp(_) => _controller.reverse();

  void _pressCancel(_) => _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _pressDown,
      onPointerUp: _pressUp,
      onPointerCancel: _pressCancel,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
