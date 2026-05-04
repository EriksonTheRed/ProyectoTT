import 'package:flutter/material.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminMonitorScreen extends StatefulWidget {
  const AdminMonitorScreen({super.key});

  @override
  State<AdminMonitorScreen> createState() => _AdminMonitorScreenState();
}

class _AdminMonitorScreenState extends State<AdminMonitorScreen> {
  final PedidoService _pedidoService = PedidoService();
  final UserService _userService = UserService();

  List<Usuario> repartidores = [];
  List<Pedido> pedidos = [];

  bool loading = true;

  int enRuta = 0;
  int activos = 0;
  int hoy = 0;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    final reps = await _userService.getDeliveryUsers();
    final peds = await _pedidoService.getPedidos();

    /// EN RUTA
    final enRutaCount =
        peds.where((p) => p.estado == EstadoPedido.proceso).length;

    /// ACTIVOS
    final activosCount = reps.where((r) => r.activo == true).length;

    /// HOY (solo completados)
    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);

    final hoyCount = peds.where((p) {
      return p.estado == EstadoPedido.completado &&
          p.fechaCreacion != null &&
          p.fechaCreacion!.isAfter(inicioDia);
    }).length;

    setState(() {
      repartidores = reps;
      pedidos = peds;
      enRuta = enRutaCount;
      activos = activosCount;
      hoy = hoyCount;
      loading = false;
    });
  }

  /// =========================
  /// TOGGLE ACTIVO
  /// =========================
  Future<void> toggleActivo(Usuario u) async {
    await _userService.updateUserActiveStatus(
      uid: u.uid,
      isActive: !(u.activo ?? false),
    );

    cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitoreo")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _stats(),
                const SizedBox(height: 10),
                ...repartidores.map((r) => _cardRepartidor(r)).toList(),
              ],
            ),
    );
  }

  /// =========================
  /// STATS
  /// =========================
  Widget _stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stat("En Ruta", enRuta, Colors.blue),
        _stat("Activos", activos, Colors.green),
        _stat("Hoy", hoy, Colors.orange),
      ],
    );
  }

  Widget _stat(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(title),
      ],
    );
  }

  /// =========================
  /// CARD REPARTIDOR
  /// =========================
  Widget _cardRepartidor(Usuario u) {
    final activo = u.activo ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  u.nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (activo ? Colors.green : Colors.grey)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activo ? "Activo" : "Inactivo",
                    style: TextStyle(
                      color: activo ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// BOTÓN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => toggleActivo(u),
                child: Text(activo ? "Desactivar" : "Activar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}