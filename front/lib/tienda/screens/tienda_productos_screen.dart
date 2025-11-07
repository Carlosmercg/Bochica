import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/producto.dart';
import '../../core/routes/app_routes.dart';
import '../services/products_repository.dart';

class TiendaProductosScreen extends StatelessWidget {
  const TiendaProductosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProductsRepository();
    final money = NumberFormat.currency(locale: 'es_CO', symbol: r'$');

    return Scaffold(
      appBar: AppBar(title: const Text('Productos Disponibles')),
      body: StreamBuilder<List<Producto>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(error: snap.error);
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const _EmptyView();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final p = items[i];
              return ListTile(
                leading: _Thumb(url: p.imagen),
                title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  p.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(money.format(p.precio)),
                onTap: () => Navigator.pushNamed(ctx, AppRoutes.tiendaDetalle, arguments: p),
              );
            },
          );
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  const _Thumb({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.devices_other));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url!, width: 48, height: 48, fit: BoxFit.cover),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No hay productos disponibles.'),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object? error;
  const _ErrorView({this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error cargando productos:\n$error',
        textAlign: TextAlign.center,
      ),
    );
  }
}
