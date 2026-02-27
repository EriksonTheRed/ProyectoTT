import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Signup con soporte para campos específicos de tu BD
  Future<String?> signup({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String rol, // "cliente", "repartidor", "admin"
    String? direccion, // Opcional solo para cliente
  }) async {
    try {
      // 1. Crear en Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // 2. Preparar el mapa de datos base (Lo que todos los usuarios tienen)
      Map<String, dynamic> userData = {
        'nombre': nombre.trim(),
        'correo': email.trim(),
        'telefono': telefono.trim(),
        'rol': rol,
        'fecha_registro': FieldValue.serverTimestamp(),
      };

      // 3. Agregar campos específicos según tus capturas de pantalla
      if (rol == 'cliente') {
        userData['direccion'] = direccion ?? '';
        userData['ubicacion'] = null; // Para llenar después con GPS
        userData['referencia_entrega'] = '';
      } else if (rol == 'repartidor') {
        userData['disponible'] = true;
        userData['estado_repartidor'] = 'activo';
      } else if (rol == 'admin') {
        userData['nivel_acceso'] = 1;
        userData['activo'] = true;
      }

      // 4. Guardar en la colección 'usuarios'
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  //Login que devuelve el rol para la redirección
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Buscamos el documento en 'users'
      DocumentSnapshot userDoc = await _firestore
          .collection('users') // Ajustado al nombre de tu colección
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return userDoc['rol']; // Retorna "cliente", "repartidor" o "admin"
      } else {
        return "Usuario no encontrado en base de datos";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
