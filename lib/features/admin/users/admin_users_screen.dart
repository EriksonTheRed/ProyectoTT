import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final UserService _userService = UserService();

  List<Usuario> usuarios = [];
  bool loading = true;

  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  String rolSeleccionado = "cliente";
  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  /// =========================
  /// CARGAR TODOS LOS USUARIOS
  /// =========================
  Future<void> cargarUsuarios() async {
    try {
      final clientes = await _userService.getClients();
      final repartidores = await _userService.getDeliveryUsers();
      final admins = await _userService.getAdmins();

      setState(() {
        usuarios = [...clientes, ...repartidores, ...admins];
        loading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  /// =========================
  /// CREAR USUARIO (REAL)
  /// =========================
  Future<void> crearUsuario() async {
    if (correoCtrl.text.isEmpty || nombreCtrl.text.isEmpty) return;

    setState(() => isCreating = true);

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      final cred = await auth.createUserWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: "12345678", // 
      );

      final uid = cred.user!.uid;

      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'nombre': nombreCtrl.text,
        'telefono': telefonoCtrl.text,
        'correo': correoCtrl.text,
        'direccion': direccionCtrl.text,
        'rol': rolSeleccionado,
        'activo': true,
        'disponible': rolSeleccionado == 'repartidor',
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      nombreCtrl.clear();
      telefonoCtrl.clear();
      correoCtrl.clear();
      direccionCtrl.clear();

      await cargarUsuarios();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario creado")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isCreating = false);
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuarios")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _form(),
            const SizedBox(height: 20),
            _lista(),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// FORMULARIO BONITO
  /// =========================
  Widget _form() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _chip("cliente"),
              _chip("repartidor"),
              _chip("admin"),
            ],
          ),
          const SizedBox(height: 10),
          _input("Nombre completo", nombreCtrl),
          _input("Teléfono", telefonoCtrl),
          _input("Correo", correoCtrl),
          _input("Dirección", direccionCtrl),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: isCreating ? null : crearUsuario,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: isCreating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Registrar usuario"),
          )
        ],
      ),
    );
  }

  Widget _chip(String rol) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(rol),
        selected: rolSeleccionado == rol,
        onSelected: (_) {
          setState(() => rolSeleccionado = rol);
        },
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// =========================
  /// LISTA DINÁMICA
  /// =========================
  Widget _lista() {
    if (loading) {
      return const CircularProgressIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: usuarios.map((u) {
        return Card(
          child: ListTile(
            title: Text(u.nombre),
            subtitle: Text("${u.rol} - ${u.telefono}"),
          ),
        );
      }).toList(),
    );
  }
}