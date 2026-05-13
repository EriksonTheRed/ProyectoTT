import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:purificadora_app/env.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/admin_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminService _adminService =
      AdminService(PedidoService(), UserService());

  String filtro = "todos";
  String busqueda = "";
  /// =========================
/// OBTENER RUTA GOOGLE
/// =========================
Future<String?> obtenerRuta({
  required double originLat,
  required double originLng,
  required double destLat,
  required double destLng,
}) async {

  try {

    final dio = Dio();

    final response = await dio.get(
      "https://maps.googleapis.com/maps/api/directions/json",
      queryParameters: {
        "origin": "$originLat,$originLng",
        "destination": "$destLat,$destLng",
        "key": googleAPIkey,
      },
    );

    final routes = response.data["routes"];

    if (routes.isEmpty) {
      return null;
    }

    return routes[0]["overview_polyline"]["points"];

  } catch (e) {

    print("ERROR RUTA MANUAL:");

    print(e);

    return null;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Pedidos")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("orders").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data["id"] = doc.id;
            return Pedido.fromMap(data);
          }).toList();

          /// FILTROS
          final filtrados = pedidos.where((p) {
            final coincideFiltro =
                filtro == "todos" ? true : p.estado.name == filtro;

            return coincideFiltro;
          }).toList();

          return Column(
            children: [
              _busqueda(),
              _filtros(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: filtrados.map((p) => _cardPedido(p)).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// =========================
  /// ASIGNAR
  /// =========================
  Future<void> asignar(BuildContext context, String pedidoId) async {
    final repartidores =
        await UserService().getAvailableDeliveryUsers();

    if (repartidores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay repartidores disponibles")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(10),
          children: repartidores.map((r) {
            return ListTile(
              title: Text(r.nombre),
              leading: const Icon(Icons.delivery_dining),
              onTap: () async {
                Navigator.pop(context);

                final pedidoDoc = await FirebaseFirestore.instance
    .collection("orders")
    .doc(pedidoId)
    .get();

final pedidoData =
    pedidoDoc.data() as Map<String, dynamic>;

final GeoPoint ubicacion =
    pedidoData["ubicacion"];

final ruta = await obtenerRuta(
  originLat: 19.454738,
  originLng: -99.174483,
  destLat: ubicacion.latitude,
  destLng: ubicacion.longitude,
);

await FirebaseFirestore.instance
    .collection("orders")
    .doc(pedidoId)
    .update({

  "id_repartidor": r.uid,

  "nombre_repartidor": r.nombre,

  "estado": "proceso",

  "ruta_polyline": ruta,

  "orden_ruta": 0,

  "punto_anterior_lat": 19.454738,

  "punto_anterior_lng": -99.174483,
});

/// REPARTIDOR OCUPADO
await FirebaseFirestore.instance
    .collection("users")
    .doc(r.uid)
    .update({
  "disponible": false,
});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Asignado a ${r.nombre}")),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> entregar(String id) async {

  final pedidoDoc =
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(id)
          .get();

  final pedidoData =
      pedidoDoc.data() as Map<String, dynamic>;

  final repartidorId =
      pedidoData["id_repartidor"];

  /// COMPLETAR PEDIDO
  await FirebaseFirestore.instance
      .collection("orders")
      .doc(id)
      .update({
    "estado": "completado",
  });

  /// REVISAR SI QUEDAN ACTIVOS
  final restantes =
      await FirebaseFirestore.instance
          .collection("orders")
          .where(
            "id_repartidor",
            isEqualTo: repartidorId,
          )
          .where(
            "estado",
            whereIn: [
              "pendiente",
              "proceso",
            ],
          )
          .get();

  /// SI YA NO HAY
  if (restantes.docs.isEmpty) {

    await FirebaseFirestore.instance
        .collection("users")
        .doc(repartidorId)
        .update({
      "disponible": true,
    });
  }
}

  Future<void> cancelar(String id) async {

  final pedidoDoc =
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(id)
          .get();

  final pedidoData =
      pedidoDoc.data() as Map<String, dynamic>;

  final repartidorId =
      pedidoData["id_repartidor"];

  /// CANCELAR PEDIDO
  await FirebaseFirestore.instance
      .collection("orders")
      .doc(id)
      .update({
    "estado": "cancelado",
  });

  /// REVISAR SI QUEDAN ACTIVOS
  final restantes =
      await FirebaseFirestore.instance
          .collection("orders")
          .where(
            "id_repartidor",
            isEqualTo: repartidorId,
          )
          .where(
            "estado",
            whereIn: [
              "pendiente",
              "proceso",
            ],
          )
          .get();

  /// SI YA NO HAY
  if (restantes.docs.isEmpty) {

    await FirebaseFirestore.instance
        .collection("users")
        .doc(repartidorId)
        .update({
      "disponible": true,
    });
  }
}

  /// =========================
  /// UI
  /// =========================
  Widget _busqueda() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        onChanged: (v) => setState(() => busqueda = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Buscar",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _filtros() {
    return Wrap(
      spacing: 8,
      children: [
        _chip("todos"),
        _chip("pendiente"),
        _chip("proceso"),
        _chip("completado"),
        _chip("cancelado"),
      ],
    );
  }

  Widget _chip(String v) {
    return ChoiceChip(
      label: Text(v),
      selected: filtro == v,
      onSelected: (_) => setState(() => filtro = v),
    );
  }

  Widget _estadoBadge(EstadoPedido estado) {
    Color color;

    switch (estado) {
      case EstadoPedido.pendiente:
        color = Colors.orange;
        break;
      case EstadoPedido.proceso:
        color = Colors.amber;
        break;
      case EstadoPedido.completado:
        color = Colors.green;
        break;
      case EstadoPedido.cancelado:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.name,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _cardPedido(Pedido p) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#${p.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                _estadoBadge(p.estado),
              ],
            ),
            const SizedBox(height: 8),
            Text("Cliente: ${p.nombreCliente ?? "Cliente"}"),

Text("\$${p.total}"),

if (p.nombreRepartidor != null)
  Text(
    "Repartidor: ${p.nombreRepartidor}",
    style: const TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    ),
  ),

const SizedBox(height: 10),

            if (p.estado == EstadoPedido.pendiente)
              ElevatedButton(
                onPressed: () => asignar(context, p.id),
                child: const Text("Asignar Repartidor"),
              ),

            if (p.estado == EstadoPedido.proceso)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () => entregar(p.id),
                      child: const Text("Entregado"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () => cancelar(p.id),
                      child: const Text("Cancelar"),
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