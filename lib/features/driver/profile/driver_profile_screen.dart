import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/auth_service.dart';
import 'package:purificadora_app/data/services/delivery_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:purificadora_app/data/services/admin_service.dart';
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
  final DeliveryService _deliveryService = DeliveryService(
    PedidoService(),
    UserService(),
  );
  final AdminService _adminService = AdminService(
    PedidoService(),
    UserService(),
  );

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
    try {
      final pedidos = await _pedidoService.getPedidosByRepartidor(
        widget.usuario.uid,
      );

      final now = DateTime.now();

      final inicioSemana = now.subtract(Duration(days: now.weekday - 1));

      final inicioMes = DateTime(now.year, now.month, 1);

      int semanaCount = 0;
      int mesCount = 0;
      int totalCount = 0;

      for (var p in pedidos) {
        if (p.estado != EstadoPedido.completado) continue;

        totalCount++;

        if (p.fechaEntrega != null) {
          final fecha = p.fechaEntrega!;

          if (fecha.isAfter(inicioSemana)) {
            semanaCount++;
          }

          if (fecha.isAfter(inicioMes)) {
            mesCount++;
          }
        }
      }

      setState(() {
        semana = semanaCount;
        mes = mesCount;
        total = totalCount;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR STATS: $e");
      setState(() => isLoading = false);
    }
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
