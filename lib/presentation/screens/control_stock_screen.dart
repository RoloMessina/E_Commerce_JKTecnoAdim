import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/entities/categorie.dart';
import 'package:flutter_application_1/presentation/providers/categories_provider.dart';
import 'package:flutter_application_1/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/presentation/widgets/custom_bottom_navbar.dart';

class ControlStockScreen extends ConsumerWidget {
  const ControlStockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriaProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Control de Stock",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: categorias.isEmpty
                ? const Center(
                    child: Text(
                    'No hay categorías.',
                    style: TextStyle(color: Colors.white),
                  ))
                : ListView.builder(
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return _CategorieItem(categorie: categoria);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

class _CategorieItem extends StatelessWidget {
  final Categorie categorie;

  const _CategorieItem({Key? key, required this.categorie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.category, color: Colors.white),
        title: Text(
          categorie.nombre,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          context.push('/stock-by-categorie/${categorie.id}');
        },
      ),
    );
  }
}