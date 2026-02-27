import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String id;
  final DocumentReference clienteRef;
  final DocumentReference? repartidorRef;
  final String estado;
  final double total;
  final Timestamp fechaCreacion;

  Pedido({
    required this.id,
    required this.clienteRef,
    this.repartidorRef,
    required this.estado,
    required this.total,
    required this.fechaCreacion,
  });

  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Pedido(
      id: doc.id,
      clienteRef: data['cliente_ref'],
      repartidorRef: data['repartidor_ref'],
      estado: data['estado'],
      total: (data['total'] as num).toDouble(),
      fechaCreacion: data['fecha_creacion'],
    );
  }
}
