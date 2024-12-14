import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/voyage/BookingListScreen.dart';
import 'package:bakhbade/Services/bookingservice.dart';

class BookingPage extends StatefulWidget {
  final int bookingId;

  BookingPage({required this.bookingId, Key? key}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late Map<String, dynamic> booking;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBooking();
  }

  Future<void> _fetchBooking() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await fetchBooking(widget.bookingId);

      setState(() {
        booking = response ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erreur lors du chargement de la réservation : $e";
        isLoading = false;
      });
    }
  }

  Future<void> _refreshBooking() async {
    await _fetchBooking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la réservation'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: _refreshBooking,
                  child: BookingDetailScreen(booking: booking),
                ),
    );
  }
}
