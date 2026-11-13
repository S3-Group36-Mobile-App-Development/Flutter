import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

class BubblePositionService {
  static const double _edgePadding = 12;

  Future<List<Offset>> generatePositions({
    required int count,
    required double bubbleSize,
    required Size fieldSize,
  }) {
    final width = fieldSize.width;
    final height = fieldSize.height;

    return Isolate.run(() {
      final random = Random();

      final double minX = _edgePadding;
      final double minY = _edgePadding;
      final double maxX = (width - bubbleSize - _edgePadding).clamp(
        minX,
        double.infinity,
      );
      final double maxY = (height - bubbleSize - _edgePadding).clamp(
        minY,
        double.infinity,
      );

      final minDistance = bubbleSize + 6;

      final List<double> dxs = [];
      final List<double> dys = [];

      for (int i = 0; i < count; i++) {
        double candidateX = 0;
        double candidateY = 0;

        for (int attempt = 0; attempt < 60; attempt++) {
          candidateX = minX + random.nextDouble() * (maxX - minX);
          candidateY = minY + random.nextDouble() * (maxY - minY);

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

      final List<Offset> positions = [];
      for (int i = 0; i < count; i++) {
        positions.add(Offset(dxs[i], dys[i]));
      }
      return positions;
    });
  }
}
