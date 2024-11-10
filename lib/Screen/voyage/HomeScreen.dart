import 'dart:developer';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/e-commerce/CommerceHomeScreen.dart';
import 'package:bakhbade/Screen/formation/FormationHomeScreen.dart';
import 'package:bakhbade/Screen/login/BusWidget.dart';
import 'package:bakhbade/Screen/voyage/VoyageListeScreen.dart';
import 'dart:convert'; // Pour jsonDecode
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Controller to handle PageView and also handles initial page
  final _pageController = PageController(initialPage: 0);

  /// Controller to handle bottom nav bar and also handles initial page
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  int maxCount = 5;

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// widget list
    final List<Widget> bottomBarPages = [
      TravelBookingPage(
        controller: (_controller),
      ),
      FormationListScreen(),
      const CommerceHomeScreen(),
    ];
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              /// Provide NotchBottomBarController
              notchBottomBarController: _controller,
              color: Colors.white,
              showLabel: true,
              textOverflow: TextOverflow.visible,
              maxLine: 1,
              shadowElevation: 5,
              kBottomRadius: 28.0,

              // notchShader: const SweepGradient(
              //   startAngle: 0,
              //   endAngle: pi / 2,
              //   colors: [Colors.red, Colors.green, Colors.orange],
              //   tileMode: TileMode.mirror,
              // ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8.0)),
              notchColor: Colors.black87,

              /// restart app if you change removeMargins
              removeMargins: false,
              bottomBarWidth: 500,
              showShadow: false,
              durationInMilliSeconds: 300,

              itemLabelStyle: const TextStyle(fontSize: 10),

              elevation: 1,
              bottomBarItems: const [
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.bus_alert,
                    color: Color(0xFFFFB300),
                  ),
                  activeItem: Icon(
                    Icons.bus_alert,
                    color: Color(0xFFFFB300),
                  ),
                  itemLabel: 'voyages',
                ),
                BottomBarItem(
                  inActiveItem: Icon(Icons.school, color: Colors.blueGrey),
                  activeItem: Icon(
                    Icons.school,
                    color: Colors.blueAccent,
                  ),
                  itemLabel: 'Formation',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.shopping_cart,
                    color: Colors.blueGrey,
                  ),
                  activeItem: Icon(
                    Icons.shopping_cart,
                    color: Colors.pink,
                  ),
                  itemLabel: 'e-commerce',
                ),
              ],
              onTap: (index) {
                log('current selected index $index');
                _pageController.jumpToPage(index);
              },
              kIconSize: 24.0,
            )
          : null,
    );
  }
}

/// add controller to check weather index through change or not. in page 1

class TravelBookingPage extends StatefulWidget {
  final NotchBottomBarController? controller;

  const TravelBookingPage({Key? key, this.controller}) : super(key: key);

  @override
  _TravelBookingPageState createState() => _TravelBookingPageState();
}

class _TravelBookingPageState extends State<TravelBookingPage> {
  List<dynamic> dakarPlaces = [];
  List<dynamic> ugbPlaces = [];
  bool isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    loadPlacesData();
  }

  // Fonction pour charger les données de l'API ou depuis SharedPreferences
  Future<void> loadPlacesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Vérifie si les données de Dakar existent
    String? dakarData = prefs.getString('dakarPlaces');
    String? ugbData = prefs.getString('ugbPlaces');

    // Si les données de Dakar n'existent pas, fais une requête API
    if (dakarData == null || ugbData == null) {
      await fetchAndStoreData();
    } else {
      // Sinon, charge les données à partir de SharedPreferences
      setState(() {
        dakarPlaces = jsonDecode(dakarData);
        ugbPlaces = jsonDecode(ugbData);
        isLoading = false; // Fin du chargement
      });
    }
  }

  // Fonction pour récupérer les données de l'API et les stocker dans SharedPreferences
  Future<void> fetchAndStoreData() async {
    var headers = {
      'Accept': 'application/json',
    };
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

      // Trier les places en fonction de la valuation
      for (var place in places) {
        if (place['valuation'] == '42') {
          dakarList.add(place);
        } else if (place['valuation'] == '6.5') {
          ugbList.add(place);
        }
      }

      // Sauvegarder dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('dakarPlaces', jsonEncode(dakarList));
      await prefs.setString('ugbPlaces', jsonEncode(ugbList));

      // Mettre à jour l'état local pour afficher les données
      setState(() {
        dakarPlaces = dakarList;
        ugbPlaces = ugbList;
        isLoading = false; // Fin du chargement
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false; // Fin du chargement en cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // Ensure the layout adjusts with the keyboard
      body: Center(
        child: isLoading // Affiche le spinner si isLoading est vrai
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                // This allows the screen to scroll when necessary
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: isPortrait ? 10 : 5),
                      Container(
                        height: MediaQuery.of(context).size.height *
                            (isPortrait ? 0.25 : 0.15),
                        child: BusWidget(),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: MediaQuery.of(context).size.width *
                            (isPortrait ? 0.9 : 0.7),
                        height: MediaQuery.of(context).size.height *
                            (isPortrait ? 0.3 : 0.4),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 10),
                              CustomButton(
                                  label: 'DAKAR ------> UGB',
                                  onPressed: () {
                                    // Passer les données de Dakar à l'écran suivant
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VoyageListeScreen(
                                            pathId: 1), // Pass the places
                                      ),
                                    );
                                  }),
                              SizedBox(height: 26),
                              CustomButton(
                                  label: 'UGB ------> DAKAR',
                                  onPressed: () {
                                    // Passer les données de UGB à l'écran suivant
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VoyageListeScreen(
                                            pathId: 2), // Pass the places
                                      ),
                                    );
                                  }),
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

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFB300), // Yellow color
          padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 40.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
    );
  }
}
