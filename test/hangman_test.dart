import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/data/asset_answer_repository.dart';
import 'package:hangman_game/domain/enums/answer_category.dart';
import 'package:hangman_game/domain/enums/difficulty.dart';
import 'package:hangman_game/domain/enums/guess_outcome.dart';
import 'package:hangman_game/domain/enums/round_status.dart';
import 'package:hangman_game/domain/models/answer_entry.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';
import 'package:hangman_game/domain/models/session_stats.dart';
import 'package:hangman_game/domain/repositories/answer_repository.dart';

AnswerEntry entryOf(String answer) => AnswerEntry(
  answer: answer,
  category: AnswerCategory.animals,
  difficulty: Difficulty.easy,
  hints: const ['dica'],
);

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  }
}

void main() {
  group('HangmanRound', () {
    test('ignora acentuação e preserva a grafia original', () {
      final round = HangmanRound(entry: entryOf('CORAÇÃO'));

      expect(round.guess('A'), GuessOutcome.correct);

      final tilde = round.entry.characters.firstWhere((c) => c.display == 'Ã');
      expect(round.isRevealed(tilde), isTrue);
      expect(tilde.display, 'Ã');
    });

    test('espaços e hífens não são letras nem entram na vitória', () {
      final round = HangmanRound(entry: entryOf('SUL-AMERICANO ABC'));
      final structural = round.entry.characters.where((c) => !c.isLetter);

      expect(structural.every(round.isRevealed), isTrue);
      expect(round.entry.words.length, 2);
      expect(round.guess('-'), GuessOutcome.ignored);
      expect(round.guess(' '), GuessOutcome.ignored);
      expect(round.errors, 0);

      for (final letter in round.entry.letters) {
        round.guess(letter);
      }
      expect(round.status, RoundStatus.won);
      expect(round.errors, 0);
    });

    test('letra em várias palavras é revelada em todas as ocorrências', () {
      final round = HangmanRound(entry: entryOf('ARARA AZUL'));

      round.guess('A');

      final revealedAs = round.entry.characters
          .where((c) => c.base == 'A' && round.isRevealed(c))
          .length;
      expect(revealedAs, 4);
    });

    test('letra repetida não gera novo erro', () {
      final round = HangmanRound(entry: entryOf('ABC'));

      expect(round.guess('Z'), GuessOutcome.wrong);
      expect(round.guess('Z'), GuessOutcome.ignored);
      expect(round.errors, 1);
    });

    test('derrota no limite de erros e nenhuma tentativa depois', () {
      final round = HangmanRound(entry: entryOf('A'));

      for (final letter in ['B', 'C', 'D', 'E', 'F', 'G']) {
        round.guess(letter);
      }

      expect(round.status, RoundStatus.lost);
      expect(round.guess('A'), GuessOutcome.ignored);
      expect(round.status, RoundStatus.lost);
    });

    test('dica é registrada no máximo uma vez', () {
      final round = HangmanRound(entry: entryOf('ABC'));

      round.requestHint();
      round.requestHint();

      expect(round.hintUsed, isTrue);
    });
  });

  group('SessionStats', () {
    test('calcula totais e percentuais das rodadas concluídas', () {
      final stats = SessionStats();

      final won = HangmanRound(entry: entryOf('A'))
        ..requestHint()
        ..guess('A');
      final lost = HangmanRound(entry: entryOf('A'));
      for (final letter in ['B', 'C', 'D', 'E', 'F', 'G']) {
        lost.guess(letter);
      }
      stats
        ..register(won)
        ..register(lost);

      expect(stats.totalRounds, 2);
      expect(stats.wins, 1);
      expect(stats.losses, 1);
      expect(stats.totalErrors, 6);
      expect(stats.hintsUsed, 1);
      expect(stats.winPercentage, 50);
      expect(stats.lossPercentage, 50);
    });
  });

  group('Enums e JSON', () {
    test('valor inválido lança FormatException', () {
      expect(() => AnswerCategory.fromJson('cars'), throwsFormatException);
      expect(() => Difficulty.fromJson('impossible'), throwsFormatException);
    });

    test('repositório converte o JSON em objetos com enums', () async {
      const json = '''
{"entries":[{"answer":"GATO","category":"animals","difficulty":"easy","hints":["Mia."]}]}
''';
      final repository = AssetAnswerRepository(bundle: _FakeBundle(json));

      final entries = await repository.loadEntries();

      expect(entries.single.category, AnswerCategory.animals);
      expect(entries.single.difficulty, Difficulty.easy);
    });

    test('repositório rejeita JSON inconsistente', () async {
      const json = '{"entries":[{"answer":"GATO","category":"x"}]}';
      final repository = AssetAnswerRepository(bundle: _FakeBundle(json));

      expect(repository.loadEntries, throwsA(isA<AnswerDataException>()));
    });
  });
}
