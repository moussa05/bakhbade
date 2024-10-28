class Booking {
  final int id;
  final String reference;
  final String status;
  final double price;
  final String createdAt;
  final String departure;
  final String arrival;
  final String statusText;
  final bool isPaid;

  Booking({
    required this.id,
    required this.reference,
    required this.status,
    required this.price,
    required this.createdAt,
    required this.departure,
    required this.arrival,
    required this.statusText,
    required this.isPaid,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      reference: json['reference'],
      status: json['status'],
      price: json['price_from_booking'].toDouble(),
      createdAt: json['created_at_formatted'],
      departure: json['departure']['name'],
      arrival: json['arrival']['name'],
      statusText: json['status_text'],
      isPaid: json['is_paid'],
    );
  }
}
