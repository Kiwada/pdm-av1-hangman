/// Resultado de uma tentativa de letra.
enum GuessOutcome {
  /// A letra existe na resposta.
  correct,

  /// A letra não existe na resposta (gera um erro).
  wrong,

  /// Tentativa descartada: letra repetida, símbolo inválido ou rodada encerrada.
  ignored,
}
