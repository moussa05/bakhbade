import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://khoulefreres.com/api';

  Future<Map<String, dynamic>?> login(
      String phoneNumber, String password) async {
    var url = Uri.parse('$baseUrl/user/login');
    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // Ajouter des cookies si nécessaire
      'Cookie':
          'XSRF-TOKEN=your-xsrf-token-here; khoul_et_frres_session=your-session-here'
    };
    var body = jsonEncode({"phone_number": phoneNumber, "password": password});

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Erreur: ${response.statusCode}");
      print(response.body);
      return null;
    }
  }
}
