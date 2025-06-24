import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/providers/admin_provider.dart';
import 'package:flutter_application_1/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/presentation/widgets/custom_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error al cargar estadísticas: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (stats) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Perfil del Administrador',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromARGB(255, 75, 74, 74),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Lionel Messi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildStatItem('Ventas totales del mes', '\$${stats.ventasMensuales}'),
              _buildStatItem('Productos activos', '${stats.productosActivos}'),
              _buildStatItem('Pedidos pendientes', '${stats.pedidosPendientes}'),
              _buildStatItem('Pedidos finalizados', '${stats.pedidosFinalizados}'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: GestureDetector(
                  onTap: () => context.go('/control-stock'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inventory_2, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Ir al Control de Stock',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 75, 74, 74),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
          Text(value, style: const TextStyle(color: Colors.tealAccent, fontSize: 18)),
        ],
      ),
    );
  }
}
