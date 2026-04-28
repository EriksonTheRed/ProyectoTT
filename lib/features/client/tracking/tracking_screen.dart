import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/client_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class TrackingScreen extends StatefulWidget {
  final Usuario usuario;
  final Pedido pedido;

  const TrackingScreen({
    super.key,
    required this.usuario,
    required this.pedido,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final PedidoService _pedidoService = PedidoService();
  final UserService _userService = UserService();
  final ClientService _clientService = ClientService(PedidoService());

  Pedido? pedido;
  Usuario? repartidor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    try {
      final pedidos = await _clientService.getMyPedidos(widget.usuario.uid);

      Pedido? pedidoEncontrado;

      for (var p in pedidos) {
        if (p.estado == EstadoPedido.pendiente ||
            p.estado == EstadoPedido.proceso) {
          pedidoEncontrado = p;
          break;
        }
      }

      if (pedidoEncontrado != null) {
        pedido = pedidoEncontrado;

        if (pedido!.repartidorId != null) {
          repartidor = await _userService.getUserById(pedido!.repartidorId!);
        }
      } else {
        pedido = null;
      }
    } catch (e) {
      pedido = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedido == null
          ? const Center(child: Text("No hay pedido activo"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildDriverCard(),
                  const SizedBox(height: 20),
                  _buildDetailsCard(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Seguimiento de Pedido",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text("Pedido", style: TextStyle(color: Colors.white70)),
          Text(
            "#${pedido!.id}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// STATUS
  /// =========================
  Widget _buildStatusCard() {
    final estadoTexto = _estadoTexto(pedido!.estado);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              estadoTexto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// REPARTIDOR
  /// =========================
  Widget _buildDriverCard() {
    return _cardWrapper(
      child: repartidor == null
          ? const Text("Esperando asignación de repartidor")
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Repartidor",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(repartidor!.nombre),
                    const SizedBox(height: 4),
                    Text(
                      repartidor!.telefono,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // opcional: abrir marcador de llamada
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text("Llamar"),
                ),
              ],
            ),
    );
  }

  /// =========================
  /// DETALLES
  /// =========================
  Widget _buildDetailsCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detalles del pedido",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${pedido!.cantidad} Garrafones"),
              Text(
                "\$${pedido!.total.toStringAsFixed(0)} MXN",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            "Dirección de entrega",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),

          Text(
            pedido!.direccionEntrega,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// HELPERS
  /// =========================
  Widget _cardWrapper({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: child,
      ),
    );
  }

  String _estadoTexto(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return "Pendiente";
      case EstadoPedido.proceso:
        return "En camino";
      case EstadoPedido.completado:
        return "Entregado";
      case EstadoPedido.cancelado:
        return "Cancelado";
    }
  }
}
