import 'package:flutter/material.dart';

/// Desenho progressivo da forca e do boneco.
///
/// A estrutura da forca é sempre exibida; cada erro adiciona uma parte do
/// boneco: cabeça, tronco, braço esquerdo, braço direito, perna esquerda e
/// perna direita (6 estados, compatível com `HangmanRound.defaultMaxErrors`).
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
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Forca com $errors de $maxErrors erros',
      child: CustomPaint(
        painter: _HangmanPainter(
          errors: errors,
          gallowsColor: scheme.onSurfaceVariant,
          bodyColor: errors >= maxErrors ? scheme.error : scheme.primary,
        ),
      ),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  _HangmanPainter({
    required this.errors,
    required this.gallowsColor,
    required this.bodyColor,
  });

  final int errors;
  final Color gallowsColor;
  final Color bodyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gallows = Paint()
      ..color = gallowsColor
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final body = Paint()
      ..color = bodyColor
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Estrutura da forca.
    canvas.drawLine(Offset(w * 0.10, h * 0.95), Offset(w * 0.90, h * 0.95), gallows);
    canvas.drawLine(Offset(w * 0.25, h * 0.95), Offset(w * 0.25, h * 0.05), gallows);
    canvas.drawLine(Offset(w * 0.25, h * 0.05), Offset(w * 0.65, h * 0.05), gallows);
    canvas.drawLine(Offset(w * 0.65, h * 0.05), Offset(w * 0.65, h * 0.15), gallows);

    // Partes do boneco, na ordem dos erros.
    if (errors >= 1) {
      canvas.drawCircle(Offset(w * 0.65, h * 0.24), h * 0.09, body);
    }
    if (errors >= 2) {
      canvas.drawLine(Offset(w * 0.65, h * 0.33), Offset(w * 0.65, h * 0.62), body);
    }
    if (errors >= 3) {
      canvas.drawLine(Offset(w * 0.65, h * 0.40), Offset(w * 0.48, h * 0.52), body);
    }
    if (errors >= 4) {
      canvas.drawLine(Offset(w * 0.65, h * 0.40), Offset(w * 0.82, h * 0.52), body);
    }
    if (errors >= 5) {
      canvas.drawLine(Offset(w * 0.65, h * 0.62), Offset(w * 0.50, h * 0.83), body);
    }
    if (errors >= 6) {
      canvas.drawLine(Offset(w * 0.65, h * 0.62), Offset(w * 0.80, h * 0.83), body);
    }
  }

  @override
  bool shouldRepaint(_HangmanPainter oldDelegate) {
    return oldDelegate.errors != errors ||
        oldDelegate.gallowsColor != gallowsColor ||
        oldDelegate.bodyColor != bodyColor;
  }
}
