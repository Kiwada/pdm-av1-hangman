import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hangman_game/application/game_controller.dart';
import 'package:hangman_game/domain/enums/guess_outcome.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';
import 'package:hangman_game/presentation/screens/stats_screen.dart';
import 'package:hangman_game/presentation/start_round_flow.dart';
import 'package:hangman_game/presentation/widgets/answer_display.dart';
import 'package:hangman_game/presentation/widgets/hangman_figure.dart';
import 'package:hangman_game/presentation/widgets/hint_panel.dart';
import 'package:hangman_game/presentation/widgets/letter_keyboard.dart';
import 'package:hangman_game/presentation/widgets/round_result_card.dart';

/// Tela principal do jogo.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.controller});

  final GameController controller;

  Future<bool> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Abandonar rodada?'),
        content: const Text(
          'A rodada atual não será contabilizada nas estatísticas e a '
          'resposta continuará marcada como utilizada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continuar jogando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Abandonar'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  void _openStats(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatsScreen(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final round = controller.round;
        if (round == null) {
          return const Scaffold(
            body: Center(child: Text('Nenhuma rodada em andamento.')),
          );
        }

        return PopScope(
          canPop: round.isFinished,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) {
              return;
            }
            final leave = await _confirmLeave(context);
            if (leave && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Rodada'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  tooltip: 'Estatísticas',
                  onPressed: () => _openStats(context),
                ),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final landscape =
                      constraints.maxWidth >= 560 &&
                      constraints.maxWidth > constraints.maxHeight;
                  return landscape
                      ? _LandscapeLayout(
                          controller: controller,
                          round: round,
                          onShowStats: () => _openStats(context),
                        )
                      : _PortraitLayout(
                          controller: controller,
                          round: round,
                          figureHeight: math.min(
                            220,
                            constraints.maxHeight * 0.28,
                          ),
                          onShowStats: () => _openStats(context),
                        );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.controller,
    required this.round,
    required this.figureHeight,
    required this.onShowStats,
  });

  final GameController controller;
  final HangmanRound round;
  final double figureHeight;
  final VoidCallback onShowStats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RoundHeader(round: round),
          const SizedBox(height: 12),
          SizedBox(
            height: figureHeight,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: HangmanFigure(
                  errors: round.errors,
                  maxErrors: round.maxErrors,
                ),
              ),
            ),
          ),
          _GuessFeedbackText(feedback: controller.lastGuess),
          const SizedBox(height: 8),
          AnswerDisplay(round: round),
          const SizedBox(height: 16),
          HintPanel(round: round, onRequestHint: controller.requestHint),
          const SizedBox(height: 16),
          _Controls(
            controller: controller,
            round: round,
            onShowStats: onShowStats,
          ),
        ],
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({
    required this.controller,
    required this.round,
    required this.onShowStats,
  });

  final GameController controller;
  final HangmanRound round;
  final VoidCallback onShowStats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RoundHeader(round: round),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: HangmanFigure(
                        errors: round.errors,
                        maxErrors: round.maxErrors,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GuessFeedbackText(feedback: controller.lastGuess),
                const SizedBox(height: 8),
                AnswerDisplay(round: round),
                const SizedBox(height: 16),
                HintPanel(round: round, onRequestHint: controller.requestHint),
                const SizedBox(height: 16),
                _Controls(
                  controller: controller,
                  round: round,
                  onShowStats: onShowStats,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.controller,
    required this.round,
    required this.onShowStats,
  });

  final GameController controller;
  final HangmanRound round;
  final VoidCallback onShowStats;

  @override
  Widget build(BuildContext context) {
    if (!round.isFinished) {
      return LetterKeyboard(
        round: round,
        onLetterSelected: controller.guess,
      );
    }
    return RoundResultCard(
      round: round,
      onNewRound: () => tryStartRound(
        context,
        controller,
        round.entry.category,
        round.entry.difficulty,
      ),
      onChangeSelection: () => Navigator.of(context).pop(),
      onShowStats: onShowStats,
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({required this.round});

  final HangmanRound round;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(
              avatar: const Icon(Icons.category_outlined, size: 18),
              label: Text(round.entry.category.label),
            ),
            Chip(
              avatar: const Icon(Icons.speed, size: 18),
              label: Text(round.entry.difficulty.label),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Erros: ${round.errors} de ${round.maxErrors}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: round.errors / round.maxErrors,
          color: scheme.error,
          backgroundColor: scheme.surfaceContainerHighest,
        ),
      ],
    );
  }
}

class _GuessFeedbackText extends StatelessWidget {
  const _GuessFeedbackText({required this.feedback});

  final GuessFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    final feedback = this.feedback;
    if (feedback == null) {
      return const SizedBox(height: 24);
    }
    final correct = feedback.outcome == GuessOutcome.correct;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 24,
      child: Center(
        child: Text(
          correct
              ? 'Letra ${feedback.letter}: acertou!'
              : 'Letra ${feedback.letter}: não existe na resposta.',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: correct ? Colors.green.shade600 : scheme.error,
          ),
        ),
      ),
    );
  }
}
