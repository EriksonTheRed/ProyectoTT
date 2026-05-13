import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoPedido {
  pendiente,
  proceso,
  completado,
  cancelado,
}

class Pedido {

  final String id;
  
  final String clienteId;
  final String nombreCliente;
  final String? repartidorId;
  final String? nombreRepartidor;

  final EstadoPedido estado;

  final String direccionEntrega;
  final String telefono;

  final int cantidad;
  final double total;

  final GeoPoint ubicacion;

  final DateTime? fechaCreacion;
  final DateTime? fechaEntrega;

  final String? rutaPolyline;

  final int? ordenRuta;

  /// 🔥 NUEVOS
  final double? puntoAnteriorLat;
  final double? puntoAnteriorLng;

  Pedido({

    required this.nombreCliente,
    required this.id,

    required this.clienteId,

    this.repartidorId,
    this.nombreRepartidor,

    required this.estado,

    required this.direccionEntrega,

    required this.telefono,

    required this.cantidad,

    required this.total,

    required this.ubicacion,

    this.fechaCreacion,

    this.fechaEntrega,

    this.rutaPolyline,

    this.ordenRuta,

    this.puntoAnteriorLat,
    this.puntoAnteriorLng,
  });

  /// =========================
  /// FROM MAP
  /// =========================
  factory Pedido.fromMap(
    Map<String, dynamic> map,
  ) {

    return Pedido(

      id:
          map['id']
              as String? ??
          '',

      clienteId:
          map['id_cliente']
              as String? ??
          '',

      nombreCliente:
          map['nombre_cliente'] as String? ?? '',


      repartidorId:
          map['id_repartidor']
              as String?,

      nombreRepartidor:
          map["nombre_repartidor"],

      estado:
          EstadoPedido.values
              .firstWhere(

        (e) =>
            e.name ==
            (map['estado']
                    as String? ??
                'pendiente'),

        orElse:
            () =>
                EstadoPedido
                    .pendiente,
      ),

      direccionEntrega:
          map['direccion_entrega']
              as String? ??
          '',

      telefono:
          map['telefono']
              as String? ??
          '',

      cantidad:
          map['cantidad']
              as int? ??
          0,

      total:
          (map['total']
                  as num?)
              ?.toDouble() ??
          0.0,

      ubicacion:
          map['ubicacion']
              as GeoPoint,

      fechaCreacion:
          map['fecha_creacion'] !=
                  null
              ? (map['fecha_creacion']
                      as Timestamp)
                  .toDate()
              : null,

      fechaEntrega:
          map['fecha_entrega'] !=
                  null
              ? (map['fecha_entrega']
                      as Timestamp)
                  .toDate()
              : null,

      rutaPolyline:
          map['ruta_polyline']
              as String?,

      ordenRuta:
          map['orden_ruta']
              as int?,

      /// 🔥 NUEVOS
      puntoAnteriorLat:
          (map['punto_anterior_lat']
                  as num?)
              ?.toDouble(),

      puntoAnteriorLng:
          (map['punto_anterior_lng']
                  as num?)
              ?.toDouble(),
    );
  }

  /// =========================
  /// TO MAP
  /// =========================
  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'id_cliente':
          clienteId,

      'nombre_cliente':
          nombreCliente,    

      'id_repartidor':
          repartidorId,

      'nombre_repartidor':
          nombreRepartidor,

      'estado':
          estado.name,

      'direccion_entrega':
          direccionEntrega,

      'telefono':
          telefono,

      'cantidad':
          cantidad,

      'total':
          total,

      'ubicacion':
          ubicacion,

      'fecha_creacion':
          fechaCreacion != null
              ? Timestamp.fromDate(
                  fechaCreacion!,
                )
              : null,

      'fecha_entrega':
          fechaEntrega != null
              ? Timestamp.fromDate(
                  fechaEntrega!,
                )
              : null,

      'ruta_polyline':
          rutaPolyline,

      'orden_ruta':
          ordenRuta,

      /// 🔥 NUEVOS
      'punto_anterior_lat':
          puntoAnteriorLat,

      'punto_anterior_lng':
          puntoAnteriorLng,
    };
  }

  /// =========================
  /// COPY WITH
  /// =========================
  Pedido copyWith({

    String? id,

    String? nombreCliente,

    String? clienteId,

    String? repartidorId,

    String? nombreRepartidor,

    EstadoPedido? estado,

    String? direccionEntrega,

    String? telefono,

    int? cantidad,

    double? total,

    GeoPoint? ubicacion,

    DateTime? fechaCreacion,

    DateTime? fechaEntrega,

    String? rutaPolyline,

    int? ordenRuta,

    double? puntoAnteriorLat,
    double? puntoAnteriorLng,

  }) {

    return Pedido(

      id:
          id ?? this.id,

      clienteId:
          clienteId ??
              this.clienteId,

      nombreCliente:
          nombreCliente ?? 
              this.nombreCliente,        

      repartidorId:
          repartidorId ??
              this.repartidorId,


      nombreRepartidor:
          nombreRepartidor ??
              this.nombreRepartidor,

      estado:
          estado ?? this.estado,

      direccionEntrega:
          direccionEntrega ??
              this.direccionEntrega,

      telefono:
          telefono ??
              this.telefono,

      cantidad:
          cantidad ??
              this.cantidad,

      total:
          total ?? this.total,

      ubicacion:
          ubicacion ??
              this.ubicacion,

      fechaCreacion:
          fechaCreacion ??
              this.fechaCreacion,

      fechaEntrega:
          fechaEntrega ??
              this.fechaEntrega,

      rutaPolyline:
          rutaPolyline ??
              this.rutaPolyline,

      ordenRuta:
          ordenRuta ??
              this.ordenRuta,

      puntoAnteriorLat:
          puntoAnteriorLat ??
              this.puntoAnteriorLat,

      puntoAnteriorLng:
          puntoAnteriorLng ??
              this.puntoAnteriorLng,
    );
  }
}