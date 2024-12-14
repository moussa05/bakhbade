import 'package:bakhbade/Services/PaymentService.dart';
import 'package:bakhbade/Services/ServiceBooking.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingListScreen extends StatefulWidget {
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() {
    setState(() {
      _bookingsFuture = BookingService().fetchBookings();
    });
  }

  Future<void> _refreshBookings() async {
    await BookingService().fetchBookings();
    setState(() {
      _fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Liste des Voyages'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text(
                    'Vérifiez votre connexion',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _refreshBookings(); // Relancer la requête
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune réservation trouvée'));
          }

          var bookings = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshBookings,
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index];
                var travel = booking['travel'];
                return _buildTravelCard(context, travel, booking);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTravelCard(BuildContext context, Map<String, dynamic> travel,
      Map<String, dynamic> booking) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              travel['name'] ?? 'Nom du Voyage',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: FontAwesomeIcons.mapMarkerAlt,
              label: 'Départ',
              value: travel['departure']['name'] ?? 'Inconnu',
              iconColor: Colors.blue,
            ),
            _buildInfoRow(
              icon: FontAwesomeIcons.flagCheckered,
              label: 'Arrivée',
              value: travel['arrival']['name'] ?? 'Inconnu',
              iconColor: Colors.green,
            ),
            _buildInfoRow(
              icon: FontAwesomeIcons.calendarAlt,
              label: 'Date',
              value: travel['at_formatted'] ?? 'Inconnue',
              iconColor: Colors.purple,
            ),
            _buildInfoRow(
              icon: FontAwesomeIcons.moneyBill,
              label: 'Prix',
              value: '${booking['price']} FCFA',
              iconColor: Colors.teal,
            ),
            _buildInfoRow(
              icon: FontAwesomeIcons.infoCircle,
              label: 'Statut',
              value: booking['status_text'] ?? 'Non spécifié',
              iconColor: Colors.red,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingDetailScreen(booking: booking),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Détails'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({required this.booking, Key? key})
      : super(key: key);

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(); // Initialize the payment service
  }

  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    var travel = widget.booking['travel'];

    // Vérifie si la réservation est payée
    bool isPaid = widget.booking['is_paid'];

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Détails de la Réservation'),
        backgroundColor: const Color(0xFFFFB300),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal du voyage
              Card(
                color: Color.fromARGB(255, 250, 251, 252),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    travel['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Informations détaillées
              _buildDetailRow('Départ', travel['departure']['name']),
              const Divider(height: 33),
              _buildDetailRow('Arrivée', travel['arrival']['name']),
              const Divider(height: 33),
              _buildDetailRow('Date', travel['at_formatted']),
              const Divider(height: 33),
              _buildDetailRow('Statut', widget.booking['status_text']),
              const Divider(height: 33),
              _buildDetailRow('Prix', '${widget.booking['price']} FCFA'),
              const Divider(height: 33),
              _buildDetailRow(
                  'Siège', widget.booking['sit_number'] ?? 'Non attribué'),
              const Divider(height: 33),

              // Boutons de paiement si la réservation n'est pas encore payée
              if (!isPaid)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bouton pour payer par Wave
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _payWithWave(context);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Payer par Wave'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white, // Texte en blanc
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 10), // Espace entre les deux boutons
                      // Bouton pour payer par Orange Money
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _payWithOrangeMoney(context);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Payer par Orange Money'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white, // Texte en blanc
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
// Bouton pour voir la facture si elle est disponible
              // if (isPaid && widget.booking['invoice_link'] != null)
              //   Center(
              //     child: ElevatedButton.icon(
              //       onPressed: () {
              //         print(
              //             'Lien de la facture : ${widget.booking['invoice_link']}');
              //       },
              //       icon: const Icon(Icons.receipt),
              //       label: const Text('Voir la facture'),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.green,
              //         foregroundColor: Colors.white, // Texte en blanc
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20),
              //         ),
              //       ),
              //     ),
              //   ),

              // // Bouton pour voir la facture si elle est disponible
              // if (isPaid && widget.booking['invoice_link'] != null)
              //   Center(
              //     child: ElevatedButton.icon(
              //       onPressed: () {
              //         print(
              //             'Lien de la facture : ${widget.booking['invoice_link']}');
              //       },
              //       icon: const Icon(Icons.receipt),
              //       label: const Text('Voir la facture'),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.green,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper pour afficher chaque ligne d'information
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder pour le paiement par Wave

  void _payWithWave(BuildContext context) async {
    final amount = (widget.booking['price'] is int)
        ? (widget.booking['price'] as int).toDouble()
        : widget
            .booking['price']; // Si déjà un double, on l'utilise directement
    final bookingId = widget.booking['id']; // Identifiant de la réservation

    try {
      // Appel à la méthode de paiement Wave
      final paymentResponse = await _paymentService.getPaymentUrl(
        amount: amount,
        booking: bookingId,
        errorUrl: 'https://khoulefreres.com/error',
        successUrl: 'https://khoulefreres.com/success',
      );
      if (paymentResponse != null || paymentResponse['id'] != null) {
        final paymentUrl = paymentResponse['payment_url'];
        print('URL de paiement Wave : $paymentUrl');

        // Ouvrir l'URL de paiement dans un navigateur ou WebView
        final Uri waveLaunchUrl = Uri.parse(paymentResponse['wave_launch_url']);
        _launchUrl(waveLaunchUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement Wave initié')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Erreur lors de la récupération de l\'URL de paiement')),
        );
      }
    } catch (e) {
      // Gérer l'erreur et afficher un message dans le ScaffoldMessenger
      print('Erreur de paiement Wave : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de paiement Wave : $e')),
      );
    }
  }

  void _payWithOrangeMoney(BuildContext context) async {
    final amount = (widget.booking['price'] is int)
        ? (widget.booking['price'] as int).toDouble()
        : widget
            .booking['price']; // Si déjà un double, on l'utilise directement
    final bookingId = widget.booking['id']; // Identifiant de la réservation

    try {
      final paymentResponse = await _paymentService.initiateOrangeMoneyPayment(
        amount: amount,
        bookingId: bookingId,
      );

      if (paymentResponse != null || paymentResponse['deepLinks'] != null) {
        final Uri waveLaunchUrl =
            Uri.parse(paymentResponse["deepLinks"]['MAXIT']);
        _launchUrl(waveLaunchUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement Orange Money initié')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de paiement avec Orange Money')),
        );
      }
    } catch (e) {
      // Gérer l'erreur et afficher un message dans le ScaffoldMessenger
      print('Erreur de paiement Orange Money ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de paiement Orange Money')),
      );
    }
  }
}
