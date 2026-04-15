import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class Repartidor {
  final String nombre;
  final String entregasHoy;
  final String estado;
  final Color estadoColor;
  final String pedidoActual;
  final String direccion;
  final String tiempo;

  Repartidor({
    required this.nombre,
    required this.entregasHoy,
    required this.estado,
    required this.estadoColor,
    required this.pedidoActual,
    required this.direccion,
    required this.tiempo,
  });
}

class AdminMonitorScreen extends StatelessWidget {
  const AdminMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Repartidor> repartidores = [
      Repartidor(
        nombre: "Christian",
        entregasHoy: "12 entregas hoy",
        estado: "Entregando",
        estadoColor: Colors.orange,
        pedidoActual: "#1234 - María González",
        direccion: "Calle Principal 123",
        tiempo: "Hace 1 min",
      ),
      Repartidor(
        nombre: "Juan",
        entregasHoy: "10 entregas hoy",
        estado: "En Ruta",
        estadoColor: Colors.blue,
        pedidoActual: "#1235 - Pedro Sánchez",
        direccion: "Av. Juárez 456",
        tiempo: "Hace 2 min",
      ),
      Repartidor(
        nombre: "Roberto",
        entregasHoy: "8 entregas",
        estado: "Disponible",
        estadoColor: Colors.grey,
        pedidoActual: "Base de operaciones",
        direccion: "Base",
        tiempo: "Hace 5 min",
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSystemStatus(),
            const SizedBox(height: 15),
            _buildStats(),
            const SizedBox(height: 20),
            _buildDriversList(repartidores),
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
            "Monitoreo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Estado actual de repartidores",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 10),
              SizedBox(width: 8),
              Text("Sistema activo"),
            ],
          ),
          Text("09:27:18 a.m."),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: const [
          Expanded(child: _StatBox("3", "En Ruta", Icons.local_shipping, Colors.blue)),
          SizedBox(width: 10),
          Expanded(child: _StatBox("5", "Activos", Icons.inventory, Colors.orange)),
          SizedBox(width: 10),
          Expanded(child: _StatBox("39", "Hoy", Icons.check_circle, Colors.green)),
        ],
      ),
    );
  }

  Widget _buildDriversList(List<Repartidor> repartidores) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Estado de Repartidores",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        ...repartidores.map((r) => _driverCard(r)).toList(),
      ],
    );
  }

  Widget _driverCard(Repartidor r) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryBlue,
                child: Text(r.nombre[0]),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      r.entregasHoy,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: r.estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.estado,
                  style: TextStyle(color: r.estadoColor),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pedido Actual:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(r.pedidoActual),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 14, color: Colors.red),
                  const SizedBox(width: 5),
                  Text(r.direccion),
                ],
              ),
              Text(
                r.tiempo,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}