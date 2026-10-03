import 'package:flutter/foundation.dart';

import '../../domain/entities/mood.dart';
import '../../domain/entities/recommendation_card.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/daily_review_repository.dart';
import '../../domain/services/card_recommender.dart';

enum CheckinStatus { loading, form, saving, done }

class DailyReviewViewModel extends ChangeNotifier {
  final DailyReviewRepository _repository;
  final bool _isGuest;
  final CardRecommender _recommender = const CardRecommender();

  DailyReviewViewModel({required this._repository, required this._isGuest});

  CheckinStatus _status = CheckinStatus.loading;
  Mood? _selectedMood;
  String _note = '';
  RecommendationCard? _card;
  String? _message;
  Streak _streak = Streak.empty;
  bool _disposed = false;

  CheckinStatus get status => _status;
  Mood? get selectedMood => _selectedMood;
  RecommendationCard? get card => _card;
  String? get message => _message;
  Streak get streak => _streak;

  bool get canSave => _selectedMood != null && _status == CheckinStatus.form;

  Future<void> initialize() async {
    final todayMood = await _repository.getTodayMood();

    if (todayMood != null) {
      _card = _recommender.recommend(todayMood);
      _message = 'Ya hiciste tu check-in de hoy. Vuelve mañana.';
      _status = CheckinStatus.done;
    } else {
      _status = CheckinStatus.form;
    }

    notifyListeners();

    await _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await _repository.getStreak(isGuest: _isGuest);

    if (_disposed) return;

    _streak = streak;
    notifyListeners();
  }

  void selectMood(Mood mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void updateNote(String value) {
    _note = value;
  }

  Future<void> save() async {
    if (!canSave) return;

    _status = CheckinStatus.saving;
    notifyListeners();

    final note = _note.trim();

    try {
      final result = await _repository.saveCheckin(
        mood: _selectedMood!,
        note: note.isEmpty ? null : note,
        isGuest: _isGuest,
      );

      _message = _messageFor(result);
    } catch (_) {
      _message = 'No pudimos sincronizar, pero tu card está lista.';
    }

    _card = _recommender.recommend(_selectedMood!);
    _status = CheckinStatus.done;
    notifyListeners();

    await _loadStreak();
  }

  String? _messageFor(SaveResult result) {
    if (_isGuest) return 'Modo invitado: se guardó solo en este teléfono.';
    if (result.alreadyCheckedInToday) return 'Tu check-in de hoy ya estaba registrado.';
    if (!result.syncedWithServer) return 'No pudimos sincronizar, pero tu card está lista.';
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}