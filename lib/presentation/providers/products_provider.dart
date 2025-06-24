import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/entities/product.dart';

final productByCategoryProvider = AsyncNotifierProviderFamily<ProductsNotifier, List<Product>, String>(
  ProductsNotifier.new,
);

class ProductsNotifier extends FamilyAsyncNotifier<List<Product>, String> {
  late final String categoryId;

  @override
  Future<List<Product>> build(String categoryId) async {
    this.categoryId = categoryId; 
    final snapshot = await FirebaseFirestore.instance
        .collection('productos')
        .where('categoriaId', isEqualTo: categoryId)
        .get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  void actualizarProductoEnLista(Product productoActualizado) {
    final productosActuales = state.value;
    if (productosActuales == null) return;

    final index = productosActuales.indexWhere((p) => p.id == productoActualizado.id);
    if (index == -1) return;

    final listaActualizada = [...productosActuales];
    listaActualizada[index] = productoActualizado;

    state = AsyncData(listaActualizada);
  }

  Future<void> increaseStock(String productId) async {
    final currentProducts = state.value;
    if (currentProducts == null) return;
    final index = currentProducts.indexWhere((prod) => prod.id == productId);
    if (index == -1) return;
    final product = currentProducts[index];
    final newStock = product.stock + 1;

    await FirebaseFirestore.instance
        .collection('productos')
        .doc(product.id)
        .update({'stock': newStock});

    final updatedProduct = product.copyWith(stock: newStock);
    final updatedList = List<Product>.from(currentProducts);
    updatedList[index] = updatedProduct;
    state = AsyncData(updatedList);
  }

  Future<void> decreaseStock(String productId) async {
    final currentProducts = state.value;
    if (currentProducts == null) return;
    final index = currentProducts.indexWhere((prod) => prod.id == productId);
    if (index == -1) return;
    final product = currentProducts[index];
    if (product.stock == 0) return;
    final newStock = product.stock - 1;

    await FirebaseFirestore.instance
        .collection('productos')
        .doc(product.id)
        .update({'stock': newStock});

    final updatedProduct = product.copyWith(stock: newStock);
    final updatedList = List<Product>.from(currentProducts);
    updatedList[index] = updatedProduct;
    state = AsyncData(updatedList);
  }
}
