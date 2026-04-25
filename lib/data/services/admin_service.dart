import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userCollection = 'users';
  final String orderCollection = 'orders';

  /// =========================
  /// OBTENER TODOS LOS PEDIDOS
  /// =========================
  Future<List<Pedido>> getAllPedidos() async {
    final snapshot = await _firestore.collection(orderCollection).get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// PEDIDOS POR ESTADO
  /// =========================
  Future<List<Pedido>> getPedidosByEstado(String estado) async {
    final snapshot = await _firestore
        .collection(orderCollection)
        .where('estado', isEqualTo: estado)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// USUARIOS POR ROL
  /// =========================
  Future<List<Usuario>> getUsuariosPorRol(String rol) async {
    final snapshot = await _firestore
        .collection(userCollection)
        .where('rol', isEqualTo: rol)
        .get();

    return snapshot.docs.map((doc) => Usuario.fromMap(doc.data())).toList();
  }

  /// =========================
  /// REPARTIDORES CON ESTADO
  /// =========================
  Future<List<Usuario>> getRepartidoresConEstado() async {
    final snapshot = await _firestore
        .collection(userCollection)
        .where('rol', isEqualTo: 'repartidor')
        .get();

    return snapshot.docs.map((doc) => Usuario.fromMap(doc.data())).toList();
  }

  /// =========================
  /// MONITOREO GENERAL
  /// =========================
  Future<Map<String, dynamic>> getMonitoreo() async {
    try {
      final pedidos = await getAllPedidos();
      final repartidores = await getRepartidoresConEstado();

      return {'pedidos': pedidos, 'repartidores': repartidores};
    } catch (_) {
      return {};
    }
  }

  /// =========================
  /// ACTIVAR / DESACTIVAR USUARIO
  /// =========================
  Future<String?> setUserActivo({
    required String uid,
    required bool activo,
  }) async {
    try {
      await _firestore.collection(userCollection).doc(uid).update({
        'activo': activo,
      });

      return null;
    } catch (_) {
      return "Error al actualizar usuario";
    }
  }

  /// =========================
  /// PEDIDOS ACTIVOS
  /// =========================
  Future<List<Pedido>> getPedidosActivos() async {
    final snapshot = await _firestore
        .collection(orderCollection)
        .where(
          'estado',
          whereIn: [EstadoPedido.pendiente.name, EstadoPedido.proceso.name],
        )
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// PEDIDOS HOY
  /// =========================
  Future<List<Pedido>> getPedidosHoy() async {
    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);

    final snapshot = await _firestore
        .collection(orderCollection)
        .where('fecha_creacion', isGreaterThanOrEqualTo: inicioDia)
        .get();

    return snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList();
  }

  /// =========================
  /// ASIGNAR REPARTIDOR
  /// =========================
  Future<String?> asignarRepartidor({
    required String pedidoId,
    required String repartidorId,
  }) async {
    try {
      await _firestore.collection(orderCollection).doc(pedidoId).update({
        'id_repartidor': repartidorId,
        'estado': EstadoPedido.proceso.name,
      });

      return null;
    } catch (_) {
      return "Error al asignar repartidor";
    }
  }

  /// =========================
  /// OBTENER USUARIO POR ID
  /// =========================
  Future<Usuario?> getUsuarioById(String uid) async {
    final doc = await _firestore.collection(userCollection).doc(uid).get();

    if (!doc.exists) return null;

    return Usuario.fromMap(doc.data()!);
  }

  Future<Map<String, dynamic>> getResumenAdmin() async {
    try {
      final usuariosSnapshot = await _firestore
          .collection(userCollection)
          .get();

      final pedidos = await getAllPedidos();
      final pedidosHoy = await getPedidosHoy();

      int clientes = 0;
      int repartidores = 0;

      for (var doc in usuariosSnapshot.docs) {
        final user = Usuario.fromMap(doc.data());

        if (user.rol == 'cliente') clientes++;
        if (user.rol == 'repartidor') repartidores++;
      }

      double ventas = pedidos.fold(0, (sum, p) => sum + p.total);

      return {
        'clientes': clientes,
        'repartidores': repartidores,
        'pedidosHoy': pedidosHoy.length,
        'ventas': ventas,
      };
    } catch (_) {
      return {};
    }
  }
}
