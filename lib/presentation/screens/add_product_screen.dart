import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/entities/categorie.dart';
import 'package:flutter_application_1/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/presentation/widgets/custom_bottom_navbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  bool _enOferta = false;
  String _categoriaSeleccionada = '';
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  Future<String> subirImagen(File imagen) async {
    final nombreArchivo = path.basename(imagen.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child('productos') 
        .child(nombreArchivo);

    await ref.putFile(imagen);

    return await ref.getDownloadURL();
  }

  Future<List<Categorie>> _fetchCategorias() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categorias').get();

    return snapshot.docs
        .map((doc) => Categorie(id: doc.id, nombre: doc.get('nombre') ?? ''))
        .toList();
  }

  Future<void> guardarProducto() async {
    try {
      if (_formKey.currentState!.validate()) {
        if (_categoriaSeleccionada.isEmpty) {
          throw Exception('Debe seleccionar una categoría');
        }

        if (_imagenSeleccionada == null) {
          throw Exception('Debe seleccionar una imagen');
        }

        _formKey.currentState!.save();

        final imagenUrl = await subirImagen(_imagenSeleccionada!);

        await FirebaseFirestore.instance.collection('productos').add({
          'nombre': _nombreController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'precio': double.parse(_precioController.text),
          'stock': int.parse(_stockController.text),
          'enOferta': _enOferta,
          'categoriaId': _categoriaSeleccionada,
          'imagenUrl': imagenUrl, 
        });

        print('Producto guardado exitosamente');

         _formKey.currentState!.reset();
        _nombreController.clear();
        _descripcionController.clear();
        _precioController.clear();
        _stockController.clear();
        setState(() {
          _categoriaSeleccionada = '';
          _enOferta = false;
          _imagenSeleccionada = null;
        });
      }
    } catch (e) {
      print('Error al guardar producto: $e');
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<List<Categorie>>(
                  future: _fetchCategorias(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay categorías disponibles'),
                      );
                    }
                    final categorias = snapshot.data!;

                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 30),

                          Text(
                            'Agregar Producto',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50),

                          TextFormField(
                            controller: _nombreController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              labelStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 75, 74, 74),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 20,
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Requerido'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descripcionController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              labelStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 75, 74, 74),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 20,
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Requerido'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _precioController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Precio',
                              labelStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 75, 74, 74),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 20,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Requerido';
                              if (double.tryParse(value) == null)
                                return 'Número inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _stockController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Stock inicial',
                              labelStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 75, 74, 74),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 20,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty){
                                return 'Requerido';}
                              if (int.tryParse(value) == null){
                                return 'Número inválido';}
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: const Color.fromARGB(
                                255,
                                75,
                                74,
                                74,
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Categoría',
                                labelStyle: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                filled: true,
                                fillColor: const Color.fromARGB(
                                  255,
                                  75,
                                  74,
                                  74,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                  horizontal: 20,
                                ),
                              ),
                              dropdownColor: const Color.fromARGB(
                                255,
                                75,
                                74,
                                74,
                              ),
                              items:
                                  categorias
                                      .map(
                                        (cat) => DropdownMenuItem<String>(
                                          value: cat.id,
                                          child: Text(
                                            cat.nombre,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              value:
                                  _categoriaSeleccionada.isNotEmpty
                                      ? _categoriaSeleccionada
                                      : null,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _categoriaSeleccionada = val;
                                  });
                                }
                              },
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Selecciona una categoría'
                                          : null,
                              iconEnabledColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Imagen del producto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _imagenSeleccionada != null
                                  ? Image.file(
                                    _imagenSeleccionada!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  )
                                  : const Text(
                                    'No hay imagen seleccionada',
                                    style: TextStyle(color: Colors.white),
                                  ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: seleccionarImagen,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Seleccionar imagen'),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),

                          SwitchListTile(
                            title: Text(
                              '¿Está en oferta?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.lightBlue[600],
                              ),
                            ),
                            value: _enOferta,
                            onChanged: (val) {
                              setState(() {
                                _enOferta = val;
                              });
                            },
                            activeColor: const Color(0xff07CAB3),
                            inactiveThumbColor: const Color.fromARGB(
                              255,
                              75,
                              74,
                              74,
                            ),
                            inactiveTrackColor: Colors.grey[300],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff07CAB3),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: guardarProducto,
              child: const Text('Guardar producto'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
