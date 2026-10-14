import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hangman_game/domain/enums/answer_category.dart';
import 'package:hangman_game/domain/enums/difficulty.dart';
import 'package:hangman_game/domain/enums/guess_outcome.dart';
import 'package:hangman_game/domain/models/answer_entry.dart';
import 'package:hangman_game/domain/models/hangman_round.dart';
import 'package:hangman_game/domain/models/session_stats.dart';
import 'package:hangman_game/domain/repositories/answer_repository.dart';

/// Situação do carregamento dos dados.
enum LoadStatus { loading, ready, failure }

/// Resultado do pedido de início de rodada.
enum StartOutcome {
  /// Rodada iniciada.
  started,

  /// Todas as respostas da combinação já foram usadas na sessão.
  exhausted,

  /// Não existem respostas para a combinação.
  unavailable,
}

/// Última tentativa válida, usada para dar feedback ao jogador.
class GuessFeedback {
  const GuessFeedback({required this.letter, required this.outcome});

  final String letter;
  final GuessOutcome outcome;
}

/// Coordena a sessão: dados, sorteio sem repetição, rodada atual e estatísticas.
class GameController extends ChangeNotifier {
  GameController({required AnswerRepository repository, Random? random})
    : _repository = repository,
      _random = random ?? Random();

  final AnswerRepository _repository;
  final Random _random;

  /// Estatísticas acumuladas da sessão.
  final SessionStats stats = SessionStats();

  final Set<AnswerEntry> _usedEntries = <AnswerEntry>{};
  List<AnswerEntry> _entries = const <AnswerEntry>[];
  LoadStatus _loadStatus = LoadStatus.loading;
  String? _errorMessage;
  HangmanRound? _round;
  GuessFeedback? _lastGuess;
  bool _resultRecorded = false;

  LoadStatus get loadStatus => _loadStatus;
  String? get errorMessage => _errorMessage;
  HangmanRound? get round => _round;
  GuessFeedback? get lastGuess => _lastGuess;

  /// Categorias que existem no conjunto de dados.
  List<AnswerCategory> get availableCategories => AnswerCategory.values
      .where((category) => _entries.any((e) => e.category == category))
      .toList();

  /// Níveis que existem no conjunto de dados.
  List<Difficulty> get availableDifficulties => Difficulty.values
      .where((difficulty) => _entries.any((e) => e.difficulty == difficulty))
      .toList();

  /// Carrega e desserializa o JSON.
  Future<void> load() async {
    _loadStatus = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _entries = await _repository.loadEntries();
      _loadStatus = LoadStatus.ready;
    } on AnswerDataException catch (error) {
      _loadStatus = LoadStatus.failure;
      _errorMessage = error.message;
    }
    notifyListeners();
  }

  Iterable<AnswerEntry> _matching(
    AnswerCategory category,
    Difficulty difficulty,
  ) {
    return _entries.where(
      (e) => e.category == category && e.difficulty == difficulty,
    );
  }

  /// Total de respostas da combinação.
  int totalCount(AnswerCategory category, Difficulty difficulty) =>
      _matching(category, difficulty).length;

  /// Respostas da combinação ainda não usadas nesta sessão.
  int remainingCount(AnswerCategory category, Difficulty difficulty) =>
      _matching(category, difficulty)
          .where((e) => !_usedEntries.contains(e))
          .length;

  /// Sorteia uma resposta ainda não usada e inicia a rodada.
  StartOutcome startRound(AnswerCategory category, Difficulty difficulty) {
    if (totalCount(category, difficulty) == 0) {
      return StartOutcome.unavailable;
    }
    final candidates = _matching(
      category,
      difficulty,
    ).where((e) => !_usedEntries.contains(e)).toList();
    if (candidates.isEmpty) {
      return StartOutcome.exhausted;
    }

    final entry = candidates[_random.nextInt(candidates.length)];
    _usedEntries.add(entry);
    _round = HangmanRound(entry: entry);
    _lastGuess = null;
    _resultRecorded = false;
    notifyListeners();
    return StartOutcome.started;
  }

  /// Libera novamente as respostas já usadas de uma combinação.
  void resetUsedAnswers(AnswerCategory category, Difficulty difficulty) {
    _usedEntries.removeAll(_matching(category, difficulty).toList());
    notifyListeners();
  }

  /// Aplica a tentativa de [letter] na rodada atual.
  GuessOutcome guess(String letter) {
    final round = _round;
    if (round == null) {
      return GuessOutcome.ignored;
    }
    final outcome = round.guess(letter);
    if (outcome != GuessOutcome.ignored) {
      _lastGuess = GuessFeedback(letter: letter, outcome: outcome);
    }
    _recordResultIfFinished(round);
    notifyListeners();
    return outcome;
  }

  /// Solicita a dica da rodada atual (contabilizada uma única vez).
  void requestHint() {
    _round?.requestHint();
    notifyListeners();
  }

  void _recordResultIfFinished(HangmanRound round) {
    if (round.isFinished && !_resultRecorded) {
      stats.register(round);
      _resultRecorded = true;
    }
  }
}
