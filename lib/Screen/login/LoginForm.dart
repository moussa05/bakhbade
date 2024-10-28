import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bakhbade/Screen/login/ForgotPasswordLink.dart';
import 'package:bakhbade/Screen/login/SocialButton.dart';
import 'package:bakhbade/Screen/voyage/HomeScreen.dart';
import 'package:bakhbade/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService =
      AuthService(); // Service pour l'authentification

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    String phoneNumber = phoneController.text.trim();
    String password = passwordController.text.trim();

    // Vérifie que les champs ne sont pas vides
    if (phoneNumber.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
          "Champs obligatoires", "Veuillez remplir tous les champs.");
      return; // Arrête la méthode si les champs sont vides
    }

    var result = await authService.login(phoneNumber, password);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      if (result["type"] == "danger") {
        String errorMessage = result["message"];
        _showErrorDialog("Erreur de connexion", errorMessage);
      } else {
        // Succès, rediriger l'utilisateur vers la page d'accueil
        print("Connexion réussie: $result");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstLaunch', false);
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('first_name', result["data"]["first_name"]);
        await prefs.setString('last_name', result["data"]["last_name"]);
        await prefs.setString('phone_number', result["data"]["phone_number"]);
        await prefs.setString('title', result["data"]["title"]);

        await prefs.setString('api_token', result["data"]["api_token"]);
        await prefs.setInt('id', result["data"]["id"]);

        Navigator.push(context, MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return const HomeScreen();
          },
        ));
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearPhone() {
    phoneController.clear();
  }

  void _clearPassword() {
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 51, 51, 50),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              controller: phoneController,
              keyboardType:
                  TextInputType.phone, // Définit le type comme téléphone
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearPhone, // Effacer le contenu
                ),
                labelText: 'Numéro téléphone',
                filled: true,
                fillColor: Colors.white,
                floatingLabelStyle: const TextStyle(color: Colors.amber),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber, width: 2.0),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearPassword, // Effacer le contenu
                ),
                labelText: 'Mot de passe',
                filled: true,
                fillColor: Colors.white,
                floatingLabelStyle: const TextStyle(color: Colors.amber),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber, width: 2.0),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const ForgotPasswordLink(),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator() // Afficher un indicateur de chargement pendant la requête
              : Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.amber),
                    ),
                    onPressed: _login,
                    child: const Text(
                      'Se connecter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          SocialButton(
            icon: FontAwesomeIcons.google,
            label: 'Se connecter avec Google',
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          SocialButton(
            icon: FontAwesomeIcons.facebook,
            label: 'Se connecter avec Facebook',
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
