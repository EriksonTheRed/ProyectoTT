import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/admin_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminService _adminService = AdminService(
    PedidoService(),
    UserService(),
  );

  int selectedFilter = 0;
  final filters = ["Todos", "Pendiente", "En proceso", "Completado"];

  List<Pedido> pedidos = [];
  List<Usuario> repartidores = [];
  Map<String, Usuario> usuarios = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      /// 🔹 Pedidos (activos en tu arquitectura)
      final pedidosData = await _adminService.getPedidosActivos();

      /// 🔹 Repartidores
      final reps = await _adminService.getRepartidores();

      /// 🔹 Mapear usuarios (clientes + repartidores)
      final Map<String, Usuario> usuariosTemp = {};

      for (var p in pedidosData) {
        /// Cliente
        if (!usuariosTemp.containsKey(p.clienteId)) {
          final user = await _adminService.getUsuarioById(p.clienteId);
          if (user != null) usuariosTemp[p.clienteId] = user;
        }

        /// Repartidor
        if (p.repartidorId != null &&
            !usuariosTemp.containsKey(p.repartidorId)) {
          final user = await _adminService.getUsuarioById(p.repartidorId!);
          if (user != null) usuariosTemp[p.repartidorId!] = user;
        }
      }

      setState(() {
        pedidos = pedidosData;
        repartidores = reps;
        usuarios = usuariosTemp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Orders error: $e");
      setState(() => isLoading = false);
    }
  }

  List<Pedido> get pedidosFiltrados {
    if (selectedFilter == 0) return pedidos;

    final estado = [
      null,
      EstadoPedido.pendiente,
      EstadoPedido.proceso,
      EstadoPedido.completado,
    ][selectedFilter];

    return pedidos.where((p) => p.estado == estado).toList();
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
                  _buildSearch(),
                  const SizedBox(height: 15),
                  _buildFilters(),
                  const SizedBox(height: 15),
                  _buildOrders(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
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
          Text(
            "Administra y asigna pedidos",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Buscar por cliente o ID",
          prefixIcon: Icon(Icons.search),
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
              onTap: () => setState(() => selectedFilter = index),
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
                      color: isSelected ? Colors.white : Colors.black,
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

  Widget _buildOrders() {
    final list = pedidosFiltrados;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "${list.length} pedidos",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 10),

        ...list.map(_orderCard),
      ],
    );
  }

  Widget _orderCard(Pedido p) {
    final cliente = usuarios[p.clienteId];
    final repartidor = p.repartidorId != null
        ? usuarios[p.repartidorId!]
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("#${p.id}"),
            Text(cliente?.nombre ?? "Cliente"),
            Text("${p.cantidad} garrafones"),
            Text("\$${p.total} MXN"),
            Text(p.direccionEntrega),

            const SizedBox(height: 10),

            if (p.estado == EstadoPedido.pendiente)
              ElevatedButton(
                onPressed: () => _asignar(p.id),
                child: const Text("Asignar Repartidor"),
              )
            else if (repartidor != null)
              Text("Repartidor: ${repartidor.nombre}"),
          ],
        ),
      ),
    );
  }

  Future<void> _asignar(String pedidoId) async {
    if (repartidores.isEmpty) return;

    final rep = repartidores.first;

    await _adminService.asignarRepartidor(
      pedidoId: pedidoId,
      repartidorId: rep.uid,
    );

    _loadData();
  }
}
