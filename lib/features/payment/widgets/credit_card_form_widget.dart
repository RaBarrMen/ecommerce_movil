import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';

class CreditCardFormWidget extends StatefulWidget {
  const CreditCardFormWidget({super.key});

  @override
  State<CreditCardFormWidget> createState() => _CreditCardFormWidgetState();
}

class _CreditCardFormWidgetState extends State<CreditCardFormWidget>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _holderCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _isFlipped = false;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.5)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
    ]).animate(_flipCtrl);
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _onCvvFocus(bool hasFocus) {
    setState(() => _isFlipped = hasFocus);
    if (hasFocus) {
      _flipCtrl.forward();
    } else {
      _flipCtrl.reverse();
    }
  }

  String get _maskedNumber {
    final raw = _numberCtrl.text.replaceAll(' ', '');
    if (raw.length < 4) return '**** **** **** ****';
    final groups = <String>[];
    for (int i = 0; i < 16; i += 4) {
      if (i < raw.length) {
        final end = (i + 4) > raw.length ? raw.length : i + 4;
        final group = raw.substring(i, end);
        groups.add(group.padRight(4, '*'));
      } else {
        groups.add('****');
      }
    }
    return groups.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated Card Preview
        AnimatedBuilder(
          animation: _flipAnim,
          builder: (_, __) {
            final angle = _flipAnim.value * 3.14159;
            final isShowingFront = _flipAnim.value < 0.5;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isShowingFront ? _CardFront(
                number: _maskedNumber,
                holder: _holderCtrl.text.isEmpty
                    ? 'NOMBRE TITULAR'
                    : _holderCtrl.text.toUpperCase(),
                expiry: _expiryCtrl.text.isEmpty ? 'MM/AA' : _expiryCtrl.text,
              ) : Transform(
                transform: Matrix4.identity()..rotateY(3.14159),
                alignment: Alignment.center,
                child: _CardBack(cvv: _cvvCtrl.text.isEmpty ? '***' : _cvvCtrl.text),
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        // Form fields
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Card Number
              TextFormField(
                controller: _numberCtrl,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                maxLength: 19,
                validator: Validators.cardNumber,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 14),
              // Card Holder
              TextFormField(
                controller: _holderCtrl,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.characters,
                validator: Validators.cardHolder,
                decoration: const InputDecoration(
                  labelText: 'Nombre del titular',
                  hintText: 'JUAN PÉREZ',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryCtrl,
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.number,
                      inputFormatters: [_ExpiryFormatter()],
                      maxLength: 5,
                      validator: Validators.cardExpiry,
                      decoration: const InputDecoration(
                        labelText: 'Vencimiento',
                        hintText: 'MM/AA',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Focus(
                      onFocusChange: _onCvvFocus,
                      child: TextFormField(
                        controller: _cvvCtrl,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 4,
                        obscureText: true,
                        validator: Validators.cvv,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '***',
                          prefixIcon: Icon(Icons.lock_outline),
                          counterText: '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Card Front ────────────────────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.number,
    required this.holder,
    required this.expiry,
  });
  final String number;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ShopApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    // Chip icon
                    Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CustomPaint(painter: _ChipPainter()),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TITULAR',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(holder,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VENCE',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(expiry,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Back ─────────────────────────────────────────────────────────────────

class _CardBack extends StatelessWidget {
  const _CardBack({required this.cvv});
  final String cvv;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Magnetic strip
          Container(
            height: 44,
            width: double.infinity,
            color: Colors.black87,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(cvv,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('CVV',
              style: TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Chip Painter ──────────────────────────────────────────────────────────────

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8960C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Rect.fromLTWH(2, 2, w - 4, h - 4), paint);
    canvas.drawLine(Offset(w / 2, 2), Offset(w / 2, h - 2), paint);
    canvas.drawLine(Offset(2, h / 2), Offset(w - 2, h / 2), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Input Formatters ──────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    final text = value.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return value.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    var text = value.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return value.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
