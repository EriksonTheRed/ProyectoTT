import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purificadora_app/domain/models/pedido.dart';

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'orders';

  /// =========================
  /// CREAR PEDIDO (CLIENTE)
  /// =========================
  Future<String?> crearPedido({
    required String clienteId,
    required String direccionEntrega,
    required String telefono,
    required int cantidad,
    required double total,
    required GeoPoint ubicacion,
  }) async {
    try {
      if (cantidad <= 0) return "Cantidad inválida";

      final doc = _firestore.collection(collection).doc();

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

      return null;
    } catch (_) {
      return "Error al crear pedido";
    }
  }

  Future<List<Pedido>> obtenerPedidosPorRepartidor(String repartidorId) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('id_repartidor', isEqualTo: repartidorId)
        .where('estado', isEqualTo: EstadoPedido.completado.name)
        .orderBy('fecha_entrega', descending: true)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// OBTENER PEDIDOS CLIENTE
  /// =========================
  Future<List<Pedido>> obtenerPedidosCliente(String clienteId) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('id_cliente', isEqualTo: clienteId)
        .orderBy('fecha_creacion', descending: true)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// OBTENER PEDIDOS DISPONIBLES (ADMIN)
  /// =========================
  Future<List<Pedido>> obtenerPedidosPendientes() async {
    final snapshot = await _firestore
        .collection(collection)
        .where('estado', isEqualTo: EstadoPedido.pendiente.name)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// ASIGNAR REPARTIDOR (ADMIN)
  /// =========================
  Future<String?> asignarRepartidor({
    required String pedidoId,
    required String repartidorId,
  }) async {
    try {
      final pedidoRef = _firestore.collection(collection).doc(pedidoId);
      final pedidoDoc = await pedidoRef.get();

      if (!pedidoDoc.exists) return "Pedido no encontrado";

      final pedido = Pedido.fromMap(pedidoDoc.data()!);

      if (pedido.estado != EstadoPedido.pendiente) {
        return "El pedido no está disponible";
      }

      /// 🔥 Validar disponibilidad del repartidor
      final repartidorDoc = await _firestore
          .collection('users')
          .doc(repartidorId)
          .get();

      if (!repartidorDoc.exists) return "Repartidor no existe";

      if (repartidorDoc['disponible'] != true) {
        return "Repartidor no disponible";
      }

      /// 🔥 Actualizar pedido
      final actualizado = pedido.copyWith(
        repartidorId: repartidorId,
        estado: EstadoPedido.proceso,
      );

      await pedidoRef.update(actualizado.toMap());

      /// 🔥 Marcar repartidor ocupado
      await _firestore.collection('users').doc(repartidorId).update({
        'disponible': false,
      });

      return null;
    } catch (_) {
      return "Error al asignar repartidor";
    }
  }

  /// =========================
  /// ACTUALIZAR ESTADO
  /// =========================
  Future<String?> actualizarEstado({
    required String pedidoId,
    required EstadoPedido nuevoEstado,
  }) async {
    try {
      final pedidoRef = _firestore.collection(collection).doc(pedidoId);
      final doc = await pedidoRef.get();

      if (!doc.exists) return "Pedido no encontrado";

      final pedido = Pedido.fromMap(doc.data()!);

      if (!_transicionValida(pedido.estado, nuevoEstado)) {
        return "Transición inválida";
      }

      final actualizado = pedido.copyWith(estado: nuevoEstado);

      await pedidoRef.update({'estado': actualizado.estado.name});

      return null;
    } catch (_) {
      return "Error al actualizar estado";
    }
  }

  /// =========================
  /// CONFIRMAR ENTREGA (ADMIN)
  /// =========================
  Future<String?> confirmarEntrega(String pedidoId) async {
    try {
      final pedidoRef = _firestore.collection(collection).doc(pedidoId);
      final doc = await pedidoRef.get();

      if (!doc.exists) return "Pedido no encontrado";

      final pedido = Pedido.fromMap(doc.data()!);

      if (pedido.estado != EstadoPedido.proceso) {
        return "El pedido no está en proceso";
      }

      final actualizado = pedido.copyWith(
        estado: EstadoPedido.completado,
        fechaEntrega: DateTime.now(),
      );

      await pedidoRef.update({
        'estado': actualizado.estado.name,
        'fecha_entrega': FieldValue.serverTimestamp(),
      });

      /// 🔥 Liberar repartidor
      if (pedido.repartidorId != null) {
        await _firestore.collection('users').doc(pedido.repartidorId).update({
          'disponible': true,
        });
      }

      return null;
    } catch (_) {
      return "Error al confirmar entrega";
    }
  }

  /// =========================
  /// CANCELAR PEDIDO
  /// =========================
  Future<String?> cancelarPedido(String pedidoId) async {
    try {
      final pedidoRef = _firestore.collection(collection).doc(pedidoId);
      final doc = await pedidoRef.get();

      if (!doc.exists) return "Pedido no encontrado";

      final pedido = Pedido.fromMap(doc.data()!);

      await pedidoRef.update({'estado': EstadoPedido.cancelado.name});

      /// 🔥 Liberar repartidor si aplica
      if (pedido.repartidorId != null) {
        await _firestore.collection('users').doc(pedido.repartidorId).update({
          'disponible': true,
        });
      }

      return null;
    } catch (_) {
      return "Error al cancelar pedido";
    }
  }

  /// =========================
  /// VALIDACIÓN DE TRANSICIONES
  /// =========================
  bool _transicionValida(EstadoPedido actual, EstadoPedido nuevo) {
    const transiciones = {
      EstadoPedido.pendiente: [EstadoPedido.proceso, EstadoPedido.cancelado],
      EstadoPedido.proceso: [EstadoPedido.completado, EstadoPedido.cancelado],
      EstadoPedido.completado: [],
      EstadoPedido.cancelado: [],
    };

    return transiciones[actual]?.contains(nuevo) ?? false;
  }

  Future<List<Pedido>> obtenerPedidosAsignados(String repartidorId) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('id_repartidor', isEqualTo: repartidorId)
        .where('estado', isEqualTo: EstadoPedido.proceso.name)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  Future<List<Pedido>> obtenerPedidosCompletadosHoy(String repartidorId) async {
    final hoy = DateTime.now();

    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);

    final snapshot = await _firestore
        .collection(collection)
        .where('id_repartidor', isEqualTo: repartidorId)
        .where('estado', isEqualTo: EstadoPedido.completado.name)
        .where('fecha_entrega', isGreaterThanOrEqualTo: inicioDia)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  Future<Map<String, int>> obtenerEstadisticasRepartidor(
    String repartidorId,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('id_repartidor', isEqualTo: repartidorId)
        .where('estado', isEqualTo: EstadoPedido.completado.name)
        .get();

    int semana = 0;
    int mes = 0;
    int total = snapshot.docs.length;

    final now = DateTime.now();

    for (var doc in snapshot.docs) {
      final pedido = Pedido.fromMap(doc.data());
      final fecha = pedido.fechaEntrega;

      if (fecha == null) continue;

      final diferencia = now.difference(fecha).inDays;

      if (diferencia <= 7) semana++;
      if (fecha.month == now.month && fecha.year == now.year) mes++;
    }

    return {'semana': semana, 'mes': mes, 'total': total};
  }
}
