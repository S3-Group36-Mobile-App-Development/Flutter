import 'package:vibration/vibration.dart';

class VibrationService {
  Future<void> vibrate() async {
    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator == true) {
      await Vibration.cancel();
      await Vibration.vibrate(duration: 150);
    }
  }

  Future<void> cancel() async {
    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator == true) {
      await Vibration.cancel();
    }
  }
}
