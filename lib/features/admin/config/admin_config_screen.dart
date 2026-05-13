import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/auth_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
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
  final UserService _userService = UserService();
  final PedidoService _pedidoService = PedidoService();

  bool isLoggingOut = false;
  int repartidoresActivos = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final reps = await _userService.getDeliveryUsers();

    setState(() {
      repartidoresActivos =
          reps.where((r) => r.activo == true).length;
    });
  }

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
            _buildSystemStatus(),
            const SizedBox(height: 20),
            _buildBackup(),
            const SizedBox(height: 20),
            _buildActions(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// HEADER
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
        "Configuración del Sistema",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// PERFIL
  Widget _buildProfile(Usuario usuario) {
    return _card(
      Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primaryBlue,
            child: Text(usuario.nombre[0],
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(usuario.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(usuario.correo,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estado del Sistema",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat("Sistema", "Operativo", Colors.green),
              _miniStat("Repartidores activos",
                  "$repartidoresActivos", Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackup() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Respaldo",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: _crearBackup,
            icon: const Icon(Icons.download),
            label: const Text("Generar copia de seguridad"),
          ),
        ],
      ),
    );
  }

  Future<void> _crearBackup() async {
    final pedidos = await _pedidoService.getPedidos();
    final usuarios = await _userService.getClients();

    debugPrint("Backup generado:");
    debugPrint("Pedidos: ${pedidos.length}");
    debugPrint("Usuarios: ${usuarios.length}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Backup generado (simulado)")),
    );
  }

  /// ACTIONS
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _actionButton(
            icon: Icons.people,
            label: "Usuarios",
            onPressed: () => widget.onNavigate(1),
          ),
          const SizedBox(height: 10),

          _actionButton(
            icon: Icons.list,
            label: "Pedidos",
            onPressed: () => widget.onNavigate(2),
          ),
          const SizedBox(height: 10),

          _actionButton(
            icon: Icons.monitor,
            label: "Monitoreo",
            onPressed: () => widget.onNavigate(3),
          ),
          const SizedBox(height: 10),

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

  Widget _miniStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color color = Colors.blue,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
            else
              Icon(icon),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => isLoggingOut = true);

    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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
        ),
        child: child,
      ),
    );
  }
}