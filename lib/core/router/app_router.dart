import 'package:flutter_application_1/presentation/screens/add_product_screen.dart';
import 'package:flutter_application_1/presentation/screens/categories_screen.dart';
import 'package:flutter_application_1/presentation/screens/control_pedidos_screen.dart';
import 'package:flutter_application_1/presentation/screens/main_screen.dart';
import 'package:flutter_application_1/presentation/screens/control_stock_screen.dart';
import 'package:flutter_application_1/presentation/screens/admin_profile_screen.dart';
import 'package:flutter_application_1/presentation/screens/pedido_detail_screen.dart';
import 'package:flutter_application_1/presentation/screens/products_by_categorie.dart';
import 'package:flutter_application_1/presentation/screens/stock_by_categorie.dart';
import 'package:flutter_application_1/presentation/screens/update_product_screen.dart';

import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainScreen()),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/control-stock',
      builder: (context, state) => const ControlStockScreen(),
    ),
    GoRoute(
      path: '/stock-by-categorie/:categorieId',
      builder: (context, state) {
        final categorieId = state.pathParameters['categorieId']!;
        return StockByCategorieScreen(categoriaId: categorieId);
      },
    ),
    GoRoute(
      path: '/admin-profile',
      builder: (context, state) => const AdminProfileScreen(),
    ),
    GoRoute(
      path: '/control-pedidos',
      builder: (context, state) => ControlPedidosScreen(),
    ),
    GoRoute(
      path: '/pedido-detail',
      builder: (context, state) {
        final pedido = state.extra as Pedido;
        return PedidoDetailScreen(pedido: pedido);
      },
    ),
    GoRoute(
      path: '/categories/:id',
      builder: (context, state) {
        final categoriaId = state.pathParameters['id']!;
        return ProductsByCategorieScreen(categoriaId: categoriaId);
      },
    ),
    GoRoute(
      path: '/update-product',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return UpdateProductScreen(
          categoriaId: data['categoriaId'],
          productoId: data['productoId'],
          datosProducto: data['datosProducto'],
        );
      },
    ),
  ],
);
