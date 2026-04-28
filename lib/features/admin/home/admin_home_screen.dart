import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/admin_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService(
    PedidoService(),
    UserService(),
  );

  int clientes = 0;
  int repartidores = 0;
  int pedidosHoy = 0;
  double ventas = 0;

  List<Pedido> pedidosActivos = [];
  Map<String, Usuario> usuarios = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final resumen = await _adminService.getResumenAdmin();
      final pedidos = await _adminService.getPedidosActivos();

      /// Obtener usuarios relacionados
      for (var p in pedidos) {
        if (!usuarios.containsKey(p.clienteId)) {
          final user = await _adminService.getUsuarioById(p.clienteId);
          if (user != null) usuarios[p.clienteId] = user;
        }

        if (p.repartidorId != null && !usuarios.containsKey(p.repartidorId)) {
          final user = await _adminService.getUsuarioById(p.repartidorId!);
          if (user != null) usuarios[p.repartidorId!] = user;
        }
      }

      setState(() {
        clientes = resumen['clientes'] ?? 0;
        repartidores = resumen['repartidores'] ?? 0;
        pedidosHoy = resumen['pedidosHoy'] ?? 0;
        ventas = resumen['ventas'] ?? 0;
        pedidosActivos = pedidos;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error admin: $e");
      setState(() => isLoading = false);
    }
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
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildPerformance(),
                  const SizedBox(height: 20),
                  _buildActiveOrders(),
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
  Widget _buildStatsGrid() {
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
  /// PERFORMANCE
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
  Widget _buildActiveOrders() {
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

        ...pedidosActivos.map((p) => _orderCard(p)).toList(),
      ],
    );
  }

  Widget _orderCard(Pedido pedido) {
    final cliente = usuarios[pedido.clienteId];
    final repartidor = pedido.repartidorId != null
        ? usuarios[pedido.repartidorId!]
        : null;

    Color color = pedido.estado == EstadoPedido.proceso
        ? Colors.orange
        : Colors.blue;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#${pedido.id}", style: const TextStyle(color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(pedido.estado.name, style: TextStyle(color: color)),
              ),
            ],
          ),
          const SizedBox(height: 5),

          Text(
            cliente?.nombre ?? "Cliente",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text("Repartidor: ${repartidor?.nombre ?? "Sin asignar"}"),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

/// =========================
/// STAT CARD
/// =========================
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
