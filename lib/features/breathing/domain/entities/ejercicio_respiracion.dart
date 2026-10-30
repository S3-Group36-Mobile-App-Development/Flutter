class EjercicioRespiracion {
  final String id;
  final String titulo;
  final String? descripcion;
  final int duracion;
  final Map<String, dynamic> patron;
  final bool vibra;
  final int usageCount;
  final double raitingAvg;
  final int ratingCoutn;

  EjercicioRespiracion({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.duracion,
    required this.patron,
    required this.vibra, 
    required this.usageCount, 
    required this.raitingAvg, 
    required this.ratingCoutn,
  });

}