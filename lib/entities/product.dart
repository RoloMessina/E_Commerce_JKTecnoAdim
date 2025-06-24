class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final bool enOferta;
  final String imagenUrl;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.enOferta,
    required this.imagenUrl,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      enOferta: data['enOferta'] ?? false,
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'enOferta': enOferta,
      'imagenUrl': imagenUrl,
    };
  }

  Product copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    bool? enOferta,
    String? imagenUrl,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      enOferta: enOferta ?? this.enOferta,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}
