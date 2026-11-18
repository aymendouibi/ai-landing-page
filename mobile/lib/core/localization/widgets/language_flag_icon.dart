import 'package:flutter/material.dart';

/// Renders a crisp vector-drawn national flag or badge for language selection.
class LanguageFlagIcon extends StatelessWidget {
  final String languageCode;
  final String countryCode;
  final double size;

  const LanguageFlagIcon({
    super.key,
    required this.languageCode,
    required this.countryCode,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final width = size * 1.35;
    final height = size;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.2),
        child: CustomPaint(
          size: Size(width, height),
          painter: _FlagPainter(
            code: '${languageCode}_$countryCode'.toLowerCase(),
          ),
        ),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  final String code;

  _FlagPainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    switch (code) {
      case 'en_us':
        _paintUS(canvas, size);
        break;
      case 'es_es':
        _paintSpain(canvas, size);
        break;
      case 'fr_fr':
        _paintFrance(canvas, size);
        break;
      case 'de_de':
        _paintGermany(canvas, size);
        break;
      case 'ar_sa':
        _paintSaudiArabia(canvas, size);
        break;
      case 'zh_cn':
        _paintChina(canvas, size);
        break;
      case 'ja_jp':
        _paintJapan(canvas, size);
        break;
      case 'pt_br':
        _paintBrazil(canvas, size);
        break;
      default:
        _paintFallback(canvas, size);
        break;
    }
  }

  // 1. USA (en_US)
  void _paintUS(Canvas canvas, Size size) {
    final paint = Paint();
    final stripeHeight = size.height / 7;

    for (int i = 0; i < 7; i++) {
      paint.color = i.isEven ? const Color(0xFFB22234) : Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        paint,
      );
    }

    // Canton
    final cantonWidth = size.width * 0.44;
    final cantonHeight = stripeHeight * 4;
    paint.color = const Color(0xFF3C3B6E);
    canvas.drawRect(Rect.fromLTWH(0, 0, cantonWidth, cantonHeight), paint);

    // Stars representation (subtle clean dots)
    paint.color = Colors.white;
    final colStep = cantonWidth / 4;
    final rowStep = cantonHeight / 4;
    for (int r = 1; r <= 3; r++) {
      for (int c = 1; c <= 3; c++) {
        canvas.drawCircle(Offset(c * colStep, r * rowStep), 1.1, paint);
      }
    }
  }

  // 2. Spain (es_ES)
  void _paintSpain(Canvas canvas, Size size) {
    final paint = Paint();
    final redHeight = size.height * 0.25;
    final yellowHeight = size.height * 0.50;

    // Top red
    paint.color = const Color(0xFFAD1519);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, redHeight), paint);

    // Middle yellow
    paint.color = const Color(0xFFFABD00);
    canvas.drawRect(
      Rect.fromLTWH(0, redHeight, size.width, yellowHeight),
      paint,
    );

    // Bottom red
    paint.color = const Color(0xFFAD1519);
    canvas.drawRect(
      Rect.fromLTWH(0, redHeight + yellowHeight, size.width, redHeight),
      paint,
    );

    // Spanish coat-of-arms accent badge
    paint.color = const Color(0xFF910F13);
    final badgeWidth = size.width * 0.16;
    final badgeHeight = size.height * 0.28;
    final badgeLeft = size.width * 0.24;
    final badgeTop = (size.height - badgeHeight) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeLeft, badgeTop, badgeWidth, badgeHeight),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  // 3. France (fr_FR)
  void _paintFrance(Canvas canvas, Size size) {
    final paint = Paint();
    final colWidth = size.width / 3;

    // Blue
    paint.color = const Color(0xFF002395);
    canvas.drawRect(Rect.fromLTWH(0, 0, colWidth, size.height), paint);

    // White
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(colWidth, 0, colWidth, size.height), paint);

    // Red
    paint.color = const Color(0xFFED2939);
    canvas.drawRect(
      Rect.fromLTWH(colWidth * 2, 0, colWidth, size.height),
      paint,
    );
  }

  // 4. Germany (de_DE)
  void _paintGermany(Canvas canvas, Size size) {
    final paint = Paint();
    final rowHeight = size.height / 3;

    // Black
    paint.color = const Color(0xFF000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, rowHeight), paint);

    // Red
    paint.color = const Color(0xFFDD0000);
    canvas.drawRect(Rect.fromLTWH(0, rowHeight, size.width, rowHeight), paint);

    // Gold
    paint.color = const Color(0xFFFFCC00);
    canvas.drawRect(
      Rect.fromLTWH(0, rowHeight * 2, size.width, rowHeight),
      paint,
    );
  }

  // 5. Saudi Arabia (ar_SA)
  void _paintSaudiArabia(Canvas canvas, Size size) {
    final paint = Paint();
    // Green field
    paint.color = const Color(0xFF006C35);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Center emblem / sword symbol in crisp white
    paint.color = Colors.white;
    final centerY = size.height * 0.62;
    final swordWidth = size.width * 0.55;
    final startX = (size.width - swordWidth) / 2;

    paint.strokeWidth = 1.4;
    paint.strokeCap = StrokeCap.round;
    // Sword blade
    canvas.drawLine(
      Offset(startX, centerY),
      Offset(startX + swordWidth, centerY),
      paint,
    );
    // Sword hilt
    canvas.drawLine(
      Offset(startX + 3, centerY - 2.5),
      Offset(startX + 3, centerY + 2.5),
      paint,
    );

    // Arabic script accent line
    paint.strokeWidth = 1.6;
    final scriptY = size.height * 0.38;
    canvas.drawLine(
      Offset(startX + 4, scriptY),
      Offset(startX + swordWidth - 4, scriptY),
      paint,
    );
  }

  // 6. China (zh_CN)
  void _paintChina(Canvas canvas, Size size) {
    final paint = Paint();
    // Red field
    paint.color = const Color(0xFFDE2910);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Main yellow star
    paint.color = const Color(0xFFFFDE00);
    final mainCenter = Offset(size.width * 0.22, size.height * 0.36);
    _drawStar(canvas, mainCenter, size.height * 0.20, paint);

    // 4 smaller surrounding stars
    final smallRadius = size.height * 0.07;
    _drawStar(
      canvas,
      Offset(size.width * 0.40, size.height * 0.18),
      smallRadius,
      paint,
    );
    _drawStar(
      canvas,
      Offset(size.width * 0.46, size.height * 0.30),
      smallRadius,
      paint,
    );
    _drawStar(
      canvas,
      Offset(size.width * 0.46, size.height * 0.48),
      smallRadius,
      paint,
    );
    _drawStar(
      canvas,
      Offset(size.width * 0.40, size.height * 0.60),
      smallRadius,
      paint,
    );
  }

  // 7. Japan (ja_JP)
  void _paintJapan(Canvas canvas, Size size) {
    final paint = Paint();
    // White field
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Red disk (Hinomaru)
    paint.color = const Color(0xFFBC002D);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.height * 0.32, paint);
  }

  // 8. Brazil (pt_BR)
  void _paintBrazil(Canvas canvas, Size size) {
    final paint = Paint();
    // Green field
    paint.color = const Color(0xFF009C3B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Yellow rhombus
    paint.color = const Color(0xFFFFDF00);
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.12)
      ..lineTo(size.width * 0.88, size.height / 2)
      ..lineTo(size.width / 2, size.height * 0.88)
      ..lineTo(size.width * 0.12, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);

    // Blue circle
    paint.color = const Color(0xFF002776);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.height * 0.23, paint);

    // White curved band
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.1;
    final arcRect = Rect.fromCircle(center: center, radius: size.height * 0.20);
    canvas.drawArc(arcRect, 3.2, 1.4, false, paint);
    paint.style = PaintingStyle.fill;
  }

  void _paintFallback(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF64748B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius / 2, paint);
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) =>
      oldDelegate.code != code;
}
