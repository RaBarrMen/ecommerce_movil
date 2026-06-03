class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value.trim())) return 'Correo electrónico inválido';
    return null;
  }

  static String? cardNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el número de tarjeta';
    final clean = value.replaceAll(' ', '');
    if (clean.length < 13 || clean.length > 19) return 'Número de tarjeta inválido';
    if (!RegExp(r'^\d+$').hasMatch(clean)) return 'Solo se permiten números';
    return null;
  }

  static String? cardExpiry(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa la fecha de vencimiento';
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    if (!regex.hasMatch(value)) return 'Formato inválido (MM/AA)';
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return 'La tarjeta está vencida';
    }
    return null;
  }

  static String? cvv(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el CVV';
    if (!RegExp(r'^\d{3,4}$').hasMatch(value.trim())) return 'CVV inválido';
    return null;
  }

  static String? cardHolder(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el nombre del titular';
    if (value.trim().length < 3) return 'Nombre demasiado corto';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu número de teléfono';
    if (!RegExp(r'^\+?[\d\s\-]{8,15}$').hasMatch(value.trim())) {
      return 'Número de teléfono inválido';
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    if (value.trim().length < min) return 'Mínimo $min caracteres';
    return null;
  }
}