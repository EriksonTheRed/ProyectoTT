import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/features/auth/login_screen.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/auth_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final Usuario usuario;

  const ProfileScreen({super.key, required this.usuario});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  late Usuario usuario;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightBackground,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _logoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// HEADER
  /// =========================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Mi Perfil",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),

          const SizedBox(height: 12),

          Text(
            usuario.nombre,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: _editarPerfil,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Editar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// INFO
  /// =========================
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Información Personal",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 20),

            _InfoTile(Icons.person, usuario.nombre),
            const SizedBox(height: 15),

            _InfoTile(Icons.email, usuario.correo),
            const SizedBox(height: 15),

            _InfoTile(Icons.phone, usuario.telefono),
            const SizedBox(height: 15),

            _InfoTile(Icons.location_on, usuario.direccion ?? ""),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Widget _logoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () async {
            await _authService.signOut();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text("Cerrar sesión"),
        ),
      ),
    );
  }

  /// =========================
  /// EDITAR PERFIL
  /// =========================
  void _editarPerfil() async {
    final nombreController = TextEditingController(text: usuario.nombre);
    final telefonoController = TextEditingController(text: usuario.telefono);
    final direccionController = TextEditingController(
      text: usuario.direccion ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Perfil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreController),
            TextField(controller: telefonoController),
            TextField(controller: direccionController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _userService.updateUserProfile(
                uid: usuario.uid,
                nombre: nombreController.text,
                telefono: telefonoController.text,
                direccion: direccionController.text,
              );

              setState(() {
                usuario = usuario.copyWith(
                  nombre: nombreController.text,
                  telefono: telefonoController.text,
                  direccion: direccionController.text,
                );
              });

              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoTile(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
