import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hangman_game/domain/models/answer_entry.dart';
import 'package:hangman_game/domain/repositories/answer_repository.dart';

/// Carrega as respostas do arquivo JSON incorporado aos assets.
class AssetAnswerRepository implements AnswerRepository {
  AssetAnswerRepository({
    AssetBundle? bundle,
    this.assetPath = defaultAssetPath,
  }) : _bundle = bundle ?? rootBundle;

  static const String defaultAssetPath = 'assets/data/hangman_entries.json';

  final AssetBundle _bundle;
  final String assetPath;

  @override
  Future<List<AnswerEntry>> loadEntries() async {
    final String raw;
    try {
      raw = await _bundle.loadString(assetPath);
    } catch (_) {
      throw AnswerDataException('Não foi possível abrir "$assetPath".');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw.replaceFirst('\uFEFF', ''));
    } on FormatException catch (error) {
      throw AnswerDataException('JSON inválido: ${error.message}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AnswerDataException('A raiz do JSON deve ser um objeto.');
    }
    final rawEntries = decoded['entries'];
    if (rawEntries is! List) {
      throw const AnswerDataException('Campo "entries" ausente ou inválido.');
    }

    final entries = <AnswerEntry>[];
    for (var index = 0; index < rawEntries.length; index++) {
      final item = rawEntries[index];
      if (item is! Map<String, dynamic>) {
        throw AnswerDataException('Entrada ${index + 1} não é um objeto.');
      }
      try {
        entries.add(AnswerEntry.fromJson(item));
      } on FormatException catch (error) {
        throw AnswerDataException('Entrada ${index + 1}: ${error.message}');
      }
    }

    if (entries.isEmpty) {
      throw const AnswerDataException('O arquivo não contém respostas.');
    }
    return List<AnswerEntry>.unmodifiable(entries);
  }
}
