import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/auth_service.dart';
import 'package:purificadora_app/features/auth/login_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  final Usuario usuario;

  const DriverProfileScreen({super.key, required this.usuario});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final PedidoService _pedidoService = PedidoService();
  final AuthService _authService = AuthService();

  int semana = 0;
  int mes = 0;
  int total = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _pedidoService.obtenerEstadisticasRepartidor(
      widget.usuario.uid,
    );

    setState(() {
      semana = stats['semana'] ?? 0;
      mes = stats['mes'] ?? 0;
      total = stats['total'] ?? 0;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPersonalInfo(),
                  const SizedBox(height: 20),
                  _buildStats(),
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
      child: const Text(
        "Mi Perfil",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// =========================
  /// INFO
  /// =========================
  Widget _buildPersonalInfo() {
    final user = widget.usuario;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Datos Personales",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(child: Text(user.nombre)),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(child: Text(user.telefono)),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// STATS
  /// =========================
  Widget _buildStats() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estadísticas",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          _statRow("Entregas esta semana:", "$semana"),
          const SizedBox(height: 10),
          _statRow("Entregas este mes:", "$mes"),
          const SizedBox(height: 10),
          _statRow("Entregas totales:", "$total"),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Widget _logoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await _authService.signOut();

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        child: const Text("Cerrar sesión"),
      ),
    );
  }

  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
