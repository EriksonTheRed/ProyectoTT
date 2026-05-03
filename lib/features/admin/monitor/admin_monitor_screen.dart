import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/admin_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminMonitorScreen extends StatefulWidget {
  const AdminMonitorScreen({super.key});

  @override
  State<AdminMonitorScreen> createState() => _AdminMonitorScreenState();
}

class _AdminMonitorScreenState extends State<AdminMonitorScreen> {
  final AdminService _adminService = AdminService(
    PedidoService(),
    UserService(),
  );

  List<Usuario> repartidores = [];
  List<Pedido> pedidos = [];
  Map<String, Usuario> clientes = {};

  bool isLoading = true;

  int enRuta = 0;
  int activos = 0;
  int entregasHoy = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final reps = await _adminService.getRepartidores();
      final orders = await _adminService.getPedidosActivos();
      final resumen = await _adminService.getResumenAdmin();

      final Map<String, Usuario> clientesTemp = {};

      print("REPARTIDORES: ${reps.length}");

      for (var r in reps) {
        print("→ ${r.nombre} | rol: ${r.rol} | disponible: ${r.disponible}");
      }

      for (var p in orders) {
        final id = p.clienteId;

        if (!clientesTemp.containsKey(id)) {
          final c = await _adminService.getUsuarioById(id);
          if (c != null) clientesTemp[id] = c;
        }
      }

      final enRutaCount = orders
          .where((p) => p.estado == EstadoPedido.proceso)
          .length;

      final activosCount = reps.where((r) => r.disponible == true).length;

      if (!mounted) return;

      setState(() {
        repartidores = reps;
        pedidos = orders;
        clientes = clientesTemp;

        enRuta = enRutaCount;
        activos = activosCount;
        entregasHoy = resumen['pedidosHoy'] ?? 0;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Monitor error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSystemStatus(),
                const SizedBox(height: 15),
                _buildStats(),
                const SizedBox(height: 20),
                _buildDriversList(),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  /// HEADER
  Widget _buildHeader() {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: top + 20, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monitoreo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Estado actual de repartidores",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// SISTEMA
  Widget _buildSystemStatus() {
    final now = TimeOfDay.now();

    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 10),
              SizedBox(width: 8),
              Text("Sistema activo"),
            ],
          ),
          Text("${now.hour}:${now.minute.toString().padLeft(2, '0')}"),
        ],
      ),
    );
  }

  /// STATS
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              "$enRuta",
              "En Ruta",
              Icons.local_shipping,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              "$activos",
              "Activos",
              Icons.inventory,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              "$entregasHoy",
              "Hoy",
              Icons.check_circle,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// LISTA
  Widget _buildDriversList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Estado de Repartidores",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: repartidores.length,
          itemBuilder: (context, index) {
            return _driverCard(repartidores[index]);
          },
        ),
      ],
    );
  }

  /// CARD
  Widget _driverCard(Usuario r) {
    Pedido? pedido;

    try {
      pedido = pedidos.firstWhere(
        (p) => p.repartidorId == r.uid && p.estado == EstadoPedido.proceso,
      );
    } catch (_) {
      pedido = null;
    }

    final cliente = pedido != null ? clientes[pedido.clienteId] : null;

    String estado;
    Color color;

    if (pedido != null) {
      estado = "En ruta";
      color = Colors.orange;
    } else if (r.disponible == true) {
      estado = "Disponible";
      color = Colors.green;
    } else {
      estado = "Inactivo";
      color = Colors.grey;
    }

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryBlue,
                child: Text(r.nombre[0]),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Repartidor",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(estado, style: TextStyle(color: color)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (pedido != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pedido Actual:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text("#${pedido.id} - ${cliente?.nombre ?? ''}"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.red),
                const SizedBox(width: 5),
                Expanded(child: Text(pedido.direccionEntrega)),
              ],
            ),
          ] else
            const Text(
              "Sin pedido asignado",
              style: TextStyle(color: Colors.grey),
            ),
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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
