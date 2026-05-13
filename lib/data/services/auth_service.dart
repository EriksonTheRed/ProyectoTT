import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// =========================
  /// REGISTRO CLIENTE
  /// =========================
  /*Future<String?> signup({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      final usuario = Usuario(
        uid: uid,
        nombre: nombre.trim(),
        correo: email.trim(),
        telefono: telefono.trim(),
        rol: 'cliente',
        direccion: direccion.trim(),
        disponible: null,
      );

      await _firestore.collection('users').doc(uid).set(usuario.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (_) {
      return "Error inesperado";
    }
  }*/
  Future<String?> signup({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
    required String rol, // 🔥 nuevo
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      final usuario = Usuario(
        uid: uid,
        nombre: nombre.trim(),
        correo: email.trim(),
        telefono: telefono.trim(),
        rol: rol, // 🔥 ahora dinámico
        direccion: rol == 'cliente' ? direccion.trim() : null,
        disponible: rol == 'repartidor' ? true : null,
      );

      await _firestore.collection('users').doc(uid).set(usuario.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      print("ERROR SIGNUP: $e"); // 🔥 log real
      return "Error inesperado";
    }
  }

  /// =========================
  /// LOGIN
  /// =========================
  Future<Usuario?> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception("Usuario no encontrado en Firestore");
      }

      return Usuario.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      // 🔥 IMPORTANTE: log real
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      throw Exception(e.code); // temporal para debug
    } catch (e, stack) {
      // 🔥 LOG COMPLETO
      print("ERROR GENERAL: $e");
      print(stack);
      throw Exception("Error inesperado: $e");
    }
  }

  /// =========================
  /// CREAR USUARIO POR ADMIN
  /// =========================
  Future<String?> createUserByAdmin({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String rol,
  }) async {
    try {
      /// 🔥 Validar rol permitido
      if (!['cliente', 'repartidor', 'admin'].contains(rol)) {
        return "Rol inválido";
      }

      /// 🔥 Validar que quien ejecuta es ADMIN
      final currentUid = _auth.currentUser?.uid;

      if (currentUid == null) {
        return "No autenticado";
      }

      final currentUserDoc = await _firestore
          .collection('users')
          .doc(currentUid)
          .get();

      if (!currentUserDoc.exists || currentUserDoc.data()?['rol'] != 'admin') {
        return "Permiso denegado";
      }

      /// 🔥 Crear usuario en secondary auth
      final secondaryAuth = await _getSecondaryAuth();

      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      final usuario = Usuario(
        uid: uid,
        nombre: nombre.trim(),
        correo: email.trim(),
        telefono: telefono.trim(),
        rol: rol,
        direccion: null,
        disponible: rol == 'repartidor' ? true : null,
      );

      await _firestore.collection('users').doc(uid).set(usuario.toMap());

      await secondaryAuth.signOut(); // limpiar sesión secundaria

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "Error al crear usuario";
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// =========================
  /// USUARIO ACTUAL
  /// =========================
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// =========================
  /// SECONDARY AUTH
  /// =========================
  Future<FirebaseAuth> _getSecondaryAuth() async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'Secondary',
      options: Firebase.app().options,
    );

    return FirebaseAuth.instanceFor(app: secondaryApp);
  }

  /// =========================
  /// MANEJO DE ERRORES
  /// =========================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo ya está en uso';
      case 'invalid-email':
        return 'Correo inválido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      default:
        return 'Error de autenticación';
    }
  }
}
