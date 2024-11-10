import 'dart:convert';
import 'package:bakhbade/models/Formation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.bakhbade.com/api/typeformations';

  Future<List<TypeFormation>> fetchFormations() async {
    var request = http.Request('GET', Uri.parse(baseUrl));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final List<dynamic> data = jsonDecode(responseBody);
      return data.map((json) => TypeFormation.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des formations');
    }
  }
}
