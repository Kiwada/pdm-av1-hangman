/// Categorias fechadas de respostas definidas no conjunto de dados.
enum AnswerCategory {
  animals('Animais'),
  humanBody('Corpo humano'),
  sports('Esportes'),
  technology('Tecnologia');

  const AnswerCategory(this.label);

  /// Texto em português apresentado ao usuário.
  final String label;

  /// Converte o valor técnico presente no JSON.
  ///
  /// Lança [FormatException] quando o valor não pertence ao conjunto válido.
  static AnswerCategory fromJson(Object? value) {
    for (final category in values) {
      if (category.name == value) {
        return category;
      }
    }
    throw FormatException('Categoria inválida: "$value".');
  }
}
