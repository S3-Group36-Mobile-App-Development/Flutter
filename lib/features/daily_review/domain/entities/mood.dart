enum Mood {
  mal('Mal', '😔', ['Mal', 'Triste']),
  ansioso('Ansioso', '😟', ['Ansioso', 'Estresado']),
  neutral('Neutral', '😐', ['Neutral', 'Tranquilo']),
  calmado('Calmado', '😌', ['Calmado', 'Tranquilo']),
  muyBien('Muy bien', '😊', ['Muy bien', 'Feliz']);

  final String label;
  final String emoji;

  final List<String> backendNames;

  const Mood(this.label, this.emoji, this.backendNames);
}