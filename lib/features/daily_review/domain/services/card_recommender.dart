import '../entities/mood.dart';
import '../entities/recommendation_card.dart';

/// Smart feature. Contesta pregunta tipo 2
class CardRecommender {
  const CardRecommender();

  RecommendationCard recommend(Mood mood) {
    switch (mood) {
      case Mood.mal:
        return const RecommendationCard(
          type: CardType.support,
          title: 'No tienes que pasarlo solo/a',
          message: 'Hablar con alguien de confianza ayuda a bajar la carga.',
          steps: [
            'Escríbele o llama a alguien de tu red de apoyo.',
            'Línea 192, opción 4: orientación en salud mental.',
            'Línea 123: emergencias.',
          ],
        );

      case Mood.ansioso:
        return const RecommendationCard(
          type: CardType.breathing,
          title: 'Tómate 2 minutos para respirar',
          message: 'Una respiración lenta ayuda a bajar la ansiedad.',
          steps: [
            'Inhala por la nariz durante 4 segundos.',
            'Sostén el aire 4 segundos.',
            'Exhala por la boca durante 6 segundos.',
          ],
          actionLabel: 'Ir a Respira',
        );

      case Mood.neutral:
        return const RecommendationCard(
          type: CardType.advice,
          title: 'Pausa consciente',
          message: 'Pequeñas pausas evitan que el estrés se acumule.',
          steps: [
            'Detente 60 segundos.',
            'Enfócate solo en tu respiración.',
            'Repite cada vez que cambies de tarea.',
          ],
        );

      case Mood.calmado:
        return const RecommendationCard(
          type: CardType.game,
          title: 'Mantén esa calma',
          message: 'Un juego corto y tranquilo ayuda a conservar este estado.',
          steps: [
            'Elige un juego de la sección Juegos.',
            'Juega 5 minutos sin presión.',
          ],
        );

      case Mood.muyBien:
        return const RecommendationCard(
          type: CardType.protocol,
          title: '¡Qué bien! Aprende a ayudar a otros',
          message:
          'Hoy que te sientes bien es un buen momento para aprender '
              'cómo acompañar a alguien en crisis.',
          steps: [
            'Escucha sin juzgar.',
            'Pregunta directamente si está en riesgo.',
            'Si hay riesgo, llama al 123 junto a la persona.',
          ],
        );
    }
  }
}