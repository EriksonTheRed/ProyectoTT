import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/client_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';

class Producto {
  final String nombre;
  final String descripcion;
  final double precio;

  Producto({
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });
}

class OrderScreen extends StatefulWidget {
  final Usuario usuario;

  const OrderScreen({super.key, required this.usuario});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int quantity = 1;
  bool isLoading = false;

  final ClientService _clientService = ClientService(PedidoService());

  final producto = Producto(
    nombre: "Garrafón de Agua",
    descripcion: "19 litros de agua purificada",
    precio: 35,
  );

  @override
  Widget build(BuildContext context) {
    double total = quantity * producto.precio;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text("Hacer Pedido"),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _productCard(),
            const SizedBox(height: 20),
            _addressCard(),
            const SizedBox(height: 20),
            _summaryCard(total),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _confirmButton(total),
      ),
    );
  }

  /// =========================
  /// PRODUCTO
  /// =========================
  Widget _productCard() {
    return _cardContainer(
      Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      producto.descripcion,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$${producto.precio} MXN",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// CANTIDAD
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text("Cantidad de garrafones"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(
                      icon: Icons.remove,
                      onTap: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                      filled: false,
                    ),
                    const SizedBox(width: 25),
                    Text(
                      "$quantity",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 25),
                    _circleButton(
                      icon: Icons.add,
                      onTap: () {
                        if (quantity < 5) {
                          setState(() => quantity++);
                        }
                      },
                      filled: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// DIRECCIÓN
  /// =========================
  Widget _addressCard() {
    return _cardContainer(
      Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dirección de entrega",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.usuario.direccion ?? "Sin dirección",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// RESUMEN
  /// =========================
  Widget _summaryCard(double total) {
    return _cardContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen del pedido",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Garrafones"),
              Text("\$${(quantity * producto.precio).toStringAsFixed(0)} MXN"),
            ],
          ),

          const SizedBox(height: 5),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Envío"),
              Text("Gratis", style: TextStyle(color: Colors.green)),
            ],
          ),

          const Divider(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${total.toStringAsFixed(0)} MXN",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// CONFIRMAR PEDIDO
  /// =========================
  Widget _confirmButton(double total) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: AppTheme.primaryBlue,
        ),
        onPressed: isLoading ? null : () => _crearPedido(total),
        // ✅ Icono oculto durante carga para que el label centrado se vea bien
        icon: isLoading
            ? const SizedBox.shrink()
            : const Icon(Icons.water_drop),
        label: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("Confirmar Pedido"),
      ),
    );
  }

  /// =========================
  /// CREAR PEDIDO
  /// =========================
  Future<void> _crearPedido(double total) async {
    final direccion = widget.usuario.direccion;

    if (direccion == null || direccion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agrega una dirección primero")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _clientService.crearPedido(
        clienteId: widget.usuario.uid,
        direccionEntrega: direccion,
        telefono: widget.usuario.telefono,
        cantidad: quantity,
        total: total,
        ubicacion: const GeoPoint(0, 0),
      );

      // ✅ Verificar mounted antes de usar context tras await
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido creado correctamente")),
      );
    } catch (e) {
      if (!mounted) return;

      // ✅ Nunca mostrar e.toString() — mensaje genérico amigable
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ocurrió un error al crear el pedido. Intenta de nuevo.",
          ),
        ),
      );
    } finally {
      // ✅ finally garantiza que isLoading se resetea siempre
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// =========================
  /// UI HELPERS
  /// =========================
  Widget _cardContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: filled ? AppTheme.primaryBlue : Colors.transparent,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppTheme.primaryBlue),
        ),
        child: Icon(icon, color: filled ? Colors.white : AppTheme.primaryBlue),
      ),
    );
  }
}
