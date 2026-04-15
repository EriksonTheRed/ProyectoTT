import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../profile/driver_profile_screen.dart';

class Pedido {
  final String cliente;
  final String fecha;
  final int cantidad;
  final double total;
  final String direccion;

  Pedido({
    required this.cliente,
    required this.fecha,
    required this.cantidad,
    required this.total,
    required this.direccion,
  });
}

class DriverHistoryScreen extends StatelessWidget {
  final Repartidor repartidor;

  const DriverHistoryScreen({
    super.key,
    required this.repartidor,
  });

  @override
  Widget build(BuildContext context) {

    final pedidos = [
      Pedido(
        cliente: "Melisa Morales",
        fecha: "10 Nov 2025",
        cantidad: 4,
        total: 140,
        direccion: "Calle Principal 123, Col. Centro",
      ),
      Pedido(
        cliente: "Yazmin Azcona",
        fecha: "10 Nov 2025",
        cantidad: 6,
        total: 210,
        direccion: "Calle Juárez 789, Col. Sur",
      ),
      Pedido(
        cliente: "Laura Rodríguez",
        fecha: "9 Nov 2025",
        cantidad: 5,
        total: 175,
        direccion: "Av. Independencia 654, Col. Oeste",
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),

            ...pedidos.map((p) => _buildOrderCard(p)).toList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.darkBlue,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Historial de Entregas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Pedidos entregados",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Pedido pedido) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Entregado",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  pedido.fecha,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              pedido.cliente,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Garrafones:"),
                Text("${pedido.cantidad} unidades"),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:"),
                Text(
                  "\$${pedido.total} MXN",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on,
                    color: Colors.red, size: 16),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    pedido.direccion,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}