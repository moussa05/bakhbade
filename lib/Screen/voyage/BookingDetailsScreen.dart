import 'package:flutter/material.dart';
import 'package:bakhbade/models/Booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: const Text(
          'Détails Réservation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        color: Colors.orange.shade50,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    booking.createdAt,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: booking.createdFormatted,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.alarm,
                  label: 'Rendez-vous',
                  value: booking.reference,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Départ',
                  value: booking.departure,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.flag,
                  label: 'Arrivée',
                  value: booking.arrival,
                ),
                const SizedBox(height: 20),
                Divider(),
                const SizedBox(height: 10),
                _buildStatusRow(
                  label: 'Statut',
                  status: booking.statusText,
                  isPaid: booking.isPaid,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  icon: Icons.star,
                  label: 'Points-Sargal',
                  value: '${booking.point}',
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Ajouter des actions pour afficher plus de détails
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Voir Plus de Détails'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade700),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required String label,
    required String status,
    required bool isPaid,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPaid ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
