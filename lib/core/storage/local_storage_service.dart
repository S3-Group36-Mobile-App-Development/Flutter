import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _guestModeKey = 'guest_mode';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<void> setGuestMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_guestModeKey, enabled);
  }

  Future<bool> isGuestMode() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_guestModeKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_onboardingCompletedKey, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> clearGuestMode() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_guestModeKey);
  }
}
