import 'package:flutter/material.dart';
import 'package:bakhbade/Screen/voyage/BookingDetailsScreen.dart';
import 'package:bakhbade/Services/bookingservice.dart';
import 'package:bakhbade/models/Booking.dart';

class BookingPage extends StatefulWidget {
  final int bookingId;

  BookingPage({required this.bookingId});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Booking? booking;

  @override
  void initState() {
    super.initState();
    fetchBooking(widget.bookingId).then((value) {
      setState(() {
        booking = value;
      });
    });
  }

  Future<void> _refreshBooking() async {
    final updatedBooking = await fetchBooking(widget.bookingId);
    setState(() {
      booking = updatedBooking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshBooking,
        child: booking == null
            ? Center(child: CircularProgressIndicator())
            : BookingDetailsScreen(booking: booking!),
      ),
    );
  }
}
