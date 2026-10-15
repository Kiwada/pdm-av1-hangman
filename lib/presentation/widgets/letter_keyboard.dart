import 'package:flutter/material.dart';
import 'package:hangman_game/core/theme/app_colors.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';
import 'package:hangman_game/domain/services/text_normalizer.dart';

/// Teclado com apenas as letras do alfabeto.
///
/// Letras já usadas permanecem visíveis:
/// verde = acerto, vermelho = erro.
class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    super.key,
    required this.round,
    required this.onLetterSelected,
  });

  final HangmanRound round;
  final ValueChanged<String> onLetterSelected;

  static const int _columns = 6;
  static const double _spacing = 7;
  static const double _maxKeyWidth = 49;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyWidth =
            ((constraints.maxWidth - _spacing * (_columns - 1)) / _columns)
                .clamp(0.0, _maxKeyWidth)
                .toDouble();

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: _spacing,
          runSpacing: 10,
          children: [
            for (final letter in TextNormalizer.letters)
              SizedBox(
                width: keyWidth,
                height: 47,
                child: _LetterButton(
                  letter: letter,
                  state: _stateFor(letter),
                  enabled:
                      !round.guessedLetters.contains(letter) &&
                      !round.isFinished,
                  onPressed: () => onLetterSelected(letter),
                ),
              ),
          ],
        );
      },
    );
  }

  _LetterState _stateFor(String letter) {
    if (!round.guessedLetters.contains(letter)) {
      return _LetterState.available;
    }

    return round.isCorrectLetter(letter)
        ? _LetterState.correct
        : _LetterState.wrong;
  }
}

class _LetterButton extends StatelessWidget {
  const _LetterButton({
    required this.letter,
    required this.state,
    required this.enabled,
    required this.onPressed,
  });

  final String letter;
  final _LetterState state;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = switch (state) {
      _LetterState.correct => (
        background: AppColors.primaryDark,
        border: AppColors.primary,
        text: AppColors.primary,
      ),
      _LetterState.wrong => (
        background: AppColors.wrongSurface,
        border: AppColors.error,
        text: AppColors.error,
      ),
      _LetterState.available => (
        background: AppColors.elevatedSurface,
        border: AppColors.border,
        text: AppColors.unavailable,
      ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                color: palette.text,
                fontFamily: 'PressStart2P',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _LetterState { available, correct, wrong }