enum CardType { support, breathing, advice, game, protocol }

class RecommendationCard {
  final CardType type;
  final String title;
  final String message;
  final List<String> steps;
  final String? actionLabel;

  const RecommendationCard({
    required this.type,
    required this.title,
    required this.message,
    required this.steps,
    this.actionLabel,
  });
}