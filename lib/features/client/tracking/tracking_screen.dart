import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class TrackingScreen extends StatefulWidget {
  final Usuario usuario;
  final Pedido pedido;
  final Function(int)? onNavigate;

  const TrackingScreen({
    super.key,
    required this.usuario,
    required this.pedido,
    this.onNavigate,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final UserService _userService = UserService();

  Usuario? repartidor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRepartidor();
  }

  Future<void> _loadRepartidor() async {
    try {
      if (widget.pedido.repartidorId != null) {
        repartidor = await _userService.getUserById(
          widget.pedido.repartidorId!,
        );
      }
    } catch (e) {
      debugPrint("Error cargando repartidor: $e");
    }

    if (!mounted) return;

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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 🔧 ajusta según tu navegación real
        onTap: (index) {
          widget.onNavigate?.call(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Pedido",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
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
            "#${widget.pedido.id}",
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
    final estadoTexto = _estadoTexto(widget.pedido.estado);

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
                  onPressed: () {},
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
              Text("${widget.pedido.cantidad} Garrafones"),
              Text(
                "\$${widget.pedido.total.toStringAsFixed(0)} MXN",
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
            widget.pedido.direccionEntrega,
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
