import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/auth_service.dart';

import 'package:purificadora_app/features/admin/users/admin_users_screen.dart';
import 'package:purificadora_app/features/admin/orders/admin_orders_screen.dart';
import 'package:purificadora_app/features/admin/monitor/admin_monitor_screen.dart';
import 'package:purificadora_app/features/auth/login_screen.dart';

class AdminConfigScreen extends StatefulWidget {
  final Usuario usuario;
  final void Function(int) onNavigate;

  const AdminConfigScreen({
    super.key,
    required this.usuario,
    required this.onNavigate,
  });

  @override
  State<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<AdminConfigScreen> {
  final AuthService _auth = AuthService();

  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProfile(widget.usuario),
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
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: top + 20, left: 20, right: 20, bottom: 30),
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
  /// SISTEMA
  /// =========================
  Widget _buildSystemInfo() {
    return _card(
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
  /// ACTIONS
  /// =========================
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _actionButton(
            icon: Icons.person_add,
            label: "Crear Usuario",
            onPressed: () => widget.onNavigate(1),
          ),

          const SizedBox(height: 10),

          _actionButton(
            icon: Icons.list,
            label: "Ver Pedidos",
            onPressed: () => widget.onNavigate(2),
          ),

          const SizedBox(height: 10),

          _actionButton(
            icon: Icons.show_chart,
            label: "Monitoreo",
            onPressed: () => widget.onNavigate(3),
          ),

          const SizedBox(height: 10),

          /// LOGOUT CORRECTO
          _actionButton(
            icon: Icons.logout,
            label: isLoggingOut ? "Cerrando sesión..." : "Cerrar Sesión",
            isLoading: isLoggingOut,
            color: Colors.red,
            onPressed: isLoggingOut ? null : _handleLogout,
          ),
        ],
      ),
    );
  }

  /// =========================
  /// BOTÓN REUTILIZABLE
  /// =========================
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color color = Colors.blue,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onPressed == null ? 0.6 : 1,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, size: 20),

              const SizedBox(width: 10),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> _handleLogout() async {
    if (isLoggingOut) return;

    setState(() => isLoggingOut = true);

    try {
      await _auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoggingOut = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al cerrar sesión")));
    }
  }

  /// =========================
  /// CARD BASE
  /// =========================
  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: child,
      ),
    );
  }
}
