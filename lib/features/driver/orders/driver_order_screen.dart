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
  final String fecha;
  final int cantidad;
  final double total;
  final String estado;

  Pedido({
    required this.cliente,
    required this.fecha,
    required this.cantidad,
    required this.total,
    required this.estado,
  });
}

class DriverOrderScreen extends StatelessWidget {
  final Repartidor repartidor;

  const DriverOrderScreen({
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
      fecha: "10 Nov 2025",
      cantidad: 4,
      total: 140,
      estado: "En reparto",
    );

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatus(pedido),
            const SizedBox(height: 20),
            _buildClientInfo(pedido),
            const SizedBox(height: 20),
            _buildOrderDetails(pedido),
            const SizedBox(height: 20),
            _buildNotes(),
            const SizedBox(height: 20),
            _buildButtons(pedido),
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
            "Pedido en Curso",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Detalles de entrega",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(Pedido pedido) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            pedido.estado,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientInfo(Pedido pedido) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Información del Cliente",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          const Text("Nombre"),
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

  Widget _buildOrderDetails(Pedido pedido) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detalles del Pedido",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Fecha:"),
              Text(pedido.fecha),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Garrafones:"),
              Text("${pedido.cantidad} unidades"),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:"),
              Text(
                "\$${pedido.total} MXN",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Notas del Pedido"),
          Text(
            "Agregar",
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(Pedido pedido) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check),
              label: const Text("Marcar como Entregado"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.close),
              label: const Text("Marcar como No Entregado"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
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