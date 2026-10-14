/// Normalização usada exclusivamente para comparar letras.
///
/// A grafia original da resposta nunca é alterada: apenas a comparação ignora
/// acentuação e diferença entre maiúsculas e minúsculas.
abstract final class TextNormalizer {
  /// Alfabeto disponibilizado ao jogador.
  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Letras do alfabeto, uma por posição.
  static final List<String> letters = List<String>.unmodifiable(
    alphabet.split(''),
  );

  static final RegExp _combiningMarks = RegExp('[\u0300-\u036f]');

  static const Map<String, String> _accentMap = <String, String>{
    'Á': 'A',
    'À': 'A',
    'Â': 'A',
    'Ã': 'A',
    'Ä': 'A',
    'É': 'E',
    'È': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'Í': 'I',
    'Ì': 'I',
    'Î': 'I',
    'Ï': 'I',
    'Ó': 'O',
    'Ò': 'O',
    'Ô': 'O',
    'Õ': 'O',
    'Ö': 'O',
    'Ú': 'U',
    'Ù': 'U',
    'Û': 'U',
    'Ü': 'U',
    'Ç': 'C',
    'Ñ': 'N',
  };

  /// Retorna [character] em maiúsculo e sem acento (forma usada na comparação).
  static String normalize(String character) {
    final upper = character.toUpperCase().replaceAll(_combiningMarks, '');
    return _accentMap[upper] ?? upper;
  }

  /// Indica se [normalized] é uma letra do alfabeto (A-Z).
  static bool isLetter(String normalized) {
    return normalized.length == 1 && alphabet.contains(normalized);
  }

  /// Indica se [symbol] é uma marca de acentuação combinante (Unicode).
  static bool isCombiningMark(String symbol) {
    return symbol.isNotEmpty &&
        symbol.runes.first >= 0x0300 &&
        symbol.runes.first <= 0x036f;
  }
}
