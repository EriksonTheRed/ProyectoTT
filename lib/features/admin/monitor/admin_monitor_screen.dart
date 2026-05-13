import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminMonitorScreen extends StatelessWidget {
  const AdminMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitoreo")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("rol", isEqualTo: "repartidor")
            .snapshots(),
        builder: (context, usersSnap) {
          if (!usersSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .snapshots(),
            builder: (context, ordersSnap) {
              if (!ordersSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              /// 🔥 USUARIOS
              final repartidores = usersSnap.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data["uid"] = doc.id;
                return Usuario.fromMap(data);
              }).toList();

              /// 🔥 PEDIDOS
              final pedidos = ordersSnap.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data["id"] = doc.id;
                return Pedido.fromMap(data);
              }).toList();

              /// =========================
              /// 🔥 STATS DINÁMICOS
              /// =========================

              /// En ruta
              final enRuta = pedidos
                  .where((p) => p.estado == EstadoPedido.proceso)
                  .length;

              /// Activos
              final activos = repartidores
                  .where((r) => r.activo == true)
                  .length;

              /// Hoy
              final now = DateTime.now();
              final inicioDia =
                  DateTime(now.year, now.month, now.day);

              final hoy = pedidos.where((p) {
                return p.estado == EstadoPedido.completado &&
                    p.fechaCreacion != null &&
                    p.fechaCreacion!.isAfter(inicioDia);
              }).length;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _stats(enRuta, activos, hoy),
                  const SizedBox(height: 10),

                  /// 🔥 LISTA REPARTIDORES
                  ...repartidores
                      .map((r) => _cardRepartidor(r))
                      .toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// =========================
  /// STATS
  /// =========================
  Widget _stats(int enRuta, int activos, int hoy) {
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
                onPressed: () async {
                  await UserService().updateUserActiveStatus(
                    uid: u.uid,
                    isActive: !activo,
                  );
                },
                child: Text(activo ? "Desactivar" : "Activar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}