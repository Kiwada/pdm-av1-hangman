/// Níveis de dificuldade definidos no conjunto de dados.
enum Difficulty {
  easy('Fácil'),
  medium('Médio'),
  hard('Difícil');

  const Difficulty(this.label);

  /// Texto em português apresentado ao usuário.
  final String label;

  /// Converte o valor técnico presente no JSON.
  ///
  /// Lança [FormatException] quando o valor não pertence ao conjunto válido.
  static Difficulty fromJson(Object? value) {
    for (final difficulty in values) {
      if (difficulty.name == value) {
        return difficulty;
      }
    }
    throw FormatException('Dificuldade inválida: "$value".');
  }
}
