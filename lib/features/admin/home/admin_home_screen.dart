import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ResumenAdmin {
  final int clientes;
  final int repartidores;
  final int pedidosHoy;
  final double ventas;

  ResumenAdmin({
    required this.clientes,
    required this.repartidores,
    required this.pedidosHoy,
    required this.ventas,
  });
}

class Pedido {
  final String id;
  final String cliente;
  final String repartidor;
  final String estado;

  Pedido({
    required this.id,
    required this.cliente,
    required this.repartidor,
    required this.estado,
  });
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resumen = ResumenAdmin(
      clientes: 248,
      repartidores: 12,
      pedidosHoy: 47,
      ventas: 6580,
    );

    final pedidos = [
      Pedido(
        id: "#1234",
        cliente: "María González",
        repartidor: "Christian",
        estado: "En reparto",
      ),
      Pedido(
        id: "#1235",
        cliente: "Pedro Sánchez",
        repartidor: "Juan",
        estado: "Preparando",
      ),
      Pedido(
        id: "#1236",
        cliente: "Laura Torres",
        repartidor: "Miguel",
        estado: "En reparto",
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatsGrid(resumen),
            const SizedBox(height: 20),
            _buildPerformance(),
            const SizedBox(height: 20),
            _buildActiveOrders(pedidos),
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
            "Panel de Control",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Bienvenido Administrador",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ResumenAdmin resumen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.5,
        children: [
          _StatCard("Clientes", "${resumen.clientes}", Icons.people, Colors.blue),
          _StatCard("Repartidores", "${resumen.repartidores}", Icons.local_shipping, Colors.green),
          _StatCard("Pedidos Hoy", "${resumen.pedidosHoy}", Icons.inventory, Colors.orange),
          _StatCard("Total Ventas", "\$${resumen.ventas}", Icons.attach_money, Colors.black),
        ],
      ),
    );
  }

  Widget _buildPerformance() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rendimiento Semanal",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          const Text("Pedidos completados"),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: 0.9,
            color: Colors.blue,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text("324/350"),
          ),

          const SizedBox(height: 15),

          const Text("Tasa de entrega"),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: 0.96,
            color: Colors.green,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text("96%"),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrders(List<Pedido> pedidos) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Pedidos Activos",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        ...pedidos.map((p) => _orderCard(p)).toList(),
      ],
    );
  }

  /// 📦 Card dinámico
  Widget _orderCard(Pedido pedido) {
    Color color = pedido.estado == "En reparto"
        ? Colors.orange
        : Colors.blue;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(pedido.id, style: const TextStyle(color: Colors.grey)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pedido.estado,
                  style: TextStyle(color: color),
                ),
              )
            ],
          ),
          const SizedBox(height: 5),

          Text(
            pedido.cliente,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          /// 🚚 Repartidor
          Text("Repartidor: ${pedido.repartidor}"),
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}