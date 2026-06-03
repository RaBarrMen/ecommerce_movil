import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" icon usando colores reales
            _GoogleIcon(),
            const SizedBox(width: 12),
            const Text(
              AppStrings.signInWithGoogle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final r = size.width / 2;

    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    final sweeps = [90.0, 90.0, 90.0, 90.0];
    var start = -90.0;

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * 0.72),
        _toRad(start),
        _toRad(sweeps[i]),
        false,
        paint,
      );
      start += sweeps[i];
    }

    // White cutout bar (right side of G)
    final barPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - size.height * 0.13,
          r, size.height * 0.26),
      barPaint,
    );
  }

  double _toRad(double deg) => deg * 3.1415926535 / 180;

  @override
  bool shouldRepaint(_) => false;
}