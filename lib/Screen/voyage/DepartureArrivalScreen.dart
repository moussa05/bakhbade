import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bakhbade/Screen/login/BusWidget.dart';
import 'package:bakhbade/models/Location.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bakhbade/Screen/voyage/PaymentScreen.dart';

class DepartureArrivalScreen extends StatefulWidget {
  final int pathId;
  final dynamic trip;
  final bool isForMe;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? gender;

  DepartureArrivalScreen({
    required this.pathId,
    required this.trip,
    required this.isForMe,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.gender,
  });

// Update constructor

  @override
  _DepartureArrivalScreenState createState() => _DepartureArrivalScreenState();
}

class _DepartureArrivalScreenState extends State<DepartureArrivalScreen> {
  List<dynamic> dakarPlaces = [];
  List<dynamic> ugbPlaces = [];
  String? selectedDeparture;
  String? selectedArrival;
  bool isLoading = true;
  late final Location departure;
  late final Location arrival;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedGender = 'Monsieur';

  @override
  void initState() {
    super.initState();
    loadPlacesData();
  }

  @override
  void dispose() {
    // Libération de la mémoire pour chaque TextEditingController
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadPlacesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the data for Dakar and UGB exists
    String? dakarData = prefs.getString('dakarPlaces');
    String? ugbData = prefs.getString('ugbPlaces');

    // If data for Dakar or UGB doesn't exist, fetch it from the API
    if (dakarData == null || ugbData == null) {
      await _fetchPlaces();
    } else {
      // Otherwise, load the data from SharedPreferences
      setState(() {
        dakarPlaces = jsonDecode(dakarData);
        ugbPlaces = jsonDecode(ugbData);
        isLoading = false; // Loading complete
      });
    }
  }

  Future<void> _fetchPlaces() async {
    var headers = {'Accept': 'application/json'};
    var request = http.Request(
        'GET', Uri.parse('https://khoule-et-freres.com/api/place'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      List<dynamic> places = jsonResponse['data']['data'];

      List<dynamic> dakarList = [];
      List<dynamic> ugbList = [];

      // Filter places based on valuation
      for (var place in places) {
        if (place['valuation'] == '42') {
          dakarList.add(place);
        } else if (place['valuation'] == '6.5') {
          ugbList.add(place);
        }
      }

      // Trier chaque liste par la valeur 'order' croissante
      dakarList.sort(
          (a, b) => int.parse(a['order']).compareTo(int.parse(b['order'])));
      ugbList.sort(
          (a, b) => int.parse(a['order']).compareTo(int.parse(b['order'])));

      // Save data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('dakarPlaces', jsonEncode(dakarList));
      await prefs.setString('ugbPlaces', jsonEncode(ugbList));

      // Update local state to display the data
      setState(() {
        dakarPlaces = dakarList;
        ugbPlaces = ugbList;
        isLoading = false; // Loading complete
      });
    } else {
      print('Error: ${response.reasonPhrase}');
      setState(() {
        isLoading = false; // Loading complete in case of error
      });
    }
  }

  // Method to find Location object by name
  Location _findLocation(String name, List<dynamic> places) {
    final placeData = places.firstWhere((place) => place['name'] == name);
    return Location.fromJson(placeData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Sélectionner Départ et Arrivée')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPlaces,
              child: SingleChildScrollView(
                // Utilisation de SingleChildScrollView
                child: Center(
                  child: Column(
                    // Changer ListView en Column
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: BusWidget(),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: const EdgeInsets.all(10),
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            top: MediaQuery.of(context).viewInsets.top),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 51, 51, 50),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(height: 16),
                              if (!widget.isForMe)
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: TextFormField(
                                        controller: firstNameController,
                                        style: TextStyle(
                                            color: Colors
                                                .white), // Couleur du texte saisi
                                        cursorColor: Colors.white,
                                        decoration: InputDecoration(
                                          labelText: 'Prénom',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: TextFormField(
                                        controller: lastNameController,
                                        style: TextStyle(
                                            color: Colors
                                                .white), // Couleur du texte saisi
                                        cursorColor: Colors.white,
                                        decoration: InputDecoration(
                                          labelText: 'Nom',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: TextFormField(
                                        controller: phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(
                                            color: Colors
                                                .white), // Couleur du texte saisi
                                        cursorColor: Colors.white,
                                        decoration: InputDecoration(
                                          labelText: 'Numéro de téléphone',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors
                                                    .white, // Définit la couleur du contour comme blanc
                                                width:
                                                    2.0, // Définit l'épaisseur du contour
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                  5), // Pour arrondir les coins du cadre
                                            ),
                                            child: CheckboxListTile(
                                              value: selectedGender ==
                                                  'Monsieur', // Vérifie si "Monsieur" est sélectionné
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    selectedGender =
                                                        'Monsieur'; // Sélectionne "Monsieur"
                                                  } else {
                                                    selectedGender =
                                                        ''; // Désélectionne "Monsieur"
                                                  }
                                                });
                                              },
                                              title: Text(
                                                'Monsieur',
                                                style: TextStyle(
                                                    color: Colors
                                                        .white), // Couleur du texte
                                              ),
                                              activeColor: Colors
                                                  .yellow, // Couleur de la case à cocher sélectionnée
                                              checkColor: Colors
                                                  .black, // Couleur du coche
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  16), // Espacement entre les cases
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors
                                                    .white, // Définit la couleur du contour comme blanc
                                                width:
                                                    2.0, // Définit l'épaisseur du contour
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                  5), // Pour arrondir les coins du cadre
                                            ),
                                            child: CheckboxListTile(
                                              value: selectedGender ==
                                                  'Madame', // Vérifie si "Madame" est sélectionné
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    selectedGender =
                                                        'Madame'; // Sélectionne "Madame"
                                                  } else {
                                                    selectedGender =
                                                        ''; // Désélectionne "Madame"
                                                  }
                                                });
                                              },
                                              title: Text(
                                                'Madame',
                                                style: TextStyle(
                                                    color: Colors
                                                        .white), // Couleur du texte
                                              ),
                                              activeColor: Colors
                                                  .yellow, // Couleur de la case à cocher sélectionnée
                                              checkColor: Colors
                                                  .black, // Couleur du coche
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 16),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Point de départ',
                                    labelStyle: TextStyle(color: Colors.white),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0),
                                    ),
                                  ),
                                  value: selectedDeparture,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedDeparture = newValue;
                                      if (newValue != null) {
                                        departure = _findLocation(
                                            newValue,
                                            widget.pathId == 1
                                                ? dakarPlaces
                                                : ugbPlaces);
                                        print(
                                            'Départ sélectionné : $departure');
                                      }
                                    });
                                  },
                                  style: TextStyle(color: Colors.white),
                                  dropdownColor:
                                      Color.fromARGB(255, 51, 51, 50),
                                  items: (widget.pathId == 1
                                          ? dakarPlaces
                                          : ugbPlaces)
                                      .map<DropdownMenuItem<String>>((place) {
                                    return DropdownMenuItem<String>(
                                      value: place['name'],
                                      child: Text(place['name'],
                                          style:
                                              TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Point d\'arrivée',
                                    labelStyle: TextStyle(color: Colors.white),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0),
                                    ),
                                  ),
                                  value: selectedArrival,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedArrival = newValue;
                                      if (newValue != null) {
                                        arrival = _findLocation(
                                            newValue,
                                            widget.pathId == 1
                                                ? ugbPlaces
                                                : dakarPlaces);
                                        print('Départ sélectionné : $arrival');
                                      }
                                    });
                                  },
                                  style: TextStyle(color: Colors.white),
                                  dropdownColor:
                                      Color.fromARGB(255, 51, 51, 50),
                                  items: (widget.pathId == 1
                                          ? ugbPlaces
                                          : dakarPlaces)
                                      .map<DropdownMenuItem<String>>((place) {
                                    return DropdownMenuItem<String>(
                                      value: place['name'],
                                      child: Text(place['name'],
                                          style:
                                              TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 32),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color(0xFFFFB300), // Yellow color
                                  ),
                                  onPressed: () {
                                    if (selectedDeparture == null ||
                                        selectedArrival == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                'Veuillez sélectionner un départ et une arrivée.')),
                                      );
                                      return;
                                    }
                                    // Valider les informations si ce n'est pas pour l'utilisateur lui-même
                                    if (!widget.isForMe) {
                                      if (firstNameController.text.isEmpty ||
                                          lastNameController.text.isEmpty ||
                                          phoneController.text.isEmpty ||
                                          selectedGender == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Veuillez remplir tous les champs requis.')),
                                        );
                                        return;
                                      }
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentScreen(
                                          departure: departure,
                                          arrival: arrival,
                                          pathId: widget.pathId,
                                          travel: widget.trip,
                                          isForMe: widget.isForMe,
                                          firstName: widget.isForMe
                                              ? null
                                              : firstNameController.text,
                                          lastName: widget.isForMe
                                              ? null
                                              : lastNameController.text,
                                          phoneNumber: widget.isForMe
                                              ? null
                                              : phoneController.text,
                                          gender: widget.isForMe
                                              ? null
                                              : selectedGender,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Continuer',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
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
