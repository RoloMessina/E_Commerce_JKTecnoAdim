import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/providers/orders_provider.dart';
import 'package:flutter_application_1/presentation/widgets/custom_bottom_navbar.dart';
import 'package:flutter_application_1/presentation/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/entities/order.dart' as model;

class PedidoDetailScreen extends ConsumerStatefulWidget {
  final model.Order order;

  const PedidoDetailScreen({super.key, required this.order});

  @override
  ConsumerState<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends ConsumerState<PedidoDetailScreen> {
  final List<String> estados = ['Para preparar', 'Enviado', 'Finalizado'];
  late String selectedEstado;

  @override
  void initState() {
    super.initState();
    selectedEstado = widget.order.estado;
  }

  String estadoFirestore(String estado) {
    switch (estado) {
      case 'Para preparar':
        return 'pending';
      case 'Enviado':
        return 'shipped';
      case 'Finalizado':
        return 'completed';
      default:
        return 'pending';
    }
  }

  Future<void> _updateOrderStatus(WidgetRef ref) async {
    try {
      final orders = ref.read(ordersProvider);
      await orders.actualizarEstadoPedido(
        pedidoId: widget.order.id,
        nuevoEstado: estadoFirestore(selectedEstado),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado del pedido actualizado correctamente!'),
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Detalle del Pedido ${widget.order.numeroDisplay}'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido ${widget.order.numeroDisplay}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dirección: ${widget.order.direccion}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: \$${widget.order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estado actual: ${widget.order.estado}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      'Cambiar estado:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    dropdownColor: Colors.grey[800],
                    value: selectedEstado,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (newValue) {
                      setState(() {
                        selectedEstado = newValue!;
                      });
                    },
                    items: estados.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(
                          child: Text(value, style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _updateOrderStatus(ref);
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'Establecer estado del pedido',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
