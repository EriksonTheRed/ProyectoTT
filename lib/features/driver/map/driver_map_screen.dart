import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../profile/driver_profile_screen.dart';

class Cliente {
  final String nombre;
  final String telefono;
  final String direccion;

  Cliente({
    required this.nombre,
    required this.telefono,
    required this.direccion,
  });
}

class Pedido {
  final Cliente cliente;
  final int cantidad;
  final double total;
  final double distancia;
  final int tiempo;

  Pedido({
    required this.cliente,
    required this.cantidad,
    required this.total,
    required this.distancia,
    required this.tiempo,
  });
}

class DriverMapScreen extends StatelessWidget {
  final Repartidor repartidor;

  const DriverMapScreen({
    super.key,
    required this.repartidor,
  });

  @override
  Widget build(BuildContext context) {

    final pedido = Pedido(
      cliente: Cliente(
        nombre: "Christian Acosta",
        telefono: "555-1234-5678",
        direccion: "Calle Principal 123, Col. Centro",
      ),
      cantidad: 4,
      total: 140,
      distancia: 2.5,
      tiempo: 8,
    );

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMapCard(),
            const SizedBox(height: 20),
            _buildDestinationCard(pedido),
            const SizedBox(height: 20),
            _buildSummaryCard(pedido),
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
            "Mapa de Ruta",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Pedido en curso",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            "Aquí se mostrará el mapa",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Pedido pedido) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Destino",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          const Text("Cliente"),

          Text(
            pedido.cliente.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue),
              const SizedBox(width: 5),
              Text(
                pedido.cliente.telefono,
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 5),
              Expanded(
                child: Text(pedido.cliente.direccion),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Pedido pedido) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _card(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Garrafones"),
                Text("${pedido.cantidad} unidades"),
              ],
            ),
          ),

          const SizedBox(height: 15),

          _card(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total"),
                Text(
                  "\$${pedido.total} MXN",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  title: "Distancia",
                  value: "${pedido.distancia} km",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoBox(
                  title: "Tiempo est.",
                  value: "${pedido.tiempo} min",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.navigation),
              label: const Text("Iniciar Navegación"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
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
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}