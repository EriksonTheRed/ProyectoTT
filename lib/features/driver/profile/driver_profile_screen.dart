import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/role_selector_screen.dart';

class Repartidor {
  final String nombre;
  final String telefono;

  Repartidor({
    required this.nombre,
    required this.telefono,
  });
}

class EstadisticasRepartidor {
  final int semana;
  final int mes;
  final int total;

  EstadisticasRepartidor({
    required this.semana,
    required this.mes,
    required this.total,
  });
}

class DriverProfileScreen extends StatelessWidget {
  final Repartidor repartidor;

  const DriverProfileScreen({
    super.key,
    required this.repartidor,
  });

  @override
  Widget build(BuildContext context) {

    final stats = EstadisticasRepartidor(
      semana: 47,
      mes: 182,
      total: 1712,
    );

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPersonalInfo(),
            const SizedBox(height: 20),
            _buildStats(stats),
            const SizedBox(height: 20),
            _logoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.darkBlue,
          ],
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
            "Mi Perfil",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Información del repartidor",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Datos Personales",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Editar",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Nombre Completo\n${repartidor.nombre}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Teléfono de Contacto\n${repartidor.telefono}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(EstadisticasRepartidor stats) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estadísticas",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          _StatRow(
            label: "Entregas esta semana:",
            value: stats.semana.toString(),
          ),

          const SizedBox(height: 10),

          _StatRow(
            label: "Entregas este mes:",
            value: stats.mes.toString(),
          ),

          const SizedBox(height: 10),

          _StatRow(
            label: "Entregas totales:",
            value: stats.total.toString(),
          ),
        ],
      ),
    );
  }

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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const RoleSelectorScreen(),
              ),
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
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}