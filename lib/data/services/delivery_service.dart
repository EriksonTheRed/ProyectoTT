import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String userCollection = 'users';
  final String orderCollection = 'orders';

  /// =========================
  /// OBTENER REPARTIDOR ACTUAL
  /// =========================
  Future<Usuario?> getCurrentDelivery() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection(userCollection).doc(uid).get();

      if (!doc.exists) return null;

      return Usuario.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  /// =========================
  /// CAMBIAR DISPONIBILIDAD
  /// =========================
  Future<String?> setDisponibilidad(bool disponible) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return "Usuario no autenticado";

      await _firestore.collection(userCollection).doc(uid).update({
        'disponible': disponible,
      });

      return null;
    } catch (_) {
      return "Error al actualizar disponibilidad";
    }
  }

  /// =========================
  /// OBTENER REPARTIDORES DISPONIBLES
  /// =========================
  Future<List<Usuario>> getRepartidoresDisponibles() async {
    final snapshot = await _firestore
        .collection(userCollection)
        .where('rol', isEqualTo: 'repartidor')
        .where('disponible', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Usuario.fromMap(doc.data())).toList();
  }

  /// =========================
  /// PEDIDOS ASIGNADOS AL REPARTIDOR
  /// =========================
  Future<List<Pedido>> getPedidosAsignados() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection(orderCollection)
        .where('id_repartidor', isEqualTo: uid)
        .where('estado', isEqualTo: EstadoPedido.proceso.name)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// OBTENER PEDIDO EN CURSO (UNO)
  /// =========================
  Future<Pedido?> getPedidoEnCurso() async {
    final pedidos = await getPedidosAsignados();

    if (pedidos.isEmpty) return null;

    /// 🔥 Asumimos solo uno activo
    return pedidos.first;
  }

  /// =========================
  /// MARCAR COMO ENTREGADO
  /// =========================
  Future<String?> marcarComoEntregado(String pedidoId) async {
    try {
      final pedidoRef = _firestore.collection(orderCollection).doc(pedidoId);
      final doc = await pedidoRef.get();

      if (!doc.exists) return "Pedido no encontrado";

      final pedido = Pedido.fromMap(doc.data()!);

      if (pedido.estado != EstadoPedido.proceso) {
        return "El pedido no está en proceso";
      }

      /// 🔥 Solo cambia estado (admin confirma después)
      await pedidoRef.update({'estado': EstadoPedido.proceso.name});

      return null;
    } catch (_) {
      return "Error al marcar entrega";
    }
  }

  /// =========================
  /// MARCAR COMO NO ENTREGADO
  /// =========================
  Future<String?> marcarNoEntregado(String pedidoId) async {
    try {
      final pedidoRef = _firestore.collection(orderCollection).doc(pedidoId);

      await pedidoRef.update({'estado': EstadoPedido.cancelado.name});

      /// 🔥 Liberar repartidor
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection(userCollection).doc(uid).update({
          'disponible': true,
        });
      }

      return null;
    } catch (_) {
      return "Error al marcar como no entregado";
    }
  }
}
