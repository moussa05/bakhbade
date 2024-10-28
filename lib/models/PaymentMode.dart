class PaymentMode {
  final int id;
  final int bookingId;
  final String paymentId;
  final String type;
  final String methode;

  PaymentMode(
      {required this.id,
      required this.bookingId,
      required this.paymentId,
      required this.type,
      required this.methode});

  // Convert to a map to save in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'paymentId': paymentId,
      'type': type,
      'methode': methode,
    };
  }

  // Factory method to create a Payment from a map
  factory PaymentMode.fromMap(Map<String, dynamic> map) {
    return PaymentMode(
      id: map['id'],
      bookingId: map['bookingId'],
      paymentId: map['paymentId'],
      type: map['type'],
      methode: map['methode'],
    );
  }
  @override
  String toString() {
    return 'PaymentMode{id: $id, bookingId: $bookingId, paymentId: $paymentId, type: $type,methode: $methode}';
  }
}
