import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class Pedido {
  final String id;
  final String cliente;
  final int cantidad;
  final double total;
  final String fecha;
  final String direccion;
  final String estado;
  final String? repartidor;

  Pedido({
    required this.id,
    required this.cliente,
    required this.cantidad,
    required this.total,
    required this.fecha,
    required this.direccion,
    required this.estado,
    this.repartidor,
  });
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  int selectedFilter = 0;

  final filters = ["Todos", "Pendiente", "Asignado", "Entregado"];

  final List<Pedido> pedidos = [
    Pedido(
      id: "#1234",
      cliente: "María González",
      cantidad: 4,
      total: 140,
      fecha: "18 Nov 2025",
      direccion: "Calle Principal 123",
      estado: "En reparto",
      repartidor: "Christian",
    ),
    Pedido(
      id: "#1236",
      cliente: "Laura Torres",
      cantidad: 2,
      total: 70,
      fecha: "18 Nov 2025",
      direccion: "Col. Centro 789",
      estado: "Pendiente",
    ),
    Pedido(
      id: "#1237",
      cliente: "Carlos Ramírez",
      cantidad: 3,
      total: 105,
      fecha: "17 Nov 2025",
      direccion: "Calle 5 de Mayo 321",
      estado: "Entregado",
      repartidor: "Miguel",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pedidosFiltrados = selectedFilter == 0
        ? pedidos
        : pedidos
            .where((p) => p.estado == filters[selectedFilter])
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearch(),
            const SizedBox(height: 15),
            _buildFilters(),
            const SizedBox(height: 15),
            _buildOrders(pedidosFiltrados),
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
            "Gestión de Pedidos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Administra y asigna pedidos",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Buscar por cliente o ID",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final isSelected = selectedFilter == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrders(List<Pedido> pedidos) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "${pedidos.length} pedidos",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 10),

        ...pedidos.map((pedido) => _orderCard(pedido)).toList(),
      ],
    );
  }

  Widget _orderCard(Pedido pedido) {
    Color statusColor;

    switch (pedido.estado) {
      case "Pendiente":
        statusColor = Colors.grey;
        break;
      case "En reparto":
        statusColor = Colors.orange;
        break;
      case "Entregado":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ID + estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pedido.id, style: const TextStyle(color: Colors.grey)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pedido.estado,
                    style: TextStyle(color: statusColor),
                  ),
                )
              ],
            ),

            const SizedBox(height: 6),

            /// 👤 Cliente
            Text(
              pedido.cliente,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.water_drop, size: 16),
                const SizedBox(width: 5),
                Text("${pedido.cantidad} garrafones"),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.attach_money, size: 16),
                const SizedBox(width: 5),
                Text("\$${pedido.total} MXN"),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 5),
                Text(pedido.fecha),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.red),
                const SizedBox(width: 5),
                Expanded(child: Text(pedido.direccion)),
              ],
            ),

            const SizedBox(height: 10),

            if (pedido.estado == "Pendiente")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                  onPressed: () {
                  },
                  child: const Text("Asignar Repartidor"),
                ),
              )
            else if (pedido.repartidor != null)
              Text(
                "Repartidor: ${pedido.repartidor}",
                style: const TextStyle(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}