import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:purificadora_app/data/services/delivery_service.dart';
import 'package:intl/intl.dart';

class DriverHistoryScreen extends StatefulWidget {
  final Usuario usuario;

  const DriverHistoryScreen({super.key, required this.usuario});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  final PedidoService _pedidoService = PedidoService();
  final UserService _userService = UserService();
  final DeliveryService _deliveryService = DeliveryService(
    PedidoService(),
    UserService(),
  );

  List<Pedido> pedidos = [];
  Map<String, Usuario> clientes = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final result = await _deliveryService.getPedidosAsignados(
        widget.usuario.uid,
      );

      final Map<String, Usuario> clientesTemp = {};

      for (var pedido in result) {
        final clienteId = pedido.clienteId;

        if (!clientesTemp.containsKey(clienteId)) {
          final cliente = await _userService.getUserById(clienteId);
          if (cliente != null) {
            clientesTemp[clienteId] = cliente;
          }
        }
      }

      setState(() {
        pedidos = result;
        clientes = clientesTemp;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR DRIVER HISTORY: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedidos.isEmpty
          ? const Center(child: Text("No hay pedidos aún"))
          : SingleChildScrollView(
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
          Text("Pedidos entregados", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Pedido pedido) {
    final cliente = clientes[pedido.clienteId];

    final fecha = pedido.fechaEntrega != null
        ? DateFormat('dd MMM yyyy').format(pedido.fechaEntrega!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
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
                  fecha,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              cliente?.nombre ?? "Cliente",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  "\$${pedido.total.toStringAsFixed(0)} MXN",
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
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    pedido.direccionEntrega,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
