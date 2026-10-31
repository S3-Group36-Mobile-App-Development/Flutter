import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

class BubblePositionService {
  Future<List<Offset>> generatePositions({
    required int count,
    required double bubbleSize,
    required Size fieldSize,
  }) {
    final width = fieldSize.width;
    final height = fieldSize.height;

    return Isolate.run(() {
      final random = Random();

      final maxX = (width - bubbleSize).clamp(0.0, double.infinity);
      final maxY = (height - bubbleSize).clamp(0.0, double.infinity);
      final minDistance = bubbleSize + 6;

      final List<double> dxs = [];
      final List<double> dys = [];

      for (int i = 0; i < count; i++) {
        double candidateX = 0;
        double candidateY = 0;

        for (int attempt = 0; attempt < 60; attempt++) {
          candidateX = random.nextDouble() * maxX;
          candidateY = random.nextDouble() * maxY;

          bool overlaps = false;
          for (int j = 0; j < dxs.length; j++) {
            final ddx = dxs[j] - candidateX;
            final ddy = dys[j] - candidateY;
            if (sqrt(ddx * ddx + ddy * ddy) < minDistance) {
              overlaps = true;
              break;
            }
          }

          if (!overlaps) break;
        }

        dxs.add(candidateX);
        dys.add(candidateY);
      }

      return List<Offset>.generate(count, (i) => Offset(dxs[i], dys[i]));
    });
  }
}
