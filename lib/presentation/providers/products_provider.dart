import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/entities/product.dart';

final productByCategoryProvider =
    AsyncNotifierProviderFamily<ProductsNotifier, List<Product>, String>(
  ProductsNotifier.new,
);

class ProductsNotifier extends FamilyAsyncNotifier<List<Product>, String> {

  @override
  Future<List<Product>> build(String categoryId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('productos')
        .where('categoriaId',
            isEqualTo:
                categoryId) 
        .get();
    return snapshot.docs
        .map((doc) =>
            Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  void agregarProductoALaLista(Product nuevoProducto) {
    final productosActuales = state.value;
    if (productosActuales == null) return;

    final listaActualizada = List<Product>.from(productosActuales);
    listaActualizada.add(nuevoProducto);

    state = AsyncData(
        listaActualizada); 
  }

  void actualizarProductoEnLista(Product productoActualizado) {
    final productosActuales = state.value;
    if (productosActuales == null) return;

    final index =
        productosActuales.indexWhere((p) => p.id == productoActualizado.id);
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

  Future<void> agregarProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required bool enOferta,
    required String
        categoriaId, 
    required File imagen,
  }) async {
    state = const AsyncLoading();
    try {
      final imagenUrl = await subirImagen(imagen);

      final docRef =
          await FirebaseFirestore.instance.collection('productos').add({
        'nombre': nombre.trim(),
        'descripcion': descripcion.trim(),
        'precio': precio,
        'stock': stock,
        'enOferta': enOferta,
        'categoriaId': categoriaId, 
        'imagenUrl': imagenUrl,
      });

      final nuevoProducto = Product(
        id: docRef.id, 
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        stock: stock,
        enOferta: enOferta,
        categoriaId: categoriaId, 
        imagenUrl: imagenUrl,
      );

      agregarProductoALaLista(nuevoProducto);

      state = AsyncData([]);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<String> subirImagen(File imagen) async {
    final nombreArchivo = path.basename(imagen.path);
    final storageRef =
        FirebaseStorage.instance.ref().child('productos/$nombreArchivo');
    await storageRef.putFile(imagen);
    return await storageRef.getDownloadURL();
  }
}
