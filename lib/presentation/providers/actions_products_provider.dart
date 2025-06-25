import 'package:flutter_application_1/entities/categorie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ProductActionsNotifier extends StateNotifier<AsyncValue<void>> {
  ProductActionsNotifier() : super(const AsyncData(null));

  Future<void> agregarProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required bool enOferta,
    required String categoriaId,
    required File imagen,
  }) async {
    state = const AsyncLoading();
    try {
      final imagenUrl = await subirImagen(imagen);

      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': nombre.trim(),
        'descripcion': descripcion.trim(),
        'precio': precio,
        'stock': stock,
        'enOferta': enOferta,
        'categoriaId': categoriaId,
        'imagenUrl': imagenUrl,
      });

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<List<Categorie>> fetchCategorias() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categorias').get();
      return snapshot.docs
          .map((doc) => Categorie(id: doc.id, nombre: doc.get('nombre') ?? ''))
          .toList();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }


  Future<void> actualizarProducto({
    required String productoId,
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required bool enOferta,
    String? imagenExistente,
    File? nuevaImagen,
  }) async {
    state = const AsyncLoading();
    try {
      String imagenUrl = imagenExistente ?? '';
      if (nuevaImagen != null) {
        final nombreArchivo = path.basename(nuevaImagen.path);
        final ref =
            FirebaseStorage.instance.ref().child('productos/$nombreArchivo');
        await ref.putFile(nuevaImagen);
        imagenUrl = await ref.getDownloadURL();
      }

      final productoRef =
          FirebaseFirestore.instance.collection('productos').doc(productoId);

      await productoRef.update({
        'nombre': nombre.trim(),
        'descripcion': descripcion.trim(),
        'precio': precio,
        'stock': stock,
        'enOferta': enOferta,
        'imagenUrl': imagenUrl,
      });

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> eliminarProducto(String productoId) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection('productos')
          .doc(productoId)
          .delete();
      state = const AsyncData(null);
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




final productActionsProvider =
    StateNotifierProvider<ProductActionsNotifier, AsyncValue<void>>(
  (ref) => ProductActionsNotifier(),
);
