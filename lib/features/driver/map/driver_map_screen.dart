// driver_map_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';

import 'package:purificadora_app/data/repositories/directions_repository.dart';
import 'package:purificadora_app/domain/models/directions.dart';

class DriverMapScreen extends StatefulWidget {

  final Usuario usuario;

  const DriverMapScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<DriverMapScreen>
      createState() =>
          _DriverMapScreenState();
}

class _DriverMapScreenState
    extends State<DriverMapScreen> {

  final DirectionsRepository
      _directionsRepository =
          DirectionsRepository();

  GoogleMapController?
      mapController;

  @override
  Widget build(
    BuildContext context,
  ) {

    return StreamBuilder<
      QuerySnapshot
    >(

      stream:
          FirebaseFirestore
              .instance
              .collection(
                "orders",
              )
              .where(
                "id_repartidor",
                isEqualTo:
                    widget
                        .usuario
                        .uid,
              )
              .where(
                "estado",
                whereIn: [
                  "pendiente",
                  "proceso",
                ],
              )
              .snapshots(),

      builder:
          (
            context,
            snapshot,
          ) {

        if (!snapshot.hasData) {

          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        final docs =
            snapshot.data!.docs;

        if (docs.isEmpty) {

          return const Scaffold(
            body: Center(
              child: Text(
                "Sin pedidos activos",
              ),
            ),
          );
        }

        final pedidos =
            docs.map((doc) {

          final data =
              doc.data()
                  as Map<
                    String,
                    dynamic
                  >;

          data["id"] =
              doc.id;

          return Pedido.fromMap(
            data,
          );

        }).toList();

        pedidos.sort(
          (a, b) =>
              (a.ordenRuta ??
                      0)
                  .compareTo(
                    b.ordenRuta ??
                        0,
                  ),
        );

        /// =========================
        /// MARKERS
        /// =========================
        final markers =
            <Marker>{};

        for (
          int i = 0;
          i < pedidos.length;
          i++
        ) {

          final p =
              pedidos[i];

          markers.add(
            Marker(
              markerId:
                  MarkerId(
                    p.id,
                  ),

              position: LatLng(
                p.ubicacion
                    .latitude,

                p.ubicacion
                    .longitude,
              ),

              infoWindow:
                  InfoWindow(
                title:
                    "Entrega ${i + 1}",
              ),
            ),
          );
        }

        return Scaffold(

          appBar: AppBar(
            title: const Text(
              "Ruta de Entregas",
            ),
          ),

          body: FutureBuilder<
            _RouteData
          >(

            future:
                _buildRoutes(
                  pedidos,
                ),

            builder:
                (
                  context,
                  routeSnapshot,
                ) {

              if (!routeSnapshot
                  .hasData) {

                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final data =
                  routeSnapshot
                      .data!;

              return GoogleMap(

                onMapCreated: (
                  controller,
                ) {

                  mapController =
                      controller;

                  if (data
                      .allPoints
                      .isNotEmpty) {

                    Future.delayed(
                      const Duration(
                        milliseconds:
                            500,
                      ),

                      () {

                        final bounds =
                            _boundsFromLatLngList(
                          data
                              .allPoints,
                        );

                        mapController!
                            .animateCamera(
                          CameraUpdate.newLatLngBounds(
                            bounds,
                            80,
                          ),
                        );
                      },
                    );
                  }
                },

                initialCameraPosition:
                    CameraPosition(
                  target:
                      data
                          .allPoints
                          .first,

                  zoom: 13,
                ),

                markers:
                    markers,

                polylines:
                    data
                        .polylines,

                myLocationEnabled:
                    true,
              );
            },
          ),
        );
      },
    );
  }

  /// =========================
  /// CREAR RUTAS
  /// =========================
  Future<_RouteData>
      _buildRoutes(
    List<Pedido> pedidos,
  ) async {

    final colores = [

      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];

    final polylines =
        <Polyline>{};

    final allPoints =
        <LatLng>[];

    for (
      int i = 0;
      i < pedidos.length;
      i++
    ) {

      final pedido =
          pedidos[i];

      final previousPoint =
          LatLng(

        pedido
            .puntoAnteriorLat!,

        pedido
            .puntoAnteriorLng!,
      );

      final destino = LatLng(
        pedido.ubicacion
            .latitude,

        pedido.ubicacion
            .longitude,
      );

      final Directions?
          directions =
          await _directionsRepository
              .getDirections(
        origin:
            previousPoint,

        destination:
            destino,
      );

      if (directions != null) {

        final points =
            directions
                .polylinePoints
                .map(
                  (
                    e,
                  ) => LatLng(
                    e.latitude,
                    e.longitude,
                  ),
                )
                .toList();

        allPoints.addAll(
          points,
        );

        polylines.add(
          Polyline(

            polylineId:
                PolylineId(
              "ruta_$i",
            ),

            points:
                points,

            width: 7,

            color:
                colores[
                    i %
                    colores.length],
          ),
        );
      }
    }

    return _RouteData(
      polylines:
          polylines,

      allPoints:
          allPoints,
    );
  }

  /// =========================
  /// BOUNDS
  /// =========================
  LatLngBounds
      _boundsFromLatLngList(
    List<LatLng> list,
  ) {

    double x0 =
        list.first.latitude;

    double x1 =
        list.first.latitude;

    double y0 =
        list.first.longitude;

    double y1 =
        list.first.longitude;

    for (
      LatLng latLng
          in list
    ) {

      if (
        latLng.latitude >
        x1
      ) {
        x1 =
            latLng.latitude;
      }

      if (
        latLng.latitude <
        x0
      ) {
        x0 =
            latLng.latitude;
      }

      if (
        latLng.longitude >
        y1
      ) {
        y1 =
            latLng.longitude;
      }

      if (
        latLng.longitude <
        y0
      ) {
        y0 =
            latLng.longitude;
      }
    }

    return LatLngBounds(
      northeast:
          LatLng(
        x1,
        y1,
      ),

      southwest:
          LatLng(
        x0,
        y0,
      ),
    );
  }
}

class _RouteData {

  final Set<Polyline>
      polylines;

  final List<LatLng>
      allPoints;

  _RouteData({
    required this.polylines,
    required this.allPoints,
  });
}