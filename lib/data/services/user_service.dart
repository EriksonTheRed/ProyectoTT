import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = 'users';

  /// =========================
  /// OBTENER USUARIO POR ID
  /// =========================
  Future<Usuario?> getUserById(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();

    if (!doc.exists) return null;

    return Usuario.fromMap(doc.data()!);
  }

  /// =========================
  /// OBTENER USUARIOS POR ROL
  /// =========================
  Future<List<Usuario>> getUsersByRole(String role) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('rol', isEqualTo: role)
        .get();

    return snapshot.docs.map((doc) => Usuario.fromMap(doc.data())).toList();
  }

  /// =========================
  /// OBTENER CLIENTES
  /// =========================
  Future<List<Usuario>> getClients() async {
    return getUsersByRole('cliente');
  }

  /// =========================
  /// OBTENER ADMINISTRADORES
  /// =========================
  Future<List<Usuario>> getAdmins() async {
    return getUsersByRole('admin');
  }

  /// =========================
  /// OBTENER REPARTIDORES
  /// =========================
  Future<List<Usuario>> getDeliveryUsers() async {
    return getUsersByRole('repartidor');
  }

  /// =========================
  /// OBTENER REPARTIDORES DISPONIBLES
  /// =========================
  Future<List<Usuario>> getAvailableDeliveryUsers() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('rol', isEqualTo: 'repartidor')
        .where('disponible', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Usuario.fromMap(doc.data())).toList();
  }

  /// =========================
  /// ACTUALIZAR PERFIL BASICO
  /// =========================
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? address,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['nombre'] = name;
    if (phone != null) data['telefono'] = phone;
    if (address != null) data['direccion'] = address;

    if (data.isEmpty) return;

    await _firestore.collection(_collection).doc(uid).update(data);
  }

  /// =========================
  /// CAMBIAR ESTADO ACTIVO
  /// =========================
  Future<void> updateUserActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    await _firestore.collection(_collection).doc(uid).update({
      'activo': isActive,
    });
  }

  /// =========================
  /// CAMBIAR DISPONIBILIDAD (REPARTIDOR)
  /// =========================
  Future<void> updateDeliveryAvailability({
    required String uid,
    required bool isAvailable,
  }) async {
    await _firestore.collection(_collection).doc(uid).update({
      'disponible': isAvailable,
    });
  }
}
