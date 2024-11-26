import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingService {
  static const String apiUrl = 'https://khoulefreres.com/user/6371/bookings';
  static const String token =
      'uzgHX9AjBtO3aFQGTydPFkI4F8YABCg3oOuIPqrF6DP1AjraPE8nKta5Zsq0nByN7O0hYI1qLuT5YY46';

  Future<List<dynamic>> fetchBookings() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var request = http.Request('GET', Uri.parse(apiUrl));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load bookings');
    }
  }
}
