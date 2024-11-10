import 'dart:ffi';

import 'package:bakhbade/Screen/voyage/HomeScreen.dart';
import 'package:bakhbade/Screen/voyage/VoyageListeScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Acueil extends StatefulWidget {
  const Acueil({Key? key}) : super(key: key);

  @override
  State<Acueil> createState() => _AcueilState();
}

class _AcueilState extends State<Acueil> {
  int _selectedIndex = 0; // Indice pour le BottomNavigationBar

  String _fullname = 'Invité';
  String _fidelite = '0';
  bool _showFidelite = false; // État pour afficher/cacher les points

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  // Fonction pour charger les informations utilisateur depuis SharedPreferences
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstName = prefs.getString('first_name') ?? '';
    String lastName = prefs.getString('last_name') ?? '';
    String fidelite = prefs.getString('fidelite') ?? '0';
    setState(() {
      _fullname = "$lastName $firstName".trim();
      _fidelite = fidelite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(
          _fullname,
          style: TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section des icônes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconCard(
                  label: 'Boutique',
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                  onPressed: () async {
                    var url = Uri.parse('https://bakhbade.com/');
                    _launchUrl(url);
                  },
                ),
                _buildIconCard(
                  label: 'Yobanté',
                  icon: Icons.delivery_dining,
                  color: Colors.brown,
                  onPressed: () {
                    var url =
                        Uri.parse('https://bakhbade.com/service-yobante/');
                    _launchUrl(url);
                    // Naviguer vers une autre page ou exécuter une action
                  },
                ),
                _buildIconCard(
                  label: 'Formation',
                  icon: Icons.school,
                  color: Colors.grey,
                  onPressed: () {
                    var url = Uri.parse('https://academy.bakhbade.com/');
                    _launchUrl(url);
                    // Naviguer vers une autre page ou exécuter une action
                  },
                ),
                _buildIconCard(
                  label: 'Voyage',
                  icon: Icons.airport_shuttle,
                  color: Colors.orange,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return const TravelBookingPage();
                      },
                    ));
                    // Naviguer vers une autre page ou exécuter une action
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Section de réservation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'RESERVER TICKET VOYAGE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'SELECTIONNER VOTRE TRAJET',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRouteButton(
                          title: 'DAKAR ➞ UGB',
                          onPressed: () {
                            // Action à réaliser lors du clic sur Sargal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VoyageListeScreen(
                                    pathId: 1), // Pass the places
                              ),
                            );
                          }),
                      _buildRouteButton(
                          title: 'UGB ➞ DAKAR',
                          onPressed: () {
                            // Action à réaliser lors du clic sur Sargal
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Sargal avec fonctionnalité d'affichage/cachage des points
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icône cadeau
                  Icon(Icons.card_giftcard, color: Colors.yellow, size: 24),

                  // Texte "SARGAL"
                  const Text(
                    'SARGAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    width: 70, // Ajustez la largeur à votre convenance
                    height: 4.3, // Hauteur du trait
                    color: Colors.white, // Couleur du trait
                  ),
                  if (_showFidelite)
                    Center(
                      child: Text(
                        '$_fidelite',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Icône pour afficher/cacher les points
                  IconButton(
                    icon: Icon(
                      _showFidelite ? Icons.visibility : Icons.visibility_off,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFidelite = !_showFidelite;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Affichage des points de fidélité
          ],
        ),
      ),
    );
  }

  // Fonction pour créer les boutons de trajet
  Widget _buildRouteButton(
      {required String title, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(color: Colors.yellow),
      ),
    );
  }

  // Fonction pour créer les icônes de la section
  // Fonction pour créer les icônes sous forme de rectangle
  Widget _buildIconCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed, // Fonction onPressed passée en paramètre
      borderRadius: BorderRadius.circular(12), // Effet d'ondulation
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: 70,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
