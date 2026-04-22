import 'package:flutter/material.dart';
import 'package:purificadora_app/features/auth/login_screen.dart';
import '../../../core/theme/app_theme.dart';

class Usuario {
  final String nombre;
  final String email;

  Usuario({required this.nombre, required this.email});
}

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
            _buildSystemStatus(),
            const SizedBox(height: 20),
            _buildSystemOptions(),
            const SizedBox(height: 20),
            _buildSecurity(),
            const SizedBox(height: 20),
            _buildActions(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Administración",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Configuración del sistema",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(Usuario usuario) {
    return _card(
      Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              usuario.nombre[0], // 🔤 Inicial del usuario
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

              Text(usuario.email, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Estado del Sistema",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              _StatusBox("Tiempo Activo", "99.9%", Colors.blue),
              SizedBox(width: 10),
              _StatusBox("Almacenamiento", "45%", Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemOptions() {
    return Column(
      children: [
        _sectionTitle("Sistema"),
        _option("Base de Datos", "PostgreSQL"),
        _option("Última Copia", "Hace 2 horas"),
        _option("Notificaciones", "Activas"),
      ],
    );
  }

  Widget _buildSecurity() {
    return Column(
      children: [_sectionTitle("Seguridad"), _option("Permisos", "Gestionar")],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text("Crear Copia de Seguridad"),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.help_outline),
              label: const Text("Centro de Ayuda"),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar Sesión"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _option(String title, String value) {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: [
              Text(value, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ],
      ),
    );
  }

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

class _StatusBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatusBox(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
