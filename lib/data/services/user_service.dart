import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String collection = 'users';

  /// =========================
  /// USUARIO ACTUAL
  /// =========================
  Future<Usuario?> getCurrentUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection(collection).doc(uid).get();

      if (!doc.exists) return null;

      return Usuario.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  /// =========================
  /// OBTENER USUARIO POR ID
  /// =========================
  Future<Usuario?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(collection).doc(uid).get();

      if (!doc.exists) return null;

      return Usuario.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  /// =========================
  /// OBTENER USUARIOS POR ROL
  /// =========================
  Future<List<Usuario>> getUsersByRole(String rol) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('rol', isEqualTo: rol)
        .get();

    return snapshot.docs.map((doc) => Usuario.fromMap(doc.data())).toList();
  }

  /// =========================
  /// OBTENER REPARTIDORES
  /// =========================
  Future<List<Usuario>> getRepartidores() async {
    final snapshot = await _firestore
        .collection(collection)
        .where('rol', isEqualTo: 'repartidor')
        .get();

    return snapshot.docs.map((doc) => Usuario.fromMap(doc.data())).toList();
  }

  /// =========================
  /// ACTUALIZAR PERFIL
  /// =========================
  Future<String?> updateUserProfile({
    required String uid,
    String? nombre,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (nombre != null) data['nombre'] = nombre;
      if (telefono != null) data['telefono'] = telefono;
      if (direccion != null) data['direccion'] = direccion;

      if (data.isEmpty) return "No hay datos para actualizar";

      await _firestore.collection(collection).doc(uid).update(data);

      return null;
    } catch (_) {
      return "Error al actualizar perfil";
    }
  }

  /// =========================
  /// ACTIVAR / DESACTIVAR USUARIO
  /// =========================
  Future<String?> setUserActive({
    required String uid,
    required bool activo,
  }) async {
    try {
      await _firestore.collection(collection).doc(uid).update({
        'activo': activo,
      });

      return null;
    } catch (_) {
      return "Error al actualizar estado";
    }
  }
}
