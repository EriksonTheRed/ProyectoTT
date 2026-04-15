import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/client_navigation.dart';

class Repartidor {
  final String nombre;
  final String telefono;

  Repartidor({
    required this.nombre,
    required this.telefono,
  });
}

class PedidoTracking {
  final String id;
  final String estado;
  final double progreso;
  final int cantidad;
  final double total;
  final String direccion;
  final Repartidor repartidor;

  PedidoTracking({
    required this.id,
    required this.estado,
    required this.progreso,
    required this.cantidad,
    required this.total,
    required this.direccion,
    required this.repartidor,
  });
}

class TrackingScreen extends StatelessWidget {
  final Usuario usuario;

  const TrackingScreen({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {

    final pedido = PedidoTracking(
      id: "PED-1234",
      estado: "En reparto",
      progreso: 0.7,
      cantidad: 3,
      total: 105,
      direccion: usuario.direccion,
      repartidor: Repartidor(
        nombre: "Erick Castañeda",
        telefono: "+52 123 456 7890",
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(pedido),
            const SizedBox(height: 20),
            _buildStatusCard(pedido),
            const SizedBox(height: 20),
            _buildTimelineCard(),
            const SizedBox(height: 20),
            _buildDriverCard(pedido),
            const SizedBox(height: 20),
            _buildDetailsCard(pedido),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PedidoTracking pedido) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Seguimiento de Pedido",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text("Pedido", style: TextStyle(color: Colors.white70)),
          Text(
            "#${pedido.id}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(PedidoTracking pedido) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryBlue,
              AppTheme.darkBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  pedido.estado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Tu pedido está en camino",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: pedido.progreso,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Estado del pedido",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _TimelineItem(Icons.check_circle, Colors.green, "Pedido recibido", "10:30"),
          _TimelineItem(Icons.local_shipping, Colors.blue, "En reparto", "11:00"),
          _TimelineItem(Icons.home, Colors.grey, "Entregado", "11:30"),
        ],
      ),
    );
  }

  Widget _buildDriverCard(PedidoTracking pedido) {
    return _cardWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Repartidor", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(pedido.repartidor.nombre),
              const SizedBox(height: 4),
              Text(
                pedido.repartidor.telefono,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.phone),
            label: const Text("Llamar"),
          )
        ],
      ),
    );
  }

  Widget _buildDetailsCard(PedidoTracking pedido) {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Detalles del pedido", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${pedido.cantidad} Garrafones"),
              Text(
                "\$${pedido.total} MXN",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text("Dirección de entrega", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),

          Text(
            pedido.direccion,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _cardWrapper({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String time;

  const _TimelineItem(this.icon, this.color, this.title, this.time);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(time, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}