import 'package:flutter/material.dart';
import 'package:hangman_game/application/game_controller.dart';

/// Estatísticas acumuladas durante a sessão.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.controller});

  final GameController controller;

  static String _percent(double value) =>
      '${value.toStringAsFixed(1).replaceAll('.', ',')}%';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final stats = controller.stats;
        return Scaffold(
          appBar: AppBar(title: const Text('Estatísticas da sessão')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (stats.totalRounds == 0)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Nenhuma rodada concluída nesta sessão.'),
                      ),
                    _StatTile(
                      icon: Icons.sports_esports,
                      label: 'Rodadas realizadas',
                      value: '${stats.totalRounds}',
                    ),
                    _StatTile(
                      icon: Icons.emoji_events,
                      label: 'Vitórias',
                      value:
                          '${stats.wins} (${_percent(stats.winPercentage)})',
                    ),
                    _StatTile(
                      icon: Icons.sentiment_dissatisfied,
                      label: 'Derrotas',
                      value:
                          '${stats.losses} (${_percent(stats.lossPercentage)})',
                    ),
                    _StatTile(
                      icon: Icons.close,
                      label: 'Total de erros',
                      value: '${stats.totalErrors}',
                    ),
                    _StatTile(
                      icon: Icons.lightbulb_outline,
                      label: 'Dicas utilizadas',
                      value: '${stats.hintsUsed}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
