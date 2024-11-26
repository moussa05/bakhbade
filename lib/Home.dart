import 'package:bakhbade/Acueil.dart';
import 'package:bakhbade/Screen/formation/FormationHomeScreen.dart';
import 'package:bakhbade/Screen/voyage/BookingListScreen.dart';
import 'package:bakhbade/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/voyage/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final int initialIndex; // Ajoutez ce paramètre
  const Home({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex;

  // Initialisation avec l'index fourni ou 0 par défaut
  _HomeState() : _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // Liste des pages
  final List<Widget> _pages = [
    const Acueil(),
    const TravelBookingPage(),
    FormationListScreen(),
    BookingListScreen(),
  ];

  // Méthode pour changer la page en fonction de l'index sélectionné
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token'); // Supprimer le token
    // Rediriger vers l'écran de connexion après la déconnexion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  Widget _buildIcon(String assetPath, int index) {
    bool isSelected = _selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.transparent,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8), // Ajuster l'espacement si nécessaire
      child: Image.asset(
        assetPath,
        width: 39,
        height: 39,
        color: isSelected
            ? Colors.white
            : null, // Changer la couleur de l'image si nécessaire
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.orange,
          elevation: 0,
          title: const Text('BakhBaDé'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                // Confirmation avant la déconnexion
                bool? confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Déconnexion'),
                      content:
                          const Text('Voulez-vous vraiment vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Oui'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmLogout == true) {
                  await _logout();
                }
              },
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(225, 255, 255, 255),
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/home.png', 0),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/voyageB.png', 1),
              label: 'Voyages',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/Formationss.png', 2),
              label: 'Formation',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/reservations.png', 3),
              label: 'Mes Reservations',
            ),
          ],
        ));
  }
}
