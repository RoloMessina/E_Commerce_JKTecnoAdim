import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/entities/order.dart' as model;

// Acciones como actualizar estado
final ordersProvider = Provider((ref) => OrdersActions());

class OrdersActions {
  Future<void> actualizarEstadoPedido({
    required String pedidoId,
    required String nuevoEstado,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(pedidoId)
          .update({'status': nuevoEstado});
    } catch (e) {
      print('Error actualizando estado del pedido: $e');
      rethrow;
    }
  }
}

final ordersFutureProvider = FutureProvider<List<model.Order>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('orders').get();

  final pedidos = snapshot.docs
      .map((doc) => model.Order.fromFirestore(doc))
      .toList();

  pedidos.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));

  for (int i = 0; i < pedidos.length; i++) {
    pedidos[i] = model.Order(
      id: pedidos[i].id,
      direccion: pedidos[i].direccion,
      total: pedidos[i].total,
      estado: pedidos[i].estado,
      purchaseDate: pedidos[i].purchaseDate,
      numeroDisplay: (i + 1).toString(),
    );
  }

  return pedidos;
});

