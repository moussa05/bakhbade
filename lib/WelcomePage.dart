import 'package:bakhbade/Home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

final List<String> imagePaths = [
  "assets/welcome/ticket.png",
  "assets/welcome/achats.png",
  "assets/welcome/formation.png",
  "assets/welcome/colis.png",
];

late List<Widget> _pages;

class _WelcomePageState extends State<WelcomePage> {
  int _activePage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  bool _isChecked = false;
  bool _isRegistering = false;
  bool _isLoading = false;
  bool _isOtpForm = false; // Flag to toggle OTP form visibility
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _otpController =
      TextEditingController(); // OTP Controller
  String? _gender = "Male";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _otpFormKey =
      GlobalKey<FormState>(); // OTP Form Key

  @override
  void initState() {
    super.initState();
    _pages = List.generate(
      imagePaths.length,
      (index) => ImagePlaceholder(imagePath: imagePaths[index]),
    );

    _pageController.addListener(() {
      int newPage = _pageController.page!.round();
      if (newPage != _activePage) {
        setState(() {
          _activePage = newPage;
        });
      }
    });
  }

  String generateOtp() {
    // Générer un nombre aléatoire entre 100000 et 999999
    Random random = Random();
    int otp = 100000 + random.nextInt(900000); // 900000 = 999999 - 100000 + 1
    return otp.toString();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool _isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^(77|78|70|76|75)\d{7}$');
    return regex.hasMatch(phone);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> saveOTPToDatabase(String phone, String otp) async {
    try {
      var response = await http.post(
        Uri.parse('https://khoulefreres.com/api/user/saveOpt'),
        headers: {'Accept': 'application/json'},
        body: {'phone': phone, 'otp': otp},
      );

      if (response.statusCode == 200) {
        print('OTP enregistré avec succès');
      } else {
        print('Échec de l\'enregistrement de l\'OTP : ${response.body}');
        _showSnackBar('Échec de l\'enregistrement de l\'OTP.');
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement : $e');
      _showSnackBar('Erreur lors de l\'enregistrement de l\'OTP.');
    }
  }

  Future<void> sendOtpViaWhatsApp(String recipientNumber, String otp) async {
    final String accessToken = dotenv.env['ACCESS_TOKEN']?.trim() ?? '';
    final String phoneNumberId = dotenv.env['PHONE_NUMBER_ID']?.trim() ?? '';

    if (accessToken.isEmpty || phoneNumberId.isEmpty) {
      print("Les variables d'environnement sont manquantes.");
      _showSnackBar("Les variables d'environnement sont manquantes.");
      return;
    }

    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    var url =
        Uri.parse('https://graph.facebook.com/v17.0/$phoneNumberId/messages');

    var body = json.encode({
      "messaging_product": "whatsapp",
      "to": recipientNumber,
      "type": "template",
      "template": {
        "name": "code",
        "language": {"code": "fr"},
        "components": [
          {
            "type": "body",
            "parameters": [
              {"type": "text", "text": otp}
            ]
          },
          {
            "type": "button",
            "sub_type": "url",
            "index": "0",
            "parameters": [
              {"type": "text", "text": otp}
            ]
          }
        ]
      }
    });
    try {
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: body);
      if (response.statusCode == 200) {
        print("OTP envoyé avec succès : $otp");
        _showSnackBar("OTP envoyé avec succès.");
      } else {
        print("Erreur lors de l'envoi : ${response.body}");
        _showSnackBar("Erreur lors de l'envoi : ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Erreur lors de la requête : $e");
      _showSnackBar("Erreur lors de la requête : $e");
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    String otp = generateOtp();

    final data = {
      'phone': _phoneController.text,
      'name': _nameController.text,
      'surname': _surnameController.text,
      'gender': _gender,
    };

    try {
      await sendOtpViaWhatsApp(_phoneController.text, otp);
      await saveOTPToDatabase(_phoneController.text, otp);

      // Si tout est réussi, afficher le formulaire OTP
      setState(() => _isOtpForm = true);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'utilisateur : $e');
      _showSnackBar('Erreur lors de l\'enregistrement de l\'utilisateur : $e');
    } finally {
      setState(() => _isLoading = false);
    }

    print('User data sent: $data');
  }

  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    if (_otpController.text.length != 6) {
      _showSnackBar("Le code OTP doit contenir exactement 6 chiffres.");
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'phone': _phoneController.text,
      'name': _nameController.text,
      'surname': _surnameController.text,
      'gender': _gender,
      'otp': _otpController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://khoulefreres.com/api/user/app'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        if (result.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);
          await prefs.setString(
              'first_name', result['user']["first_name"] ?? '');
          await prefs.setString('last_name', result['user']["last_name"] ?? '');
          await prefs.setString(
              'phone_number', result['user']["phone_number"] ?? '');
          await prefs.setString('api_token', result['user']["api_token"] ?? '');
          await prefs.setString('fidelite', result['user']["fidelite"] ?? '0');
          await prefs.setInt('id', result['user']["id"] ?? 0);
          Navigator.push(context, MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return const Home();
            },
          ));
        }
      } else {
        _showSnackBar('Erreur lors de la vérification de l\'OTP.');
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la connexion : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) => _pages[index],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        _pages.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: InkWell(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Container(
                              width: 49,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _activePage == index
                                    ? Colors.yellow
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _isOtpForm
                      ? _buildOtpForm()
                      : _isRegistering
                          ? _buildRegistrationForm()
                          : _buildPhoneForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Numéro de téléphone",
            filled: true,
            fillColor: Colors.white,
            floatingLabelStyle: const TextStyle(color: Colors.amber),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 2.0),
            ),
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showSnackBar("Numéro requis");
              return null;
            }
            if (!_isValidPhoneNumber(value)) {
              _showSnackBar("Numéro invalide");
              return null;
            }
            return null;
          },
        ),
        SizedBox(height: 10),
        CheckboxListTile(
          value: _isChecked,
          onChanged: (value) => setState(() => _isChecked = value!),
          title: Text(
            "Accepter les conditions générales",
            style: TextStyle(fontSize: 12),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              _isChecked ? Colors.amber : Colors.grey,
            ),
          ),
          onPressed: _isChecked
              ? () {
                  if (_isValidPhoneNumber(_phoneController.text)) {
                    setState(() => _isRegistering = true);
                  } else {
                    _showSnackBar("Veuillez entrer un numéro valide");
                  }
                }
              : null,
          child: Text(
            "Continuer",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Nom",
              filled: true,
              fillColor: Colors.white,
              floatingLabelStyle: const TextStyle(color: Colors.amber),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber, width: 2.0),
              ),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _surnameController,
            decoration: InputDecoration(
              labelText: "Prénom",
              filled: true,
              fillColor: Colors.white,
              floatingLabelStyle: const TextStyle(color: Colors.amber),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber, width: 2.0),
              ),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un prénom';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Radio<String>(
                value: 'Male',
                groupValue: _gender,
                onChanged: (value) => setState(() => _gender = value),
                activeColor: Colors.amber,
              ),
              Text("Homme"),
              Radio<String>(
                value: 'Female',
                groupValue: _gender,
                onChanged: (value) => setState(() => _gender = value),
                activeColor: Colors.amber,
              ),
              Text("Femme"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _isRegistering = false),
                child: Text("Retour"),
              ),
              ElevatedButton(
                onPressed: _registerUser,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Valider"),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: "Entrez le OTP",
              filled: true,
              fillColor: Colors.white,
              floatingLabelStyle: const TextStyle(color: Colors.amber),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber, width: 2.0),
              ),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.security),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le code OTP';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _isOtpForm = false),
                child: Text("Retour"),
              ),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Vérifier OTP"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  final String imagePath;

  ImagePlaceholder({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}
