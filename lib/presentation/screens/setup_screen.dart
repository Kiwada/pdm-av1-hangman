
import 'package:flutter/material.dart';
import 'package:hangman_game/application/game_controller.dart';
import 'package:hangman_game/core/theme/app_colors.dart';
import 'package:hangman_game/domain/enums/answer_category.dart';
import 'package:hangman_game/domain/enums/difficulty.dart';
import 'package:hangman_game/presentation/screens/about_screen.dart';
import 'package:hangman_game/presentation/screens/game_screen.dart';
import 'package:hangman_game/presentation/screens/stats_screen.dart';
import 'package:hangman_game/presentation/start_round_flow.dart';

/// Configuração da partida: categoria, dificuldade e início da rodada.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  AnswerCategory? _category;
  Difficulty? _difficulty;

  bool get _canStart => _category != null && _difficulty != null;

  Future<void> _startRound() async {
    final started = await tryStartRound(
      context,
      widget.controller,
      _category!,
      _difficulty!,
    );
    if (!started || !mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'JOGO DA FORCA',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: AppColors.text,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart),
                color: AppColors.primary,
                tooltip: 'Estatísticas',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StatsScreen(controller: controller),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                color: AppColors.primary,
                tooltip: 'Sobre',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Nova rodada', style: textTheme.titleLarge),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Categoria', style: textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final category
                                  in controller.availableCategories)
                                ChoiceChip(
                                  label: Text(category.label),
                                  selected: _category == category,
                                  onSelected: (_) =>
                                      setState(() => _category = category),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Nível de dificuldade',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final difficulty
                                  in controller.availableDifficulties)
                                ChoiceChip(
                                  label: Text(difficulty.label),
                                  selected: _difficulty == difficulty,
                                  onSelected:
                                      _category != null &&
                                          controller.totalCount(
                                                _category!,
                                                difficulty,
                                              ) ==
                                              0
                                      ? null
                                      : (_) => setState(
                                          () => _difficulty = difficulty,
                                        ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SelectionSummary(
                            controller: controller,
                            category: _category,
                            difficulty: _difficulty,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _canStart ? _startRound : null,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('INICIAR RODADA'),
                          ),
                        ],
                      ),
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

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({
    required this.controller,
    required this.category,
    required this.difficulty,
  });

  final GameController controller;
  final AnswerCategory? category;
  final Difficulty? difficulty;

  @override
  Widget build(BuildContext context) {
    final category = this.category;
    final difficulty = this.difficulty;
    final hasBoth = category != null && difficulty != null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OPÇÕES SELECIONADAS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text('Categoria: ${category?.label ?? 'não selecionada'}'),
            Text('Nível: ${difficulty?.label ?? 'não selecionado'}'),
            if (hasBoth)
              Text(
                'Respostas disponíveis: '
                '${controller.remainingCount(category, difficulty)} de '
                '${controller.totalCount(category, difficulty)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
