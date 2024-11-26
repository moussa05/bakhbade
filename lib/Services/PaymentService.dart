import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String orangeMoneyApiUrl =
      "https://api.orange-sonatel.com/api/eWallet/v4/qrcode";
  final String tokenUrl = "https://api.orange-sonatel.com/oauth/token";
  final String apiUrl = "https://api.wave.com/v1/checkout/sessions";
  final String bookingApiUrl =
      "https://khoulefreres.com/api/booking"; // Your booking API base URL

  /// Charge la clé d'API depuis le fichier .env
  String get apiKey => dotenv.env['WAVE_API_KEY'] ?? '';
  String get clientId => dotenv.env['CLIENT_ID'] ?? '';
  String get clientSecret => dotenv.env['CLIENT_SECRET'] ?? '';

  Future<String?> getOrangeMoneyToken() async {
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = {
      'grant_type': 'client_credentials',
      'client_id': clientId,
      'client_secret': clientSecret,
    };

    final response =
        await http.post(Uri.parse(tokenUrl), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      print('Erreur lors de l\'obtention du token : ${response.statusCode}');
      return null;
    }
  }

  Future<dynamic> initiateOrangeMoneyPayment({
    required double amount,
    required int bookingId,
  }) async {
    final accessToken = await getOrangeMoneyToken();
    String merchantName = "réservation_sur_Bakhbadé";

    if (accessToken == null) {
      return 'Erreur : Impossible d\'obtenir le jeton d\'accès';
    }

    final callbackSuccessUrl = "https://khoulefreres.com/$bookingId";
    final callbackCancelUrl = "https://khoulefreres.com/$bookingId";
    final codeMarchand = dotenv.env['IDORANGEMONEY'] ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = json.encode({
      "amount": {
        "unit": "XOF",
        "value": amount, // Direct double value instead of String
      },
      "callbackCancelUrl": callbackCancelUrl,
      "callbackSuccessUrl": callbackSuccessUrl,
      "code": codeMarchand,
      "metadata": {
        "booking": bookingId, // Ensure bookingId is an integer
      },
      "name": merchantName,
      "validity": 15,
    });

    final response = await http.post(Uri.parse(orangeMoneyApiUrl),
        headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Réponse OrangeMoney : $data');
      return data;
    } else {
      print(
          'Erreur de paiement OrangeMoney : ${response.statusCode}, raison : ${response.reasonPhrase}');
      return 'Erreur : ${response.statusCode} - ${response.reasonPhrase}';
    }
  }

  /// Effectue la requête HTTP pour obtenir l'URL de paiement
  Future<dynamic> getPaymentUrl({
    required double amount,
    required int booking,
    String errorUrl = "https://example.com/error",
    String successUrl = "https://example.com/success",
  }) async {
    final uri = Uri.parse(apiUrl);
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final headersBooking = {
      'Accept': 'application/json',
      'Cookie':
          'XSRF-TOKEN=eyJpdiI6InRnenRwd2V4V0M5SFBzTFQrYm92N2c9PSIsInZhbHVlIjoiUTZUYTFCQ0dxWVBSb0IxRTFWeE1HT3JiOUhYRkF6ZzRcL0xlU2VWbnQ5dXVTRm9DSlVQeXp4Ujl5NE5BMlwvZFI2IiwibWFjIjoiYTdjMzc3MWI4ZDIyMjE0MTk2OTZmZWJmMjBjN2YwYzAyMThmYjI5NWIzYWQzYjZmODhiZGYxNmNjMGRmYWQxOCJ9; _session=eyJpdiI6IkI4aGhBTnVsbEROTTRlNndNVUFMRVE9PSIsInZhbHVlIjoiSzFNbDdPSnlNOFEyMkgxeGg1cTduT1ZTSlVoRDdPbXl5N3F5eVY4amVEaWs0cWtPUjZaSXN6XC9uWDZIUVNuZngiLCJtYWMiOiJlMTQ2NmQwZTRiZWYxZWNlZWU4OWJhMzVlYzBiNTY3YzUzNDUxMmRkNDkwZjhiMWYzMTM1NWMxMmUwNGE2N2YzIn0%3D'
    };
    final body = json.encode({
      "amount": amount, // Use double directly for numeric precision
      "currency": "XOF",
      "error_url": errorUrl,
      "success_url": successUrl,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var bookingPaymentUri =
            Uri.parse("$bookingApiUrl/$booking/payment/${data['id']}");
        final response2 =
            await http.post(bookingPaymentUri, headers: headersBooking);
        print('Payment URL Response: $data');
        return data;
      } else {
        print(
            'Request failed with status: ${response.statusCode}, reason: ${response.reasonPhrase}');
        return 'Erreur : ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (error) {
      return 'Erreur de requête : $error';
    }
  }
}
