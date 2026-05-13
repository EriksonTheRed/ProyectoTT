import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/client_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final Usuario usuario;

  const HistoryScreen({super.key, required this.usuario});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ClientService _clientService = ClientService(PedidoService());

  List<Pedido> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    try {
      print("UID: ${widget.usuario.uid}");

      final result = await _clientService.getMyPedidos(widget.usuario.uid);

      print("Pedidos obtenidos: ${result.length}");

      setState(() {
        pedidos = result;
        isLoading = false;
      });
    } catch (e, stack) {
      print("ERROR EN HISTORIAL: $e");
      print(stack);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightBackground,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

  /// =========================
  /// HEADER
  /// =========================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
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

  /// =========================
  /// STATS
  /// =========================
  Widget _buildStatsCard(List<Pedido> pedidos) {
    final total = pedidos.length;

    final entregados = pedidos
        .where((p) => p.estado == EstadoPedido.completado)
        .length;

    final cancelados = pedidos
        .where((p) => p.estado == EstadoPedido.cancelado)
        .length;

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

  /// =========================
  /// CARD PEDIDO
  /// =========================
  Widget _buildOrderCard(Pedido pedido) {
    final estadoTexto = _estadoTexto(pedido.estado);
    final statusColor = _estadoColor(pedido.estado);

    final fecha = pedido.fechaCreacion != null
        ? DateFormat('dd MMM yyyy').format(pedido.fechaCreacion!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pedido", style: TextStyle(color: Colors.grey)),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estadoTexto,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fecha,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// ID
            Text(
              pedido.id,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),

            /// DETALLE
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
                      const Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text("${pedido.cantidad} garrafón(es)"),
                    ],
                  ),
                  Text(
                    "\$${pedido.total.toStringAsFixed(0)} MXN",
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
      ),
    );
  }

  /// =========================
  /// HELPERS
  /// =========================
  String _estadoTexto(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.completado:
        return "Entregado";
      case EstadoPedido.cancelado:
        return "Cancelado";
      case EstadoPedido.proceso:
        return "En proceso";
      case EstadoPedido.pendiente:
        return "Pendiente";
    }
  }

  Color _estadoColor(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.completado:
        return Colors.green;
      case EstadoPedido.cancelado:
        return Colors.red;
      case EstadoPedido.proceso:
        return Colors.orange;
      case EstadoPedido.pendiente:
        return Colors.blue;
    }
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
