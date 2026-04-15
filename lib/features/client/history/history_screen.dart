import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

import '../../../core/navigation/client_navigation.dart';

class Pedido {
  final String id;
  final String status;
  final String date;
  final int quantity;
  final int total;

  Pedido({
    required this.id,
    required this.status,
    required this.date,
    required this.quantity,
    required this.total,
  });
}

class HistoryScreen extends StatelessWidget {
  final Usuario usuario;

  const HistoryScreen({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {

    final pedidos = [
      Pedido(
        id: "PED-1234",
        status: "Entregado",
        date: "24 Oct 2025",
        quantity: 3,
        total: 105,
      ),
      Pedido(
        id: "PED-1233",
        status: "Entregado",
        date: "20 Oct 2025",
        quantity: 2,
        total: 70,
      ),
      Pedido(
        id: "PED-1232",
        status: "Cancelado",
        date: "18 Oct 2025",
        quantity: 1,
        total: 35,
      ),
    ];

    return Container(
      color: AppTheme.lightBackground,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatsCard(pedidos),
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
      child: const Text(
        "Historial de Pedidos",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<Pedido> pedidos) {
    final total = pedidos.length;
    final entregados = pedidos.where((p) => p.status == "Entregado").length;
    final cancelados = pedidos.where((p) => p.status == "Cancelado").length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem("$total", "Total", Colors.blue),
            _StatItem("$entregados", "Entregados", Colors.green),
            _StatItem("$cancelados", "Cancelados", Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Pedido pedido) {
    Color statusColor =
        pedido.status == "Entregado" ? Colors.green : Colors.red;

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
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pedido", style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pedido.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      pedido.date,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            ),

            const SizedBox(height: 6),

            Text(
              pedido.id,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 6),
                      Text("${pedido.quantity} garrafón(es)"),
                    ],
                  ),
                  Text(
                    "\$${pedido.total} MXN",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}