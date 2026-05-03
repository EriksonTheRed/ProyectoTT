import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purificadora_app/domain/models/pedido.dart';

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = 'orders';

  /// =========================
  /// CREAR PEDIDO
  /// =========================
  Future<void> createPedido({
    required String clienteId,
    required String direccionEntrega,
    required String telefono,
    required int cantidad,
    required double total,
    required GeoPoint ubicacion,
  }) async {
    if (cantidad <= 0) {
      throw Exception('Cantidad inválida');
    }

    final doc = _firestore.collection(_collection).doc();

    final pedido = Pedido(
      id: doc.id,
      clienteId: clienteId,
      repartidorId: null,
      estado: EstadoPedido.pendiente,
      direccionEntrega: direccionEntrega,
      telefono: telefono,
      cantidad: cantidad,
      total: total,
      ubicacion: ubicacion,
      fechaCreacion: DateTime.now(),
      fechaEntrega: null,
    );

    await doc.set(pedido.toMap());
  }

  /// =========================
  /// OBTENER PEDIDO POR ID
  /// =========================
  Future<Pedido?> getPedidoById(String pedidoId) async {
    final doc = await _firestore.collection(_collection).doc(pedidoId).get();

    if (!doc.exists) return null;

    return Pedido.fromMap(doc.data()!);
  }

  /// =========================
  /// OBTENER PEDIDOS POR CLIENTE
  /// =========================
  Future<List<Pedido>> getPedidosByCliente(String clienteId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('id_cliente', isEqualTo: clienteId)
        .orderBy('fecha_creacion', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Pedido.fromMap({
        'id': data['id'],
        'clienteId': data['id_cliente'],
        'repartidorId': data['id_repartidor'],
        'estado': data['estado'],
        'direccionEntrega': data['direccion_entrega'],
        'telefono': data['telefono'],
        'cantidad': data['cantidad'],
        'total': data['total'],
        'ubicacion': data['ubicacion'],
        'fechaCreacion': data['fecha_creacion'],
        'fechaEntrega': data['fecha_entrega'],
      });
    }).toList();
  }

  /// =========================
  /// OBTENER PEDIDOS POR REPARTIDOR
  /// =========================
  Future<List<Pedido>> getPedidosByRepartidor(String repartidorId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('id_repartidor', isEqualTo: repartidorId)
        .orderBy('fecha_creacion', descending: true)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// OBTENER PEDIDOS PENDIENTES
  /// =========================
  Future<List<Pedido>> getPedidosPendientes() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('estado', isEqualTo: EstadoPedido.pendiente.name)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// ASIGNAR REPARTIDOR (SOLO DATA, SIN VALIDACIONES DE ROL)
  /// =========================
  Future<void> assignRepartidor({
    required String pedidoId,
    required String repartidorId,
  }) async {
    final pedidoRef = _firestore.collection(_collection).doc(pedidoId);

    await pedidoRef.update({
      'id_repartidor': repartidorId,
      'estado': EstadoPedido.proceso.name,
    });
  }

  /// =========================
  /// ACTUALIZAR ESTADO DEL PEDIDO
  /// =========================
  Future<void> updateEstado({
    required String pedidoId,
    required EstadoPedido nuevoEstado,
  }) async {
    final pedidoRef = _firestore.collection(_collection).doc(pedidoId);
    final doc = await pedidoRef.get();

    if (!doc.exists) {
      throw Exception('Pedido no encontrado');
    }

    final pedido = Pedido.fromMap(doc.data()!);

    if (!_isValidTransition(pedido.estado, nuevoEstado)) {
      throw Exception('Transición inválida');
    }

    final updateData = <String, dynamic>{'estado': nuevoEstado.name};

    /// Si se completa, registrar fecha de entrega
    if (nuevoEstado == EstadoPedido.completado) {
      updateData['fecha_entrega'] = DateTime.now();
    }

    await pedidoRef.update(updateData);
  }

  /// =========================
  /// VALIDAR TRANSICIONES
  /// =========================
  bool _isValidTransition(EstadoPedido actual, EstadoPedido nuevo) {
    const transiciones = {
      EstadoPedido.pendiente: [EstadoPedido.proceso, EstadoPedido.cancelado],
      EstadoPedido.proceso: [EstadoPedido.completado, EstadoPedido.cancelado],
      EstadoPedido.completado: [],
      EstadoPedido.cancelado: [],
    };

    return transiciones[actual]?.contains(nuevo) ?? false;
  }

  Future<List<Pedido>> getPedidos() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('fecha_creacion', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Pedido.fromMap(data);
    }).toList();
  }
}
