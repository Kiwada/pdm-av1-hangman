import 'package:flutter/material.dart';
import 'package:hangman_game/core/team_members.dart';

/// Identificação da equipe responsável pelo desenvolvimento.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Jogo da Forca', style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                const Text(
                  'Programação para Dispositivos Móveis - UESPI\n'
                  'Desenvolvido com Flutter e Dart.',
                ),
                const SizedBox(height: 24),
                Text('Equipe de desenvolvimento', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final member in teamMembers)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(member),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
