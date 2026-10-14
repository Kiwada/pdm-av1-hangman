import 'package:hangman_game/domain/models/hangman_round.dart';

/// Estatísticas acumuladas durante a sessão (apenas em memória).
class SessionStats {
  int _totalRounds = 0;
  int _wins = 0;
  int _losses = 0;
  int _totalErrors = 0;
  int _hintsUsed = 0;

  int get totalRounds => _totalRounds;
  int get wins => _wins;
  int get losses => _losses;
  int get totalErrors => _totalErrors;
  int get hintsUsed => _hintsUsed;

  /// Percentual de vitórias sobre as rodadas concluídas.
  double get winPercentage =>
      _totalRounds == 0 ? 0 : _wins * 100 / _totalRounds;

  /// Percentual de derrotas sobre as rodadas concluídas.
  double get lossPercentage =>
      _totalRounds == 0 ? 0 : _losses * 100 / _totalRounds;

  /// Contabiliza uma rodada concluída.
  void register(HangmanRound round) {
    assert(round.isFinished, 'Somente rodadas concluídas são registradas');
    _totalRounds++;
    if (round.isWon) {
      _wins++;
    } else {
      _losses++;
    }
    _totalErrors += round.errors;
    if (round.hintUsed) {
      _hintsUsed++;
    }
  }
}
