import 'package:flutter/material.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';

/// Resultado da rodada: vitória ou derrota, com ações para continuar.
class RoundResultCard extends StatelessWidget {
  const RoundResultCard({
    super.key,
    required this.round,
    required this.onNewRound,
    required this.onChangeSelection,
    required this.onShowStats,
  });

  final HangmanRound round;
  final VoidCallback onNewRound;
  final VoidCallback onChangeSelection;
  final VoidCallback onShowStats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final won = round.isWon;
    final background = won ? scheme.primaryContainer : scheme.errorContainer;
    final foreground = won ? scheme.onPrimaryContainer : scheme.onErrorContainer;

    return Card(
      color: background,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    color: foreground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      won ? 'Você venceu!' : 'Você perdeu!',
                      style: textTheme.titleLarge?.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Resposta: ${round.entry.answer}'),
              Text('Erros: ${round.errors} de ${round.maxErrors}'),
              Text('Dica: ${round.hintUsed ? 'utilizada' : 'não utilizada'}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onNewRound,
                    icon: const Icon(Icons.replay),
                    label: const Text('Nova rodada'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onChangeSelection,
                    icon: const Icon(Icons.tune),
                    label: const Text('Categoria e nível'),
                  ),
                  TextButton.icon(
                    onPressed: onShowStats,
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Estatísticas'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
