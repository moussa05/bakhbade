import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bakhbade/Home.dart';
import 'package:bakhbade/Screen/voyage/BookingPage.dart';
import 'package:bakhbade/WelcomePage.dart';
import 'dart:async';

Future<void> main() async {
  // Assurer le chargement des variables d'environnement
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstTime = true;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    print(_isFirstTime);
    _initializeApp();
  }

  /// Initialiser l'application avec les vérifications nécessaires
  Future<void> _initializeApp() async {
    // Charger les données de manière asynchrone
    await Future.wait([
      _checkIfFirstTime(),
      _checkIfLoggedIn(),
    ]);

    // Initialiser le routeur après avoir chargé les états
    setState(() {
      _initializeRouter();
      _isLoading = false;
    });

    // Initialiser les liens dynamiques en arrière-plan
    _initUniLinks();
  }

  /// Configurer le routeur GoRouter
  void _initializeRouter() {
    _router = GoRouter(
      initialLocation: _isLoggedIn ? '/home' : '/welcome',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => _isLoggedIn ? Home() : WelcomePage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Home(),
        ),
        GoRoute(
          path: '/booking/:bookingId',
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId']!;
            return BookingPage(bookingId: int.parse(bookingId));
          },
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => _isLoggedIn ? Home() : WelcomePage(),
        ),
      ],
    );
  }

  /// Vérifier si c'est la première utilisation
  Future<void> _checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('isFirstLaunch') ?? true;
  }

  /// Vérifier si l'utilisateur est connecté
  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isAuthenticated') ?? false;
  }

  /// Initialiser les liens dynamiques pour les redirections
  Future<void> _initUniLinks() async {
    try {
      // Récupérer le lien initial si l'application est lancée à partir d'un lien
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }

      // Écouter les liens entrants pendant que l'application est en cours d'exécution
      linkStream.listen((String? link) {
        if (link != null) {
          _handleIncomingLink(link);
        }
      });
    } catch (e) {
      print('Erreur lors de la récupération des liens dynamiques : $e');
    }
  }

  /// Gérer les liens entrants pour la navigation
  void _handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    if (uri.pathSegments.length > 1 && uri.pathSegments[0] == 'booking') {
      final bookingId = uri.pathSegments[1];
      _router.go('/booking/$bookingId');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un indicateur de chargement pendant l'initialisation
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFB300),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFFFCC80),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        cardColor: const Color(0xFFFFFFFF),
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Color(0xFF000000)),
        ),
      ),
      routerConfig: _router,
    );
  }
}
