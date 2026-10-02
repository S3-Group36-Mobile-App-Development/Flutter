import 'package:flutter/material.dart';

class BreathingCircle extends StatelessWidget {
  final String phase;
  final bool isBreathing;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.isBreathing,
  });

  @override
  Widget build(BuildContext context) {
    final shouldExpand = phase == 'Inhala';

    final size = shouldExpand ? 220.0 : 150.0;

    return AnimatedContainer(
      duration: Duration(
        seconds: phase == 'Exhala' ? 3 : 2,
      ),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(
          alpha: 0.2,
        ),
        border: Border.all(
          color: Colors.blue,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          isBreathing ? phase : 'Respira',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}