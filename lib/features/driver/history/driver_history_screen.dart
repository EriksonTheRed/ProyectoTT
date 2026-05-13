import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';



class DriverHistoryScreen extends StatelessWidget {
  final Usuario usuario;

  

  const DriverHistoryScreen({super.key, required this.usuario});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Column(
        children: [
          _header(),
          Expanded(child: _historial()),
        ],
      ),
    );
  }

  /// ================= HEADER =================
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Historial de Entregas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Pedidos entregados",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// ================= LISTA =================
  Widget _historial() {

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("orders")
        .where(
          "id_repartidor",
          isEqualTo: usuario.uid,
        )
        .snapshots(),

    builder: (context, snapshot) {

      /// ERROR
      if (snapshot.hasError) {
        return Center(
          child: Text("Error: ${snapshot.error}"),
        );
      }

      /// LOADING
      if (snapshot.connectionState ==
          ConnectionState.waiting) {

        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      /// DATA
      final docs = snapshot.data?.docs ?? [];

      /// SOLO COMPLETADOS Y CANCELADOS
      final filtrados = docs.where((doc) {

        final data =
            doc.data() as Map<String, dynamic>;

        final estado = data["estado"];

        return estado == "completado" ||
            estado == "cancelado";

      }).toList();

      /// ORDENAR LOCALMENTE
      filtrados.sort((a, b) {

        final aData =
            a.data() as Map<String, dynamic>;

        final bData =
            b.data() as Map<String, dynamic>;

        final aFecha =
            (aData["fecha_creacion"] as Timestamp)
                .toDate();

        final bFecha =
            (bData["fecha_creacion"] as Timestamp)
                .toDate();

        return bFecha.compareTo(aFecha);

      });

      if (filtrados.isEmpty) {

        return const Center(
          child: Text("Sin historial aún"),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: filtrados.length,

        itemBuilder: (context, index) {

          final data =
              filtrados[index].data()
                  as Map<String, dynamic>;

          return _card(data);
        },
      );
    },
  );
}

  /// ================= CARD =================
  Widget _card(Map<String, dynamic> pedido) {
  
  final cliente =
    pedido["nombre_cliente"] ?? "Cliente";

  final direccion =
      pedido["direccion_entrega"] ?? "-";

  final cantidad =
      pedido["cantidad"] ?? 0;

  final total =
      pedido["total"] ?? 0;

  final fecha =
      pedido["fecha_creacion"];

  final estado =
      pedido["estado"] ?? "";

  String fechaTexto = "";

  if (fecha != null) {

    final date =
        (fecha as Timestamp).toDate();

    fechaTexto =
        "${date.day}/${date.month}/${date.year}";
  }

  final esCancelado =
      estado == "cancelado";

  return Container(
    margin: const EdgeInsets.only(bottom: 15),

    padding: const EdgeInsets.all(15),

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(18),

      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
        )
      ],
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        /// HEADER
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: [

            Row(
              children: [

                Icon(
                  esCancelado
                      ? Icons.cancel
                      : Icons.check_circle,

                  color: esCancelado
                      ? Colors.red
                      : Colors.green,
                ),

                const SizedBox(width: 5),

                Text(
                  esCancelado
                      ? "Cancelado"
                      : "Entregado",

                  style: TextStyle(
                    color: esCancelado
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),

            Text(fechaTexto),
          ],
        ),

        const SizedBox(height: 10),

        Text(
  cliente,
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),

const SizedBox(height: 10),

        /// DETALLES
        Text(
          "Garrafones: $cantidad unidades",
        ),

        const SizedBox(height: 5),

        Text(
          "Total: \$${total} MXN",

          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [

            const Icon(
              Icons.location_on,
              color: Colors.red,
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Text(direccion),
            ),
          ],
        ),
      ],
    ),
  );
}
}