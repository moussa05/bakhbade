import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bakhbade/Screen/login/BusWidget.dart';
import 'package:bakhbade/Screen/login/LoginPage.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(7),
          width: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              const BusWidget(), // Logo Image

              texteAvecStyle(
                  'Voyagez avec nous vers l’execellence !', 22, true),
              texteAvecStyle(
                  """Votre service de transport entre l'Université Gaston Berger 
            et Dakar. Réservez facilement votre place, suivez votre trajet, 
            et voyagez en toute sécurité avec Khoulé et Frère.""", 12, false),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.amber),
                ),
                onPressed: () {
                  return context.go('/login');
                  // Navigator.push(context, MaterialPageRoute<void>(
                  //   builder: (BuildContext context) {
                  //     return LoginPage();
                  //   },
                  // ));
                },
                child: const Text(
                  'Commencer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      )),
    );
    // ignore: dead_code
  }

  Text texteAvecStyle(String data, double scale, bool bold) {
    if (bold) {
      return Text(
        data,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: scale, fontWeight: FontWeight.bold),
      );
    } else {
      return Text(
        data,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: scale, fontWeight: FontWeight.normal),
      );
    }
  }
}
