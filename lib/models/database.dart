import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'PaymentMode.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Ouvrir ou initialiser la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'payment_database.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE payments(id INTEGER PRIMARY KEY, bookingId INTEGER UNIQUE, paymentId TEXT,type TEXT)',
        );
      },
      version: 1,
    );
  }

  // Ajouter un nouveau paiement si le bookingId n'existe pas
  Future<void> insertPayment(PaymentMode payment) async {
    final db = await database;

    // Check if the bookingId exists in the payments table
    var result = await db.query(
      'payments',
      where: 'bookingId = ?',
      whereArgs: [payment.bookingId],
    );

    if (result.isEmpty) {
      // If bookingId doesn't exist, insert a new record
      await db.insert(
        'payments',
        payment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      print(
          'Payment ajouté : bookingId=${payment.bookingId}, paymentId=${payment.paymentId}');
    } else {
      // If bookingId exists, update the paymentId
      await db.update(
        'payments',
        {'paymentId': payment.paymentId},
        where: 'bookingId = ?',
        whereArgs: [payment.bookingId],
      );
      print(
          'Payment mis à jour : bookingId=${payment.bookingId}, paymentId=${payment.paymentId}');
    }
  }

  // Récupérer tous les paiements pour vérifier le stockage
  Future<List<PaymentMode>> getPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('payments');

    return List.generate(maps.length, (i) {
      return PaymentMode.fromMap(maps[i]);
    });
  }

  // Récupérer un paiement par bookingId
  Future<PaymentMode?> getPaymentById(int bookingId) async {
    final db = await database;

    // Query the payments table for the specified bookingId
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'bookingId = ?',
      whereArgs: [bookingId],
    );

    // Check if any payment was found
    if (maps.isNotEmpty) {
      // Return the first PaymentMode object found
      return PaymentMode.fromMap(maps.first);
    }

    // Return null if no payment was found
    return null;
  }
}
