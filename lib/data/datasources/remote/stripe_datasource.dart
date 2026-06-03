import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class StripeDatasource {
  Future<String> createPaymentIntent({
    required int amountInCents,
    required String currency,
  });
}

class StripeDatasourceImpl implements StripeDatasource {
  // TODO: Reemplazar con tu backend URL que expone /create-payment-intent
  // NUNCA expongas la secret key de Stripe en el cliente.
  static const String _backendUrl =
      'https://your-backend.com/create-payment-intent';

  @override
  Future<String> createPaymentIntent({
    required int amountInCents,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse(_backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountInCents,
        'currency': currency,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['clientSecret'] as String;
    } else {
      throw Exception(
          'Error al crear payment intent: ${response.statusCode}');
    }
  }
}