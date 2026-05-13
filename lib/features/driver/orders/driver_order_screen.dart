import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:intl/intl.dart';

class DriverOrderScreen extends StatelessWidget {
  final Usuario usuario;

  const DriverOrderScreen({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,

      body: StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore.instance
                .collection("orders")
                .where(
                  "id_repartidor",
                  isEqualTo: usuario.uid,
                )
                .where(
                  "estado",
                  whereIn: [
                    "pendiente",
                    "proceso",
                  ],
                )
                .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final pedidos =
              snapshot.data!.docs.map((doc) {

            final data =
                doc.data()
                    as Map<String, dynamic>;

            data["id"] = doc.id;

            return Pedido.fromMap(data);

          }).toList();

          /// ORDENAR POR RUTA
          pedidos.sort(
            (a, b) =>
                (a.ordenRuta ?? 0)
                    .compareTo(
              b.ordenRuta ?? 0,
            ),
          );

          if (pedidos.isEmpty) {

            return const Center(
              child: Text(
                "Sin pedidos activos",
              ),
            );
          }

          /// SIEMPRE EL PRÓXIMO
          final pedido =
              pedidos.first;

          return SingleChildScrollView(

            child: Column(

              children: [

                _header(),

                const SizedBox(
                  height: 15,
                ),

                _estado(pedido),

                const SizedBox(
                  height: 15,
                ),

                _cliente(pedido),

                const SizedBox(
                  height: 15,
                ),

                _detalles(pedido),

                const SizedBox(
                  height: 15,
                ),

                _notas(),

                const SizedBox(
                  height: 20,
                ),

                _botones(
                  context,
                  pedido,
                ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// =========================
  /// HEADER
  /// =========================
  Widget _header() {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 25,
      ),

      decoration:
          const BoxDecoration(

        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.darkBlue,
          ],
        ),

        borderRadius:
            BorderRadius.vertical(
          bottom:
              Radius.circular(30),
        ),
      ),

      child: const Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            "Pedido en Curso",

            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            "Detalles de entrega",

            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ESTADO
  /// =========================
  Widget _estado(
    Pedido pedido,
  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Container(

        width: double.infinity,

        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(

          color:
              Colors.orange.withOpacity(
            0.2,
          ),

          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        child: const Center(

          child: Text(
            "En reparto",

            style: TextStyle(
              color: Colors.orange,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// =========================
  /// CLIENTE
  /// =========================
  Widget _cliente(
    Pedido pedido,
  ) {

    return _card(

      Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "Información del Cliente",

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
          "Nombre: ${pedido.nombreCliente ?? "Cliente"}",
              ),

          const SizedBox(
            height: 10,
          ),

          Row(

            children: [

              const Icon(
                Icons.phone,
                color: Colors.blue,
              ),

              const SizedBox(
                width: 5,
              ),

              Text(
                pedido.telefono,
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Row(

            children: [

              const Icon(
                Icons.location_on,
                color: Colors.blue,
              ),

              const SizedBox(
                width: 5,
              ),

              Expanded(
                child: Text(
                  pedido
                      .direccionEntrega,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// DETALLES
  /// =========================
  Widget _detalles(
    Pedido pedido,
  ) {

    final fecha =
        pedido.fechaCreacion != null

            ? DateFormat(
                'dd MMM yyyy',
              ).format(
                pedido
                    .fechaCreacion!,
              )

            : '';

    return _card(

      Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "Detalles del Pedido",

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              const Text("Fecha:"),

              Text(fecha),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              const Text(
                "Garrafones:",
              ),

              Text(
                "${pedido.cantidad} unidades",
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              const Text("Total:"),

              Text(

                "\$${pedido.total} MXN",

                style: const TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// NOTAS
  /// =========================
  Widget _notas() {

    return _card(

      Row(

        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: const [

          Text(
            "Notas del Pedido",
          ),

          Text(
            "Agregar",

            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// BOTONES
  /// =========================
  Widget _botones(
    BuildContext context,
    Pedido pedido,
  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Column(

        children: [

          /// =====================================
          /// ENTREGADO
          /// =====================================
          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green,

                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 15,
                ),
              ),

              onPressed: () async {

                /// COMPLETAR
                await FirebaseFirestore
                    .instance
                    .collection("orders")
                    .doc(pedido.id)
                    .update({
                  "estado":
                      "completado",
                });

                /// VERIFICAR RESTANTES
                final restantes =
                    await FirebaseFirestore
                        .instance
                        .collection(
                          "orders",
                        )
                        .where(
                          "id_repartidor",
                          isEqualTo:
                              usuario.uid,
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
                if (restantes
                    .docs
                    .isEmpty) {

                  await FirebaseFirestore
                      .instance
                      .collection(
                        "users",
                      )
                      .doc(usuario.uid)
                      .update({
                    "disponible":
                        true,
                  });
                }
              },

              child: const Text(
                "Marcar como Entregado",
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          /// =====================================
          /// CANCELADO
          /// =====================================
          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,

                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 15,
                ),
              ),

              onPressed: () async {

                /// CANCELAR
                await FirebaseFirestore
                    .instance
                    .collection("orders")
                    .doc(pedido.id)
                    .update({
                  "estado":
                      "cancelado",
                });

                /// VERIFICAR RESTANTES
                final restantes =
                    await FirebaseFirestore
                        .instance
                        .collection(
                          "orders",
                        )
                        .where(
                          "id_repartidor",
                          isEqualTo:
                              usuario.uid,
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
                if (restantes
                    .docs
                    .isEmpty) {

                  await FirebaseFirestore
                      .instance
                      .collection(
                        "users",
                      )
                      .doc(usuario.uid)
                      .update({
                    "disponible":
                        true,
                  });
                }
              },

              child: const Text(
                "Marcar como No Entregado",
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// CARD BASE
  /// =========================
  Widget _card(
    Widget child,
  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Container(

        padding:
            const EdgeInsets.all(
          18,
        ),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          boxShadow: [

            BoxShadow(
              blurRadius: 6,
              color:
                  Colors.black.withOpacity(
                0.05,
              ),
            ),
          ],
        ),

        child: child,
      ),
    );
  }
}