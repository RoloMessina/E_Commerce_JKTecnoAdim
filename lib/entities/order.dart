import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String? numeroDisplay;
  final String direccion;
  final double total;
  final String estado;
  final DateTime purchaseDate;

  Order({
    required this.id,
    this.numeroDisplay,
    required this.direccion,
    required this.total,
    required this.estado,
    required this.purchaseDate,
  });

  static String mapEstado(dynamic raw) {
    if (raw == null) return 'Para preparar';
    final value = raw.toString().toLowerCase();
    if (value == 'pending' ||
        value == 'pendiente' ||
        value == 'para preparar') {
      return 'Para preparar';
    } else if (value == 'shipped' || value == 'enviado') {
      return 'Enviado';
    } else if (value == 'completed' || value == 'finalizado') {
      return 'Finalizado';
    } else {
      return 'Para preparar';
    }
  }

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final billingInfo = data['billingInfo'] as Map<String, dynamic>?;
    final items = data['items'] as List<dynamic>?;
    final timestamp = data['purchaseDate'] as Timestamp?;

    double calculatedTotal = 0.0;
    if (items != null) {
      for (var item in items) {
        if (item is Map<String, dynamic>) {
          final price = (item['price'] as num?)?.toDouble() ?? 0.0;
          final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
          calculatedTotal += price * quantity;
        }
      }
    }

    return Order(
      id: doc.id,
      direccion: billingInfo?['direccion'] ?? 'Dirección no disponible',
      total: calculatedTotal,
      estado: mapEstado(data['status']),
      purchaseDate: timestamp?.toDate() ?? DateTime.now(),
    );
  }
}