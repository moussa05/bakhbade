import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bakhbade/models/Booking.dart';

Future<Booking?> fetchBooking(int id) async {
  var headers = {
    'Accept': 'application/json',
    'Cookie': 'XSRF-TOKEN=YOUR_TOKEN; _session=YOUR_SESSION'
  };
  var url = Uri.parse('https://khoulefreres.com/api/booking/$id');
  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body)['data'];
    return Booking.fromJson(data);
  } else {
    print('Failed to load booking');
    return null;
  }
}
