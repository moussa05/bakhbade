import 'package:flutter/material.dart';
import 'package:bakhbade/models/Booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  BookingDetailsScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Réservation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Référence: ${booking.reference}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Statut: ${booking.statusText}',
                style: TextStyle(
                    fontSize: 18,
                    color: booking.isPaid ? Colors.green : Colors.red)),
            SizedBox(height: 10),
            Text('Prix: ${booking.price} FCFA', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Départ: ${booking.departure}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Arrivée: ${booking.arrival}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date de création: ${booking.createdAt}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ajouter des actions pour "Plus de détails" ou redirection vers un paiement
              },
              child: Text('Plus de détails'),
            ),
          ],
        ),
      ),
    );
  }
}
