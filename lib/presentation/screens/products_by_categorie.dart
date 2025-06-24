import 'package:flutter/material.dart';
import 'package:flutter_application_1/entities/categorie.dart';
import 'package:flutter_application_1/entities/product.dart';
import 'package:flutter_application_1/presentation/providers/actions_products_provider.dart';
import 'package:flutter_application_1/presentation/providers/categories_provider.dart';
import 'package:flutter_application_1/presentation/providers/products_provider.dart';
import 'package:flutter_application_1/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/presentation/widgets/custom_bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductsByCategorieScreen extends ConsumerWidget {
  final String categoriaId;

  const ProductsByCategorieScreen({super.key, required this.categoriaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productByCategoryProvider(categoriaId));
    final categorias = ref.watch(categoriaProvider);

    final nombreCategoria = categorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categorie(id: 'none', nombre: 'Categoría'),
    ).nombre;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Productos",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nombreCategoria,
            style: const TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: productosAsync.when(
              data: (productos) {
                if (productos.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay productos en esta categoría',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return _ProductCard(
                      producto: producto,
                      categoriaId: categoriaId,
                      onProductoEliminado: () {
                        ref.invalidate(productByCategoryProvider(categoriaId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto eliminado'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product producto;
  final String categoriaId;
  final VoidCallback onProductoEliminado;

  const _ProductCard({
    super.key,
    required this.producto,
    required this.categoriaId,
    required this.onProductoEliminado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(productActionsProvider.notifier);

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.network(
              producto.imagenUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${producto.precio}',
                    style: const TextStyle(color: Colors.tealAccent),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.teal),
              onPressed: () {
                context.push('/update-product', extra: {
                  'categoriaId': categoriaId,
                  'productoId': producto.id,
                  'datosProducto': {
                    'nombre': producto.nombre,
                    'descripcion': producto.descripcion,
                    'precio': producto.precio,
                    'stock': producto.stock,
                    'imagenUrl': producto.imagenUrl,
                    'enOferta': producto.enOferta,
                  },
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirmacion = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: const Text(
                      'Confirmar eliminación',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      '¿Estás seguro de eliminar este producto?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );

                if (confirmacion == true) {
                  await actions.eliminarProducto(producto.id);
                  onProductoEliminado();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
