import 'package:vibration/vibration.dart';

class VibrationService {
  Future<void> vibrate() async {
    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator) {
      await Vibration.vibrate(duration: 150);
    }
  }
}