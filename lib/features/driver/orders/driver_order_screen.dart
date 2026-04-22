import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/delivery_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:intl/intl.dart';

class DriverOrderScreen extends StatefulWidget {
  final Pedido pedido;

  const DriverOrderScreen({super.key, required this.pedido});

  @override
  State<DriverOrderScreen> createState() => _DriverOrderScreenState();
}

class _DriverOrderScreenState extends State<DriverOrderScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  final UserService _userService = UserService();

  Usuario? cliente;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCliente();
  }

  Future<void> _loadCliente() async {
    cliente = await _userService.getUserById(widget.pedido.clienteId);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatus(pedido),
                  const SizedBox(height: 20),
                  _buildClientInfo(),
                  const SizedBox(height: 20),
                  _buildOrderDetails(pedido),
                  const SizedBox(height: 20),
                  _buildButtons(pedido),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  /// =========================
  /// STATUS
  /// =========================
  Widget _buildStatus(Pedido pedido) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            _estadoTexto(pedido.estado),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// =========================
  /// CLIENTE
  /// =========================
  Widget _buildClientInfo() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Información del Cliente",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Text(
            cliente?.nombre ?? "Cliente",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue),
              const SizedBox(width: 5),
              Text(cliente?.telefono ?? "-"),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 5),
              Expanded(child: Text(widget.pedido.direccionEntrega)),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// DETALLES
  /// =========================
  Widget _buildOrderDetails(Pedido pedido) {
    final fecha = pedido.fechaCreacion != null
        ? DateFormat('dd MMM yyyy').format(pedido.fechaCreacion!)
        : '';

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detalles del Pedido",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text("Fecha:"), Text(fecha)],
          ),

          const SizedBox(height: 5),

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
        ],
      ),
    );
  }

  /// =========================
  /// BOTONES
  /// =========================
  Widget _buildButtons(Pedido pedido) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _entregar(pedido.id),
            icon: const Icon(Icons.check),
            label: const Text("Marcar como Entregado"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _noEntregado(pedido.id),
            icon: const Icon(Icons.close),
            label: const Text("Marcar como No Entregado"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ACCIONES
  /// =========================
  Future<void> _entregar(String id) async {
    await _deliveryService.marcarComoEntregado(id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _noEntregado(String id) async {
    await _deliveryService.marcarNoEntregado(id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  String _estadoTexto(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return "Pendiente";
      case EstadoPedido.proceso:
        return "En reparto";
      case EstadoPedido.completado:
        return "Entregado";
      case EstadoPedido.cancelado:
        return "Cancelado";
    }
  }

  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
        "Pedido en Curso",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
