import 'package:flutter/material.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';

/// Botão de dica e, depois de solicitada, o texto da dica.
class HintPanel extends StatelessWidget {
  const HintPanel({
    super.key,
    required this.round,
    required this.onRequestHint,
  });

  final HangmanRound round;
  final VoidCallback onRequestHint;

  @override
  Widget build(BuildContext context) {
    if (round.hintUsed) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.lightbulb),
          title: const Text('Dica'),
          subtitle: Text(round.hint),
        ),
      );
    }
    if (round.isFinished) {
      return const SizedBox.shrink();
    }
    return Align(
      child: OutlinedButton.icon(
        onPressed: onRequestHint,
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Pedir dica'),
      ),
    );
  }
}
