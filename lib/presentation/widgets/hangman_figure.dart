import 'package:flutter/material.dart';
import 'package:hangman_game/core/theme/app_colors.dart';

/// Desenho pixelado da forca e do boneco.
///
/// A estrutura da forca permanece visível. Cada erro adiciona uma parte:
/// cabeça, tronco, braço esquerdo, braço direito, perna esquerda e
/// perna direita.
class HangmanFigure extends StatelessWidget {
  const HangmanFigure({
    super.key,
    required this.errors,
    required this.maxErrors,
  });

  final int errors;
  final int maxErrors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Forca com $errors de $maxErrors erros',
      child: CustomPaint(
        painter: _PixelHangmanPainter(
          errors: errors.clamp(0, maxErrors),
          maxErrors: maxErrors,
        ),
      ),
    );
  }
}

class _PixelHangmanPainter extends CustomPainter {
  const _PixelHangmanPainter({
    required this.errors,
    required this.maxErrors,
  });

  final int errors;
  final int maxErrors;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 24;

    // Centraliza o desenho quadrado na área disponível.
    final originX = (size.width - 24 * unit) / 2;
    final originY = (size.height - 24 * unit) / 2;

    final gallowsPaint = Paint()
      ..color = AppColors.text
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final bodyPaint = Paint()
      ..color = errors >= maxErrors ? AppColors.error : AppColors.primary
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final shadowPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    Rect block(double x, double y, double w, double h) {
      return Rect.fromLTWH(
        originX + x * unit,
        originY + y * unit,
        w * unit,
        h * unit,
      );
    }

    void drawBlocks(Paint paint, List<Rect> blocks) {
      for (final rect in blocks) {
        canvas.drawRect(rect, paint);
      }
    }

    // Estrutura da forca.
    drawBlocks(gallowsPaint, [
      block(2, 23, 19, 1),
      block(5, 1, 1, 22),
      block(5, 1, 11, 1),
      block(15, 2, 1, 3),
      block(6, 5, 1, 1),
      block(8, 3, 1, 1),
      block(7, 4, 1, 1),
      block(9, 2, 1, 1),
    ]);

    // 1º erro: cabeça.
    if (errors >= 1) {
      drawBlocks(bodyPaint, [
        block(14, 5, 4, 1),
        block(13, 6, 1, 4),
        block(18, 6, 1, 4),
        block(14, 10, 4, 1),
      ]);
    }

    // 2º erro: tronco.
    if (errors >= 2) {
      drawBlocks(bodyPaint, [
        block(15, 11, 1, 6),
      ]);
    }

    // 3º erro: braço esquerdo.
    if (errors >= 3) {
      drawBlocks(bodyPaint, [
        block(14, 12, 1, 1),
        block(13, 13, 1, 1),
        block(12, 14, 1, 1),
      ]);
    }

    // 4º erro: braço direito.
    if (errors >= 4) {
      drawBlocks(bodyPaint, [
        block(16, 12, 1, 1),
        block(17, 13, 1, 1),
        block(18, 14, 1, 1),
      ]);

      drawBlocks(shadowPaint, [
        block(17, 12, 1, 1),
        block(18, 13, 1, 1),
        block(16, 11, 1, 1),
      ]);
    }

    // 5º erro: perna esquerda.
    if (errors >= 5) {
      drawBlocks(bodyPaint, [
        block(14, 17, 1, 1),
        block(13, 18, 1, 1),
        block(12, 19, 1, 1),
      ]);
    }

    // 6º erro: perna direita.
    if (errors >= 6) {
      drawBlocks(bodyPaint, [
        block(16, 17, 1, 1),
        block(17, 18, 1, 1),
        block(18, 19, 1, 1),
      ]);

      drawBlocks(shadowPaint, [
        block(16, 16, 1, 1),
        block(17, 17, 1, 1),
        block(18, 18, 1, 1),
      ]);
    }
  }

  @override
  bool shouldRepaint(covariant _PixelHangmanPainter oldDelegate) {
    return oldDelegate.errors != errors || oldDelegate.maxErrors != maxErrors;
  }
}
