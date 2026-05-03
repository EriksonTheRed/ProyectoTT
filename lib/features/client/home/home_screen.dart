import 'package:flutter/material.dart';
import 'package:purificadora_app/features/client/tracking/tracking_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/client_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int, {Pedido? pedido})? onNavigate; // ✅ FIX
  final Usuario usuario;

  const HomeScreen({super.key, this.onNavigate, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ClientService _clientService;

  Pedido? pedidoActual;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _clientService = ClientService(PedidoService());
    _loadPedidoActual();
  }

  /// =========================
  /// LOAD PEDIDO ACTUAL
  /// =========================
  Future<void> _loadPedidoActual() async {
    try {
      final pedidos = await _clientService.getMyPedidos(widget.usuario.uid);

      // 🔍 DEBUG AQUÍ
      print("TOTAL PEDIDOS: ${pedidos.length}");

      for (var p in pedidos) {
        print("Pedido: ${p.id}");
        print("Estado: ${p.estado}");
        print("Tipo estado: ${p.estado.runtimeType}");
        print("--------------------");
      }

      final activos = pedidos.where(
        (p) =>
            p.estado == EstadoPedido.pendiente ||
            p.estado == EstadoPedido.proceso,
      );

      print("PEDIDOS ACTIVOS: ${activos.length}");

      pedidoActual = activos.isNotEmpty ? activos.first : null;
    } catch (e) {
      debugPrint("Error cargando pedido: $e");
      pedidoActual = null;
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  /// =========================
  /// NAVIGAR A TRACKING
  /// =========================
  /// 🔥 NAVEGACIÓN CORRECTA
  void navegarTracking() {
    if (isLoading) return;

    if (pedidoActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No tienes ningún pedido activo en este momento."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onNavigate?.call(
      0, // 👈 índice irrelevante ahora
      pedido: pedidoActual,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    return Container(
      color: AppTheme.lightBackground,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(usuario),
            const SizedBox(height: 20),
            _buildActionCards(),
            const SizedBox(height: 20),
            _buildCurrentOrderCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// HEADER
  /// =========================
  Widget _buildHeader(Usuario usuario) {
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
            "Purificadora",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            "Hola,\n${usuario.nombre}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "¿Qué deseas hacer hoy?",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ACTION CARDS
  /// =========================
  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _ActionCard(
            icon: Icons.shopping_cart_outlined,
            title: "Hacer Pedido",
            subtitle: "Solicita tus garrafones",
            color: Colors.blue,
            onTap: () => widget.onNavigate?.call(1),
          ),
          const SizedBox(height: 15),
          _ActionCard(
            icon: Icons.water_drop_outlined,
            title: "Seguimiento",
            subtitle: "Rastrea tu pedido actual",
            color: Colors.teal,
            onTap: navegarTracking,
          ),
          const SizedBox(height: 15),
          _ActionCard(
            icon: Icons.access_time,
            title: "Historial",
            subtitle: "Ver pedidos anteriores",
            color: Colors.blueAccent,
            onTap: () => widget.onNavigate?.call(2),
          ),
          const SizedBox(height: 15),
          _ActionCard(
            icon: Icons.person_outline,
            title: "Mi Perfil",
            subtitle: "Editar información",
            color: Colors.blue,
            onTap: () => widget.onNavigate?.call(3),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// PEDIDO ACTUAL
  /// =========================
  Widget _buildCurrentOrderCard() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    if (pedidoActual == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F2FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pedido actual",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              "Estado: ${pedidoActual!.estado.name}",
              style: const TextStyle(color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: navegarTracking,
              child: const Text(
                "Ver seguimiento →",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================
/// ACTION CARD
/// =========================
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
