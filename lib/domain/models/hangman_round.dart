import 'dart:collection';

import 'package:hangman_game/domain/enums/guess_outcome.dart';
import 'package:hangman_game/domain/enums/round_status.dart';
import 'package:hangman_game/domain/models/answer_character.dart';
import 'package:hangman_game/domain/models/answer_entry.dart';
import 'package:hangman_game/domain/services/text_normalizer.dart';

/// Estado e regras de uma rodada, independentes da interface.
class HangmanRound {
  HangmanRound({required this.entry, this.maxErrors = defaultMaxErrors})
    : assert(maxErrors > 0, 'maxErrors deve ser positivo');

  /// Quantidade de partes do boneco: cabeça, tronco, 2 braços e 2 pernas.
  static const int defaultMaxErrors = 6;

  final AnswerEntry entry;
  final int maxErrors;

  final Set<String> _guessedLetters = <String>{};
  int _errors = 0;
  bool _hintUsed = false;
  RoundStatus _status = RoundStatus.inProgress;

  int get errors => _errors;
  bool get hintUsed => _hintUsed;
  RoundStatus get status => _status;
  bool get isFinished => _status != RoundStatus.inProgress;
  bool get isWon => _status == RoundStatus.won;
  bool get isLost => _status == RoundStatus.lost;

  /// Letras (normalizadas) já tentadas, certas ou erradas.
  Set<String> get guessedLetters =>
      UnmodifiableSetView<String>(_guessedLetters);

  /// Dica associada à resposta.
  String get hint => entry.hints.first;

  /// Indica se [letter] (normalizada) pertence à resposta.
  bool isCorrectLetter(String letter) => entry.letters.contains(letter);

  /// Caracteres estruturais ficam sempre visíveis; letras só após acertadas
  /// (ou quando a rodada termina em derrota e a resposta é revelada).
  bool isRevealed(AnswerCharacter character) {
    return !character.isLetter ||
        _guessedLetters.contains(character.base) ||
        isLost;
  }

  /// Letra que o jogador não descobriu antes da derrota.
  bool isMissed(AnswerCharacter character) {
    return isLost &&
        character.isLetter &&
        !_guessedLetters.contains(character.base);
  }

  /// Aplica uma tentativa. Somente letras são aceitas; repetições e tentativas
  /// após o fim da rodada são ignoradas e não geram erro.
  GuessOutcome guess(String input) {
    if (isFinished || input.length != 1) {
      return GuessOutcome.ignored;
    }
    final letter = TextNormalizer.normalize(input);
    if (!TextNormalizer.isLetter(letter) || !_guessedLetters.add(letter)) {
      return GuessOutcome.ignored;
    }

    if (isCorrectLetter(letter)) {
      if (entry.letters.every(_guessedLetters.contains)) {
        _status = RoundStatus.won;
      }
      return GuessOutcome.correct;
    }

    _errors++;
    if (_errors >= maxErrors) {
      _status = RoundStatus.lost;
    }
    return GuessOutcome.wrong;
  }

  /// Registra o uso da dica (no máximo uma vez por rodada).
  void requestHint() {
    if (!isFinished) {
      _hintUsed = true;
    }
  }
}
