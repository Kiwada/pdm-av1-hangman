import 'package:flutter/material.dart';
import 'package:hangman_game/application/game_controller.dart';
import 'package:hangman_game/data/asset_answer_repository.dart';
import 'package:hangman_game/domain/repositories/answer_repository.dart';
import 'package:hangman_game/presentation/screens/setup_screen.dart';
import 'package:hangman_game/core/theme/app_theme.dart';

/// Raiz da aplicação: cria o controlador e carrega o JSON dos assets.
class HangmanApp extends StatefulWidget {
  const HangmanApp({super.key, this.repository});

  /// Permite substituir a fonte de dados (útil em testes).
  final AnswerRepository? repository;

  @override
  State<HangmanApp> createState() => _HangmanAppState();
}

class _HangmanAppState extends State<HangmanApp> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      repository: widget.repository ?? AssetAnswerRepository(),
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Forca',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      home: _HomeGate(controller: _controller),
    );
  }
}

class _HomeGate extends StatelessWidget {
  const _HomeGate({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        switch (controller.loadStatus) {
          case LoadStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case LoadStatus.failure:
            return _LoadErrorView(
              message: controller.errorMessage ?? 'Erro desconhecido.',
              onRetry: controller.load,
            );
          case LoadStatus.ready:
            return SetupScreen(controller: controller);
        }
      },
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Não foi possível carregar os dados do jogo.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
