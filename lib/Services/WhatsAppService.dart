import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WhatsAppService {
  final String accessToken = dotenv.env['ACCESS_TOKEN'] ?? '';
  final String phoneNumberId = dotenv.env['PHONE_NUMBER_ID'] ?? '';
  Future<void> sendWhatsAppOTP(String userPhone, String otpCode) async {
    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };

    var body = json.encode({
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": userPhone,
      "type": "template",
      "template": {
        "name": "code",
        "language": {"code": "fr"},
        "components": [
          {
            "type": "body",
            "parameters": [
              {"type": "text", "text": otpCode}
            ]
          }
        ]
      }
    });

    try {
      var response = await http.post(
        Uri.parse('https://graph.facebook.com/v17.0/$phoneNumberId/messages'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print("OTP sent successfully: ${response.body}");
      } else {
        print("Failed to send OTP: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
