import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoPedido { pendiente, proceso, completado, cancelado }

class Pedido {
  final String id;
  final String clienteId;
  final String? repartidorId;

  final EstadoPedido estado;

  final String direccionEntrega;
  final String telefono;

  final int cantidad;
  final double total;

  final GeoPoint ubicacion;

  final DateTime? fechaCreacion;
  final DateTime? fechaEntrega;

  Pedido({
    required this.id,
    required this.clienteId,
    this.repartidorId,
    required this.estado,
    required this.direccionEntrega,
    required this.telefono,
    required this.cantidad,
    required this.total,
    required this.ubicacion,
    this.fechaCreacion,
    this.fechaEntrega,
  });

  /// =========================
  /// FROM MAP
  /// =========================
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      clienteId: map['id_cliente'],
      repartidorId: map['id_repartidor'],
      estado: _estadoFromString(map['estado']),
      direccionEntrega: map['direccion_entrega'],
      telefono: map['telefono'],
      cantidad: map['cantidad'],
      total: (map['total'] as num).toDouble(),
      ubicacion: map['ubicacion'] is GeoPoint
          ? map['ubicacion']
          : const GeoPoint(0, 0),
      fechaCreacion: (map['fecha_creacion'] as Timestamp?)?.toDate(),
      fechaEntrega: (map['fecha_entrega'] as Timestamp?)?.toDate(),
    );
  }

  /// =========================
  /// TO MAP
  /// =========================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_cliente': clienteId,
      'id_repartidor': repartidorId,
      'estado': estado.name,
      'direccion_entrega': direccionEntrega,
      'telefono': telefono,
      'cantidad': cantidad,
      'total': total,
      'ubicacion': ubicacion,
      'fecha_creacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : null,
      'fecha_entrega': fechaEntrega != null
          ? Timestamp.fromDate(fechaEntrega!)
          : null,
    };
  }

  /// =========================
  /// COPY WITH (clave para updates)
  /// =========================
  Pedido copyWith({
    String? id,
    String? clienteId,
    String? repartidorId,
    EstadoPedido? estado,
    String? direccionEntrega,
    String? telefono,
    int? cantidad,
    double? total,
    GeoPoint? ubicacion,
    DateTime? fechaCreacion,
    DateTime? fechaEntrega,
  }) {
    return Pedido(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      repartidorId: repartidorId ?? this.repartidorId,
      estado: estado ?? this.estado,
      direccionEntrega: direccionEntrega ?? this.direccionEntrega,
      telefono: telefono ?? this.telefono,
      cantidad: cantidad ?? this.cantidad,
      total: total ?? this.total,
      ubicacion: ubicacion ?? this.ubicacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
    );
  }

  /// =========================
  /// HELPERS
  /// =========================
  static EstadoPedido _estadoFromString(String? estado) {
    switch (estado) {
      case 'pendiente':
        return EstadoPedido.pendiente;
      case 'proceso':
        return EstadoPedido.proceso;
      case 'completado':
        return EstadoPedido.completado;
      case 'cancelado':
        return EstadoPedido.cancelado;
      default:
        return EstadoPedido.pendiente; // fallback seguro
    }
  }
}
