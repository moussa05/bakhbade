import 'package:bakhbade/Acueil.dart';
import 'package:bakhbade/Screen/e-commerce/CommerceHomeScreen.dart';
import 'package:bakhbade/Screen/formation/FormationHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/voyage/HomeScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  // Liste des pages
  final List<Widget> _pages = [
    const Acueil(),
    const TravelBookingPage(),
    FormationListScreen(),
    const CommerceHomeScreen(),
  ];

  // Méthode pour changer la page en fonction de l'index sélectionné
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Mes Reservations'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Mes Colis'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Mes Commandes'),
        ],
      ),
    );
  }
}
