import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class DriverHomeScreen extends StatelessWidget {
  final Usuario usuario;

  const DriverHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("id_repartidor", isEqualTo: usuario.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!.docs;

          final activos = pedidos.where((p) =>
              p["estado"] == "pendiente" ||
              p["estado"] == "proceso").toList();

          final completadosHoy = pedidos.where((p) =>
              p["estado"] == "completado").length;

          final actual = activos.isNotEmpty ? activos.first : null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(usuario),

                const SizedBox(height: 20),

                _stats(activos.length, completadosHoy),

                const SizedBox(height: 20),

                _titulo("Pedido en curso"),

                _currentOrder(actual),

                const SizedBox(height: 20),

                _titulo("Accesos rápidos"),

                _quickAccess(),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// =========================
  /// HEADER
  /// =========================
  Widget _header(Usuario usuario) {
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
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hola ${usuario.nombre}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Listo para entregar pedidos",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// STATS
  /// =========================
  Widget _stats(int pendientes, int completados) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              "Pendientes",
              pendientes.toString(),
              Colors.blue,
              Icons.inventory_2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              "Entregados hoy",
              completados.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// TITULOS
  /// =========================
  Widget _titulo(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// =========================
  /// PEDIDO ACTUAL
  /// =========================
  Widget _currentOrder(dynamic pedido) {
    if (pedido == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No hay pedidos activos"),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// header card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cliente"),
                _estadoBadge(pedido["estado"]),
              ],
            ),

            const SizedBox(height: 10),

            Text(
  pedido["nombre_cliente"] ?? "Cliente",
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Garrafones:"),
                Text("${pedido["cantidad"]} unidades"),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:"),
                Text("\$${pedido["total"]} MXN"),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    pedido["direccion_entrega"] ?? "-",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Ver detalles"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoBadge(String estado) {
    Color color;

    switch (estado) {
      case "pendiente":
        color = Colors.orange;
        break;
      case "proceso":
        color = Colors.amber;
        break;
      case "completado":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(color: color),
      ),
    );
  }

  /// =========================
  /// ACCESOS RÁPIDOS
  /// =========================
  Widget _quickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: const [
            Icon(Icons.history, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(child: Text("Ver historial de entregas")),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}