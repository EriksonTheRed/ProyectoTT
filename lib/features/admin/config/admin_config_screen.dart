import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/auth_service.dart';

class AdminConfigScreen extends StatelessWidget {
  final Usuario usuario;

  const AdminConfigScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProfile(usuario),
            const SizedBox(height: 20),
            _buildSystemInfo(),
            const SizedBox(height: 20),
            _buildActions(context),
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
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
      ),
      child: const Text(
        "Administración",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// =========================
  /// PERFIL
  /// =========================
  Widget _buildProfile(Usuario usuario) {
    return _card(
      Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              usuario.nombre[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(usuario.correo, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// INFO SISTEMA
  /// =========================
  Widget _buildSystemInfo() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Sistema", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Base de datos: Firebase"),
          Text("Notificaciones: Pendiente"),
          Text("Estado: Operativo"),
        ],
      ),
    );
  }

  /// =========================
  /// ACCIONES (BACKEND REAL)
  /// =========================
  Widget _buildActions(BuildContext context) {
    final auth = AuthService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          /// 👉 CREAR USUARIO
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/admin/users');
            },
            icon: const Icon(Icons.person_add),
            label: const Text("Crear Usuario"),
          ),

          const SizedBox(height: 10),

          /// 👉 VER PEDIDOS
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/admin/orders');
            },
            icon: const Icon(Icons.list),
            label: const Text("Ver Pedidos"),
          ),

          const SizedBox(height: 10),

          /// 👉 MONITOREO
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/admin/monitor');
            },
            icon: const Icon(Icons.show_chart),
            label: const Text("Monitoreo"),
          ),

          const SizedBox(height: 10),

          /// 👉 LOGOUT (YA BIEN HECHO)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await auth.signOut();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar Sesión"),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// CARD
  /// =========================
  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }
}
