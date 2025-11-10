import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../../core/routes/app_routes.dart';

class TiendaCompraInfoScreen extends StatefulWidget {
  const TiendaCompraInfoScreen({super.key});

  @override
  State<TiendaCompraInfoScreen> createState() => _TiendaCompraInfoScreenState();
}

class _TiendaCompraInfoScreenState extends State<TiendaCompraInfoScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _depto = TextEditingController();
  final _ciudad = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  String _pago = 'PSE';

  @override
  void dispose() {
    _nombre.dispose(); _depto.dispose(); _ciudad.dispose();
    _direccion.dispose(); _telefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final producto = ModalRoute.of(context)!.settings.arguments as Producto;

    return Scaffold(
      appBar: AppBar(title: const Text('Información de envío')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _form,
            child: Column(
              children: [
                _i(_nombre, 'Nombre'),
                _i(_depto, 'Departamento'),
                _i(_ciudad, 'Ciudad'),
                _i(_direccion, 'Dirección'),
                _i(_telefono, 'Teléfono', keyboard: TextInputType.phone),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Método de pago', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip('PSE'), _chip('Tarjeta'), _chip('Efectivo'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('\$ ${producto.precio ~/ 1000}.000',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              FilledButton(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  final data = {
                    'producto': producto,
                    'nombre': _nombre.text.trim(),
                    'cantidad': 1,
                    'metodoPago': _pago,
                    'fecha': DateTime.now(),
                    'referencia': 'REF${DateTime.now().millisecondsSinceEpoch % 100000}',
                  };
                  Navigator.pushNamed(context, AppRoutes.tiendaResultado, arguments: data);
                },
                child: const Text('Comprar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _i(TextEditingController c, String h, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: h, border: const OutlineInputBorder()),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
      ),
    );
  }

  Widget _chip(String value) {
    final selected = _pago == value;
    return ChoiceChip(
      label: Text(value),
      selected: selected,
      onSelected: (_) => setState(() => _pago = value),
    );
  }
}
