import 'package:flutter/material.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';
import 'package:hangman_game/domain/services/text_normalizer.dart';

/// Teclado com apenas as letras do alfabeto.
///
/// Letras já usadas ficam desabilitadas e coloridas (verde = acerto,
/// vermelho riscado = erro).
class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    super.key,
    required this.round,
    required this.onLetterSelected,
  });

  final HangmanRound round;
  final ValueChanged<String> onLetterSelected;

  static const int _columns = 7;
  static const double _spacing = 6;
  static const double _maxKeyWidth = 56;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final keyWidth =
            ((constraints.maxWidth - _spacing * (_columns - 1)) / _columns)
                .clamp(0.0, _maxKeyWidth)
                .toDouble();

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final letter in TextNormalizer.letters)
              SizedBox(
                width: keyWidth,
                height: 46,
                child: _buildKey(letter, scheme),
              ),
          ],
        );
      },
    );
  }

  Widget _buildKey(String letter, ColorScheme scheme) {
    final guessed = round.guessedLetters.contains(letter);
    final correct = guessed && round.isCorrectLetter(letter);
    final wrong = guessed && !correct;

    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        padding: EdgeInsets.zero,
        disabledBackgroundColor: correct
            ? Colors.green.shade700
            : (wrong ? scheme.error : null),
        disabledForegroundColor: correct
            ? Colors.white
            : (wrong ? scheme.onError : null),
      ),
      onPressed: (guessed || round.isFinished)
          ? null
          : () => onLetterSelected(letter),
      child: Text(
        letter,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          decoration: wrong ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
