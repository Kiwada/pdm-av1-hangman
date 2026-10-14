# Integrantes

- Nome completo do integrante 1
- Nome completo do integrante 2
- Nome completo do integrante 3
- Nome completo do integrante 4

---

# hangman-game

Jogo da Forca para dispositivos Android desenvolvido com **Flutter** e **Dart**
para a disciplina Programação para Dispositivos Móveis (UESPI).

## Descrição

Aplicativo totalmente offline. As respostas, categorias, níveis e dicas são
lidos, em tempo de execução, do arquivo `assets/data/hangman_entries.json`.
Respostas podem ter uma ou várias palavras, acentos, espaços e hífens; os
caracteres não alfabéticos são exibidos automaticamente e o jogador tenta
apenas letras.

## Principais funcionalidades

- Seleção de categoria e dificuldade antes de iniciar a rodada
- Sorteio sem repetição de respostas por sessão (com aviso ao esgotar)
- Comparação de letras ignorando acentuação, preservando a grafia original
- Forca desenhada progressivamente (6 erros)
- Dica por rodada, contabilizada uma única vez
- Tela de resultado (vitória/derrota) e estatísticas da sessão
- Tela "Sobre" com os nomes da equipe

## Tecnologias utilizadas

- Dart 3 / Flutter 3.27+
- `ChangeNotifier` + `ListenableBuilder` para gerenciamento de estado
- Nenhum pacote externo de runtime

## Como executar

```bash
git clone <url-do-repositorio>
cd hangman-game
flutter pub get
flutter run
```

Verificações de qualidade:

```bash
dart format .
flutter analyze
flutter test
```

## Estrutura

```text
lib/
  core/          dados estáticos da aplicação (equipe)
  domain/        enums, modelos, regras da rodada, normalização, contrato do repositório
  data/          carregamento e desserialização do JSON (assets)
  application/   GameController: sessão, sorteio sem repetição, estatísticas
  presentation/  telas e widgets
assets/data/     hangman_entries.json
test/            testes unitários das regras de negócio
```
