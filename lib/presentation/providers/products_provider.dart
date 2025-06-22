import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/entities/product.dart';

// Provider que recibe el ID de la categoría y devuelve la lista de productos filtrados.
final productByCategoryProvider = AsyncNotifierProviderFamily<ProductsNotifier, List<Product>, String>(ProductsNotifier.new);

class ProductsNotifier extends FamilyAsyncNotifier<List<Product>, String> {
  late final String categoryId;

  @override
  Future<List<Product>> build(String categoryId) async {
    this.categoryId = categoryId;
    final snapshot = await FirebaseFirestore.instance
        .collection('productos') // Aquí usamos "productos" en lugar de "products"
        .where('categoriaId', isEqualTo: categoryId) // Filtra por el campo "categoriaId"
        .get();
    final products = snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    return products;
  }

  Future<void> increaseStock(String productId) async {
    final currentProducts = state.value;
    if (currentProducts == null) return;
    final index = currentProducts.indexWhere((prod) => prod.id == productId);
    if (index == -1) return;
    final product = currentProducts[index];
    final newStock = product.stock + 1;

    // Actualiza Firestore en la colección "productos"
    await FirebaseFirestore.instance
        .collection('productos')
        .doc(product.id)
        .update({'stock': newStock});

    // Actualiza el estado local
    final updatedProduct = Product(
      id: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      stock: newStock,
      enOferta: product.enOferta,
      imagenUrl: product.imagenUrl,
    );
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
    if (product.stock == 0) return; // Evita stock negativo
    final newStock = product.stock - 1;

    // Actualiza Firestore
    await FirebaseFirestore.instance
        .collection('productos')
        .doc(product.id)
        .update({'stock': newStock});

    // Actualiza el estado local
    final updatedProduct = Product(
      id: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      stock: newStock,
      enOferta: product.enOferta,
      imagenUrl: product.imagenUrl,
    );
    final updatedList = List<Product>.from(currentProducts);
    updatedList[index] = updatedProduct;
    state = AsyncData(updatedList);
  }
}