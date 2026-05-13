import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/pedido.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppTheme.lightBackground,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            /// convertir a modelo
            final pedidos = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data["id"] = doc.id;
              return Pedido.fromMap(data);
            }).toList();

            /// =========================
            /// STATS EN TIEMPO REAL
            /// =========================
            final clientes = pedidos.map((p) => p.clienteId).toSet().length;

            final repartidores = pedidos
                .where((p) => p.repartidorId != null)
                .map((p) => p.repartidorId)
                .toSet()
                .length;

            final pedidosHoy = pedidos.where((p) {
              if (p.fechaCreacion == null) return false;
              final now = DateTime.now();
              final inicio = DateTime(now.year, now.month, now.day);
              return p.fechaCreacion!.isAfter(inicio);
            }).length;

            final ventas = pedidos
                .where((p) => p.estado == EstadoPedido.completado)
                .fold<double>(0, (sum, p) => sum + p.total);

            final pedidosActivos = pedidos.where((p) =>
                p.estado == EstadoPedido.pendiente ||
                p.estado == EstadoPedido.proceso);

            return ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  /// STATS
                  _buildStatsGrid(
                    clientes,
                    repartidores,
                    pedidosHoy,
                    ventas,
                  ),

                  const SizedBox(height: 20),

                  _buildPerformance(),

                  const SizedBox(height: 20),

                  /// PEDIDOS ACTIVOS
                  _buildActiveOrders(pedidosActivos.toList()),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// =========================
  /// HEADER
  /// =========================
  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: top + 20,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Panel de Control",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Bienvenido Administrador",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// STATS
  /// =========================
  Widget _buildStatsGrid(
    int clientes,
    int repartidores,
    int pedidosHoy,
    double ventas,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.5,
        children: [
          _StatCard("Clientes", "$clientes", Icons.people, Colors.blue),
          _StatCard(
            "Repartidores",
            "$repartidores",
            Icons.local_shipping,
            Colors.green,
          ),
          _StatCard(
            "Pedidos Hoy",
            "$pedidosHoy",
            Icons.inventory,
            Colors.orange,
          ),
          _StatCard(
            "Ventas",
            "\$${ventas.toStringAsFixed(0)}",
            Icons.attach_money,
            Colors.black,
          ),
        ],
      ),
    );
  }

  /// =========================
  Widget _buildPerformance() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rendimiento",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.9,
            color: Colors.blue,
            backgroundColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  /// =========================
  /// PEDIDOS ACTIVOS
  /// =========================
  Widget _buildActiveOrders(List<Pedido> pedidos) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Pedidos Activos",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...pedidos.map((p) => _orderCard(p)).toList(),
      ],
    );
  }

  Widget _orderCard(Pedido pedido) {
    final color = pedido.estado == EstadoPedido.proceso
        ? Colors.orange
        : Colors.blue;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#${pedido.id}",
                  style: const TextStyle(color: Colors.grey)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pedido.estado.name,
                  style: TextStyle(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Cliente: ${pedido.nombreCliente}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "Repartidor: ${pedido.nombreRepartidor ?? "Sin asignar"}",
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}