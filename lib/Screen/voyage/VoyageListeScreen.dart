import 'package:bakhbade/Screen/voyage/DepartureArrivalScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_share/social_share.dart';
import 'package:flutter/material.dart';

class VoyageListeScreen extends StatefulWidget {
  final int pathId; // Add pathId variable

  VoyageListeScreen(
      {required this.pathId}); // Initialize pathId in the constructor

  @override
  _VoyageListeScreenState createState() => _VoyageListeScreenState();
}

class _VoyageListeScreenState extends State<VoyageListeScreen> {
  List<dynamic> trips = [];
  bool isLoading = false;

  void showReservationDialog(BuildContext context, dynamic trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isForMe = true; // Default selection

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Réservation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Pour moi'),
                    leading: Radio(
                      value: true,
                      activeColor: Colors.amberAccent,
                      groupValue: isForMe,
                      onChanged: (bool? value) {
                        setState(() {
                          isForMe = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Pour un autre'),
                    leading: Radio(
                      value: false,
                      activeColor: Colors.amberAccent,
                      groupValue: isForMe,
                      onChanged: (bool? value) {
                        setState(() {
                          isForMe = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartureArrivalScreen(
                          pathId: widget.pathId,
                          trip: trip,
                          isForMe: isForMe,
                        ), // Pass the trip object
                      ),
                    );
                  },
                  child: Text('Continuer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTrips(); // Fetch data when the screen loads
  }

  void _shareOnWhatsApp(String travelName, int travelId) async {
    final message =
        "Bonjour, veuillez cliquer sur le lien suivant pour faire votre réservation pour $travelName : https://khoulefreres.com/booking/create?travel_id=$travelId";
    final whatsappUrl = "whatsapp://send?text=${Uri.encodeFull(message)}";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      // Handle the error
      print("WhatsApp is not installed.");
    }
  }

  Future<void> fetchTrips() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('api_token');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var request = http.Request(
      'GET',
      Uri.parse('https://khoule-et-freres.com/api/travel/future'),
    );

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedData = json.decode(responseBody) as Map<String, dynamic>;
        setState(() {
          // Filter trips based on the path_id value
          trips = decodedData['data']?.where((trip) {
                return trip['path_id'].toString() ==
                    widget.pathId.toString(); // Filter trips by path_id
              }).toList() ??
              [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(title: Text('Voyages')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchTrips,
              child: ListView.builder(
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['name'] ?? 'Trip Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.calendarAlt,
                                      size: 16, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    'Date: ${trip['at_date_short'] ?? 'Unknown'}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.moneyBill,
                                      size: 16, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    '${trip['price'] ?? 'Unknown'} CFA',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showReservationDialog(
                                      context, trip); // Open dialog
                                },
                                child: Text('Réserver',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow[700],
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  String travelId =
                                      trip['id'].toString(); // Get travel ID
                                  String message =
                                      'Bonjour, veuillez cliquer sur le lien suivant pour faire votre réservation pour ${trip['name']}: https://khoulefreres.com/booking/create?travel_id=$travelId';

                                  SocialShare.shareWhatsapp(message);
                                },
                                child: Text('Partager'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
