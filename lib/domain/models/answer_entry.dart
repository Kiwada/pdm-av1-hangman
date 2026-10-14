import 'package:hangman_game/domain/enums/answer_category.dart';
import 'package:hangman_game/domain/enums/difficulty.dart';
import 'package:hangman_game/domain/models/answer_character.dart';
import 'package:hangman_game/domain/services/text_normalizer.dart';

/// Uma resposta do jogo: uma palavra ou uma expressão com várias palavras.
class AnswerEntry {
  AnswerEntry({
    required this.answer,
    required this.category,
    required this.difficulty,
    required List<String> hints,
  }) : hints = List<String>.unmodifiable(hints),
       characters = _parseCharacters(answer);

  /// Converte um objeto do JSON, validando os campos obrigatórios.
  ///
  /// Lança [FormatException] quando o conteúdo é inconsistente.
  factory AnswerEntry.fromJson(Map<String, dynamic> json) {
    final answer = json['answer'];
    if (answer is! String || answer.trim().isEmpty) {
      throw const FormatException('Campo "answer" ausente ou vazio.');
    }

    final hints = json['hints'];
    if (hints is! List ||
        hints.isEmpty ||
        hints.any((hint) => hint is! String || hint.trim().isEmpty)) {
      throw FormatException(
        'Campo "hints" deve ser uma lista não vazia de textos '
        '(resposta "$answer").',
      );
    }

    final entry = AnswerEntry(
      answer: answer.trim(),
      category: AnswerCategory.fromJson(json['category']),
      difficulty: Difficulty.fromJson(json['difficulty']),
      hints: hints.cast<String>(),
    );
    if (entry.letters.isEmpty) {
      throw FormatException('A resposta "$answer" não contém letras.');
    }
    return entry;
  }

  /// Texto completo da resposta, com a grafia original.
  final String answer;
  final AnswerCategory category;
  final Difficulty difficulty;
  final List<String> hints;

  /// Todos os caracteres da resposta, na ordem original.
  final List<AnswerCharacter> characters;

  /// Letras distintas (normalizadas) que o jogador precisa descobrir.
  late final Set<String> letters = Set<String>.unmodifiable(
    characters.where((c) => c.isLetter).map((c) => c.base),
  );

  /// Palavras da resposta (separadas por espaços). Hífens e demais símbolos
  /// permanecem dentro da palavra em que aparecem.
  late final List<List<AnswerCharacter>> words = _splitWords(characters);

  static List<AnswerCharacter> _parseCharacters(String text) {
    final units = <String>[];
    for (final rune in text.trim().runes) {
      final symbol = String.fromCharCode(rune);
      if (TextNormalizer.isCombiningMark(symbol) && units.isNotEmpty) {
        units[units.length - 1] += symbol;
      } else {
        units.add(symbol);
      }
    }
    return List<AnswerCharacter>.unmodifiable(
      units.map(AnswerCharacter.fromDisplay),
    );
  }

  static List<List<AnswerCharacter>> _splitWords(
    List<AnswerCharacter> characters,
  ) {
    final words = <List<AnswerCharacter>>[];
    var current = <AnswerCharacter>[];
    for (final character in characters) {
      if (character.isSpace) {
        if (current.isNotEmpty) {
          words.add(current);
          current = <AnswerCharacter>[];
        }
      } else {
        current.add(character);
      }
    }
    if (current.isNotEmpty) {
      words.add(current);
    }
    return words;
  }
}
