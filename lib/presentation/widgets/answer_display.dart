import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hangman_game/domain/models/answer_character.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';

/// Resposta parcialmente revelada, com as palavras visualmente separadas.
///
/// Letras ocultas aparecem como sublinhado; espaços separam as palavras e
/// hífens/pontuação aparecem desde o início, sem ação do jogador.
class AnswerDisplay extends StatelessWidget {
  const AnswerDisplay({super.key, required this.round});

  final HangmanRound round;

  static const double _spacing = 4;
  static const double _minCell = 22;
  static const double _maxCell = 38;

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
            spacing: cellWidth * 0.9,
            runSpacing: 14,
            children: [
              for (final word in words)
                Wrap(
                  spacing: _spacing,
                  runSpacing: 6,
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
    final scheme = Theme.of(context).colorScheme;
    final height = width * 1.3;

    // Hífens e demais símbolos: exibidos automaticamente, sem sublinhado.
    if (!character.isLetter) {
      return SizedBox(
        width: width * 0.6,
        height: height,
        child: Center(
          child: Text(
            character.display,
            style: TextStyle(
              fontSize: width * 0.7,
              fontWeight: FontWeight.bold,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final revealed = round.isRevealed(character);
    final missed = round.isMissed(character);
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: missed ? scheme.error : scheme.onSurface,
            width: 3,
          ),
        ),
      ),
      child: revealed
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                character.display,
                style: TextStyle(
                  fontSize: width * 0.8,
                  fontWeight: FontWeight.bold,
                  color: missed ? scheme.error : scheme.onSurface,
                ),
              ),
            )
          : null,
    );
  }
}
