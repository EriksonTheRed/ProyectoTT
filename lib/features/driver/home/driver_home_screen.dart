import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/delivery_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class DriverHomeScreen extends StatefulWidget {
  final Usuario usuario;

  const DriverHomeScreen({super.key, required this.usuario});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final PedidoService _pedidoService = PedidoService();
  final UserService _userService = UserService();
  final DeliveryService _deliveryService = DeliveryService(
    PedidoService(),
    UserService(),
  );

  Pedido? pedidoActual;
  Usuario? cliente;

  int pendientes = 0;
  int entregadosHoy = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      /// 🔹 Obtener pedidos asignados (en proceso)
      final asignados = await _deliveryService.getPedidosAsignados(
        widget.usuario.uid,
      );

      Pedido? pedidoTemp;
      Usuario? clienteTemp;

      if (asignados.isNotEmpty) {
        pedidoTemp = asignados.first;

        if (pedidoTemp.clienteId.isNotEmpty) {
          clienteTemp = await _userService.getUserById(pedidoTemp.clienteId);
        }
      }

      /// 🔹 Obtener TODOS los pedidos del repartidor
      final todos = await _pedidoService.getPedidosByRepartidor(
        widget.usuario.uid,
      );

      /// 🔹 Filtrar completados hoy
      final now = DateTime.now();
      final inicioDia = DateTime(now.year, now.month, now.day);

      final completadosHoy = todos.where((p) {
        return p.estado == EstadoPedido.completado &&
            p.fechaEntrega != null &&
            p.fechaEntrega!.isAfter(inicioDia);
      }).toList();

      setState(() {
        pedidoActual = pedidoTemp;
        cliente = clienteTemp;
        pendientes = asignados.length;
        entregadosHoy = completadosHoy.length;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR DRIVER HOME: $e");

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
                  _buildStats(),
                  const SizedBox(height: 20),
                  _buildCurrentOrder(),
                  const SizedBox(height: 20),
                  _buildQuickAccess(),
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
          Text(
            "Hola ${widget.usuario.nombre}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Listo para entregar pedidos",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// STATS
  /// =========================
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.inventory_2_outlined,
              title: "Pendientes",
              value: "$pendientes",
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              title: "Entregados\nhoy",
              value: "$entregadosHoy",
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// PEDIDO ACTUAL
  /// =========================
  Widget _buildCurrentOrder() {
    if (pedidoActual == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text("No hay pedidos en curso"),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pedido en curso",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 10),

          Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Cliente"),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "En proceso",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  cliente?.nombre ?? "Cliente",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Garrafones:"),
                    Text("${pedidoActual!.cantidad} unidades"),
                  ],
                ),

                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:"),
                    Text("\$${pedidoActual!.total.toStringAsFixed(0)} MXN"),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        pedidoActual!.direccionEntrega,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 👉 aquí luego conectamos pantalla de detalle
                    },
                    child: const Text("Ver detalles"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// QUICK ACCESS
  /// =========================
  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Accesos rápidos",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blue),
                    SizedBox(width: 10),
                    Text("Ver historial de entregas"),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

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
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
