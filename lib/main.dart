import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/login/LoginPage.dart';
import 'package:bakhbade/Screen/voyage/BookingPage.dart';
import 'package:bakhbade/Screen/voyage/HomeScreen.dart';
import 'package:bakhbade/WelcomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
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
  bool _isLoading = true; // Add a loading state

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _initApp();
    _initUniLinks();
  }

  Future<void> _initApp() async {
    await _checkIfFirstTime();
    await _checkIfLoggedIn();

    setState(() {
      _isLoading = false; // Set loading to false after initialization
    });

    _router = GoRouter(
      initialLocation:
          _isLoggedIn ? '/home' : (_isFirstTime ? '/welcome' : '/login'),
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            if (_isLoggedIn) {
              return HomeScreen();
            } else {
              return LoginPage();
            }
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
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
            builder: (context, state) {
              if (_isLoggedIn) {
                return HomeScreen();
              } else if (!_isFirstTime) {
                return LoginPage();
              } else {
                return WelcomePage();
              }
            }),
      ],
    );
  }

  Future<void> _initUniLinks() async {
    try {
      linkStream.listen((String? link) {
        if (link != null) {
          _handleIncomingLink(link);
        }
      });
    } catch (e) {
      print('Failed to get latest link: $e');
    }
  }

  void _handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    if (uri.pathSegments.length > 1 && uri.pathSegments[0] == 'booking') {
      final bookingId = uri.pathSegments[1];
      _router.go('/booking/$bookingId'); // Use GoRouter for navigation
    }
  }

  Future<void> _checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('isFirstLaunch') ?? true;
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isAuthenticated') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while checking states
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFFB300),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFFFFCC80),
        ),
        backgroundColor: Color(0xFFF5F5F5),
        cardColor: Color(0xFFFFFFFF),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Color(0xFF000000)),
        ),
      ),
      routerConfig: _router, // Use GoRouter's configuration
    );
  }
}
