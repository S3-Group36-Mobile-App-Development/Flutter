import 'package:zenmind/features/cuestionario/data/models/cuestionario_entry.dart';

class Racha {
  final int actual;
  final int mejor;

  const Racha({required this.actual, required this.mejor});

  static const Racha vacia = Racha(actual: 0, mejor: 0);
}

class PerfilCuestionario {
  final Racha racha;
  final bool consentimiento;

  const PerfilCuestionario({required this.racha, required this.consentimiento});
}

Racha calcularRacha(List<String> fechas, DateTime ahora) {
  if (fechas.isEmpty) return Racha.vacia;

  final dias = fechas.map(_diaUtc).toList();
  final hoy = _diaUtc(fechaLocalDe(ahora));

  var mejor = 1;
  var seguidos = 1;
  for (var i = 1; i < dias.length; i++) {
    final esConsecutivo = dias[i - 1].difference(dias[i]).inDays == 1;
    seguidos = esConsecutivo ? seguidos + 1 : 1;
    if (seguidos > mejor) mejor = seguidos;
  }

  var actual = 0;
  if (hoy.difference(dias.first).inDays <= 1) {
    actual = 1;
    for (var i = 1; i < dias.length; i++) {
      if (dias[i - 1].difference(dias[i]).inDays != 1) break;
      actual++;
    }
  }

  return Racha(actual: actual, mejor: mejor);
}

DateTime _diaUtc(String fecha) => DateTime.parse('${fecha}T00:00:00Z');
