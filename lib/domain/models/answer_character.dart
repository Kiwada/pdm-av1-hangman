import 'package:hangman_game/domain/services/text_normalizer.dart';

/// Um caractere da resposta, preservando a grafia original.
///
/// Letras ([isLetter]) são ocultadas no início da rodada e podem ser
/// reveladas por tentativas. Os demais caracteres (espaços, hífens,
/// apóstrofos etc.) são estruturais: aparecem desde o início e nunca são
/// tentativas do jogador.
class AnswerCharacter {
  const AnswerCharacter({required this.display, required this.base});

  /// Cria o caractere calculando sua forma normalizada.
  factory AnswerCharacter.fromDisplay(String display) {
    return AnswerCharacter(
      display: display,
      base: TextNormalizer.normalize(display),
    );
  }

  /// Grafia original, exibida na interface (ex.: `Ã`).
  final String display;

  /// Forma normalizada usada apenas na comparação (ex.: `A`).
  final String base;

  /// Verdadeiro quando o caractere é uma letra (A-Z após normalização).
  bool get isLetter => TextNormalizer.isLetter(base);

  /// Verdadeiro quando o caractere é um espaço em branco.
  bool get isSpace => display.trim().isEmpty;
}
