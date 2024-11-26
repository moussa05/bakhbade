import 'package:bakhbade/models/database.dart';
import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/login/BusWidget.dart';
import 'package:bakhbade/models/Location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bakhbade/services/PaymentService.dart';
import 'package:bakhbade/models/PaymentMode.dart';

class PaymentScreen extends StatefulWidget {
  final Location departure;
  final Location arrival;
  final int pathId;
  final dynamic travel;
  final bool isForMe;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? gender;

  // Constructor to accept departure and arrival values
  PaymentScreen({
    required this.departure,
    required this.arrival,
    required this.pathId,
    required this.travel,
    required this.isForMe,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.gender,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false; // Variable to track loading state

  // Function to send the payment request
  Future<void> sendPaymentRequest(int later, String firstName, String lastName,
      String phoneNumber, String title, int userId) async {
    var url = Uri.parse('https://khoulefreres.com/api/booking');

    // Headers of the request
    var headers = {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
    };

    // Corps de la requête
    var body = json.encode({
      "path_id": widget.pathId,
      "code": "",
      "later": later,
      "travel": {
        "id": widget.travel['id'],
        "name": widget.travel['name'],
        "departure_id": widget.departure.id,
        "arrival_id": widget.arrival.id,
        "path_id": widget.pathId,
        "sit_count": widget.travel['sit_count'],
        "ok_enabled": widget.travel['ok_enabled'],
        "fast": widget.travel['fast'],
        "price": widget.travel['price'],
        "sit_left": widget.travel['sit_left'],
        "arrival": {
          "id": widget.arrival.id,
          "name": widget.arrival.name,
          "valuation": widget.arrival.valuation,
        },
        "departure": {
          "id": widget.departure.id,
          "name": widget.departure.name,
          "valuation": widget.departure.valuation,
        },
      },
      "travel_id": widget.travel['id'],
      "departure_id": widget.departure.id,
      "arrival_id": widget.arrival.id,
      "title": title,
      "full_name": "",
      "client_id": userId,
      "phone_number": phoneNumber,
      "passengers": [],
      "first_name": firstName,
      "last_name": lastName
    });

    try {
      setState(() {
        _isLoading = true; // Start loading
      });

      // Send the POST request
      var response = await http.post(url, headers: headers, body: body);

      // Check the status of the response
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // Define the success and error URLs
        String errorUrl =
            'https://khoulefreres.com/booking/${jsonResponse["data"]["id"]}';
        String successUrl =
            'https://khoulefreres.com/booking/${jsonResponse["data"]["id"]}';
        double amount = (jsonResponse["data"]["price"])
            .toDouble(); // Assuming "price" holds the payment amount

        // Call PaymentService to retrieve the payment URL
        var paymentService = PaymentService();
        if (later == 4) {
          var paymentResponse = await paymentService.getPaymentUrl(
            amount: amount,
            booking: jsonResponse["data"]["id"],
            successUrl: successUrl,
            errorUrl: errorUrl,
          );
          if (paymentResponse != null || paymentResponse['id'] != null) {
            print(paymentResponse['id']);
            // Launch the provided URL if the API response is successful
            // var newPayment = PaymentMode(
            //     id: jsonResponse["data"]["id"], // ID unique généré par l'API
            //     bookingId: jsonResponse["data"]["id"], // bookingId
            //     paymentId: paymentResponse["id"], // paymentId
            //     type: "booking",
            //     methode: "booking");

            // await DatabaseHelper().insertPayment(newPayment);

            final Uri waveLaunchUrl =
                Uri.parse(paymentResponse['wave_launch_url']);
            _launchUrl(waveLaunchUrl);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Paiement réussi ${paymentResponse['id']}'),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Erreur lors de la récupération de l\'URL de paiement'),
            ));
          }
        } else if (later == 0) {
          /// add the code for orange money
          var orangePaymentService =
              await paymentService.initiateOrangeMoneyPayment(
                  amount: amount, bookingId: jsonResponse["data"]["id"]);
          if (orangePaymentService != null ||
              orangePaymentService['deepLinks'] != null) {
            // Launch the provided URL if the API response is successful
            final Uri waveLaunchUrl =
                Uri.parse(orangePaymentService["deepLinks"]['MAXIT']);
            _launchUrl(waveLaunchUrl);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Paiement réussi ${orangePaymentService['deepLinks']}'),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Erreur lors de la récupération de l\'URL de paiement'),
            ));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : ${response.statusCode} - ${response.body}'),
        ));
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : ${e} }'),
      ));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  // Function to retrieve user information
  Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "first_name": prefs.getString('first_name') ?? '',
      "last_name": prefs.getString('last_name') ?? '',
      "phone_number": prefs.getString('phone_number') ?? '',
      "title": prefs.getString('title') ?? '',
      "id": prefs.getInt('id') ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mode de paiement')),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 5),
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: BusWidget(),
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.25,
                  margin: const EdgeInsets.all(10),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 51, 51, 50),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        if (_isLoading) // Show spinner while loading
                          CircularProgressIndicator()
                        else ...[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 40.0),
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () async {
                                if (widget.isForMe) {
                                  var userInfo = await getUserInfo();
                                  await sendPaymentRequest(
                                      4,
                                      userInfo["first_name"],
                                      userInfo["last_name"],
                                      userInfo["phone_number"],
                                      userInfo["title"],
                                      userInfo["id"]);
                                } else {
                                  String firstName = widget.firstName ?? '';
                                  String lastName = widget.lastName ?? '';
                                  String phoneNumber = widget.phoneNumber ?? '';
                                  String gender = widget.gender ?? '';
                                  await sendPaymentRequest(
                                      4,
                                      firstName,
                                      lastName,
                                      phoneNumber,
                                      gender,
                                      0); // Send default values for non-user
                                }
                                print('Payer par Wave');
                              },
                              child: const Text('Payer par Wave',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0)),
                            ),
                          ),
                          SizedBox(height: 26),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 40.0),
                                backgroundColor:
                                    Color.fromARGB(255, 241, 129, 36),
                              ),
                              onPressed: () async {
                                if (widget.isForMe) {
                                  var userInfo = await getUserInfo();
                                  await sendPaymentRequest(
                                      0,
                                      userInfo["first_name"],
                                      userInfo["last_name"],
                                      userInfo["phone_number"],
                                      userInfo["title"],
                                      userInfo["id"]);
                                } else {
                                  String firstName = widget.firstName ?? '';
                                  String lastName = widget.lastName ?? '';
                                  String phoneNumber = widget.phoneNumber ?? '';
                                  String gender = widget.gender ?? '';
                                  await sendPaymentRequest(
                                      0,
                                      firstName,
                                      lastName,
                                      phoneNumber,
                                      gender,
                                      0); // Send default values for non-user
                                }
                                print('Payer par Orange Money');
                              },
                              child: const Text('Payer par Orange money',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
