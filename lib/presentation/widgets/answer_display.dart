import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hangman_game/core/theme/app_colors.dart';
import 'package:hangman_game/domain/models/answer_character.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';

/// Resposta parcialmente revelada, com as palavras visualmente separadas.
///
/// Letras ocultas aparecem em células com sublinhado; espaços separam as
/// palavras e hífens/pontuação aparecem desde o início.
class AnswerDisplay extends StatelessWidget {
  const AnswerDisplay({super.key, required this.round});

  final HangmanRound round;

  static const double _spacing = 7;
  static const double _minCell = 38;
  static const double _maxCell = 55;

  String get _semanticsLabel {
    final parts = round.entry.characters.map((c) {
      if (round.isRevealed(c)) {
        return c.display;
      }
      return 'letra oculta';
    });
    return 'Resposta: ${parts.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final words = round.entry.words;
    final longestWord = words.map((w) => w.length).reduce(math.max);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth / longestWord - _spacing)
            .clamp(_minCell, _maxCell)
            .toDouble();

        return Semantics(
          label: _semanticsLabel,
          excludeSemantics: true,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: cellWidth * 0.35,
            runSpacing: 10,
            children: [
              for (final word in words)
                Wrap(
                  spacing: _spacing,
                  runSpacing: 10,
                  children: [
                    for (final character in word)
                      _CharacterCell(
                        character: character,
                        round: round,
                        width: cellWidth,
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CharacterCell extends StatelessWidget {
  const _CharacterCell({
    required this.character,
    required this.round,
    required this.width,
  });

  final AnswerCharacter character;
  final HangmanRound round;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width;
    final revealed = round.isRevealed(character);
    final missed = round.isMissed(character);

    if (!character.isLetter) {
      return SizedBox(
        width: width * 0.6,
        height: height,
        child: Center(
          child: Text(
            character.display,
            style: TextStyle(
              color: AppColors.text,
              fontFamily: 'PressStart2P',
              fontSize: width * 0.4,
            ),
          ),
        ),
      );
    }

    final backgroundColor = missed
        ? AppColors.wrongSurface
        : revealed
        ? AppColors.primaryDark
        : AppColors.surface;

    final borderColor = missed
        ? AppColors.error
        : revealed
        ? AppColors.primary
        : AppColors.border;

    final foregroundColor = missed
        ? AppColors.error
        : revealed
        ? AppColors.primary
        : AppColors.muted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (revealed)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                character.display,
                style: TextStyle(
                  color: foregroundColor,
                  fontFamily: 'PressStart2P',
                  fontSize: width * 0.36,
                ),
              ),
            ),
          Positioned(
            bottom: 6,
            left: 7,
            right: 7,
            child: Container(
              height: 2,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}