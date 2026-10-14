import 'package:hangman_game/domain/models/answer_entry.dart';

/// Falha ao carregar ou interpretar os dados do jogo.
class AnswerDataException implements Exception {
  const AnswerDataException(this.message);

  final String message;

  @override
  String toString() => 'AnswerDataException: $message';
}

/// Fonte de dados das respostas.
abstract interface class AnswerRepository {
  /// Carrega todas as respostas. Lança [AnswerDataException] em caso de erro.
  Future<List<AnswerEntry>> loadEntries();
}
