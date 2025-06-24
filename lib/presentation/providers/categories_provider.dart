import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/entities/categorie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesNotifier extends StateNotifier<List<Categorie>> {
  CategoriesNotifier() : super([]) {
    _loadCategorias(); 
  }

  Future<void> _loadCategorias() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categorias').get();

    state = snapshot.docs
        .map((doc) => Categorie(id: doc.id, nombre: doc.get('nombre') ?? ''))
        .toList();
  }

  Future<void> crearCategoria(String nombre) async {
    try {
      final docRef =
          await FirebaseFirestore.instance.collection('categorias').add({
        'nombre': nombre,
      });

      final nuevaCategoria = Categorie(id: docRef.id, nombre: nombre);
      state = [...state, nuevaCategoria];
    } catch (e) {
      print('Error al crear categoría: $e');
      rethrow;
    }
  }

  String getNombrePorId(String id) {
    final cat = state.firstWhere(
      (c) => c.id == id,
      orElse: () => Categorie(id: id, nombre: 'Categoría'),
    );
    return cat.nombre;
  }
}

final categoriaProvider = StateNotifierProvider<CategoriesNotifier, List<Categorie>>(
  (ref) => CategoriesNotifier(),
);
