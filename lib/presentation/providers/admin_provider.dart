import 'package:flutter_application_1/entities/adminStats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) async {
  final firestore = FirebaseFirestore.instance;

  final productosSnap = await firestore.collection('productos').get();
  final productosCount = productosSnap.docs.length;

  final pendientesSnap = await firestore
      .collection('orders')
      .where('status', isNotEqualTo: 'completed')
      .get();
  final pendientesCount = pendientesSnap.docs.length;

  final completadosSnap = await firestore
      .collection('orders')
      .where('status', isEqualTo: 'completed')
      .get();
  final completadosCount = completadosSnap.docs.length;

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final ventasSnap = await firestore
      .collection('orders')
      .where('status', isEqualTo: 'completed')
      .where('purchaseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .get();

  int totalVentas = 0;
  for (var doc in ventasSnap.docs) {
    final data = doc.data();
    totalVentas += ((data['totalAmount'] ?? 0) as num).toInt();
  }

  return AdminStats(
    productosActivos: productosCount,
    pedidosPendientes: pendientesCount,
    pedidosFinalizados: completadosCount,
    ventasMensuales: totalVentas,
  );
});
