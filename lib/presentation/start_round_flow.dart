import 'package:flutter/material.dart';
import 'package:hangman_game/application/game_controller.dart';
import 'package:hangman_game/domain/enums/answer_category.dart';
import 'package:hangman_game/domain/enums/difficulty.dart';

/// Tenta iniciar uma rodada tratando o caso de respostas esgotadas.
///
/// Retorna `true` quando uma rodada foi iniciada.
Future<bool> tryStartRound(
  BuildContext context,
  GameController controller,
  AnswerCategory category,
  Difficulty difficulty,
) async {
  var outcome = controller.startRound(category, difficulty);

  if (outcome == StartOutcome.exhausted) {
    final reset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Respostas esgotadas'),
        content: Text(
          'Todas as respostas de "${category.label}" no nível '
          '"${difficulty.label}" já foram utilizadas nesta sessão.\n\n'
          'Deseja liberar essas respostas novamente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Escolher outra opção'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reiniciar respostas'),
          ),
        ],
      ),
    );
    if (reset != true) {
      return false;
    }
    controller.resetUsedAnswers(category, difficulty);
    outcome = controller.startRound(category, difficulty);
  }

  if (outcome == StartOutcome.unavailable && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não há respostas para essa categoria e nível.'),
      ),
    );
  }
  return outcome == StartOutcome.started;
}
