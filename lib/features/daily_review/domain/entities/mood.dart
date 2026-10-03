enum Mood {
  feliz('Feliz', '😊'),
  tranquilo('Tranquilo', '😌'),
  ansioso('Ansioso', '😟'),
  triste('Triste', '😔'),
  estresado('Estresado', '😣');

  final String label;
  final String emoji;

  const Mood(this.label, this.emoji);
}