import 'package:flutter/material.dart';

class BreathingCircle extends StatelessWidget {
  final String phase;
  final bool isBreathing;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.isBreathing,
  });

  
  static const Map<String, String> _images = {
    'Inhala': 'lib/core/assets/images/INHALE.png',
    'Sostén': 'lib/core/assets/images/HOLD.png',
    'Exhala': 'lib/core/assets/images/EXHALE.png',
  };

  static const String _idleImage = 'lib/core/assets/images/INHALE.png';

  @override
  Widget build(BuildContext context) {
    final shouldExpand = phase == 'Inhala' || phase == 'Sostén';
    final size = shouldExpand ? 220.0 : 150.0;

    final imagePath = isBreathing ? (_images[phase] ?? _idleImage) : _idleImage;

    return AnimatedContainer(
      duration: Duration(seconds: phase == 'Exhala' ? 3 : 2),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Image.asset(
          imagePath,
          key: ValueKey(imagePath), 
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}