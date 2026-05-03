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
  Map<String, Usuario> usuarios = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// =========================
  /// LOAD DATA
  /// =========================
  Future<void> _loadData() async {
    try {
      final pedidosData = await _adminService.getPedidosActivos();

      final Map<String, Usuario> usuariosTemp = {};

      for (var p in pedidosData) {
        if (!usuariosTemp.containsKey(p.clienteId)) {
          final user = await _adminService.getUsuarioById(p.clienteId);
          if (user != null) usuariosTemp[p.clienteId] = user;
        }

        if (p.repartidorId != null &&
            !usuariosTemp.containsKey(p.repartidorId)) {
          final user = await _adminService.getUsuarioById(p.repartidorId!);
          if (user != null) usuariosTemp[p.repartidorId!] = user;
        }
      }

      if (!mounted) return;

      setState(() {
        pedidos = pedidosData;
        usuarios = usuariosTemp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Orders error: $e");
      setState(() => isLoading = false);
    }
  }

  /// =========================
  /// FILTRO
  /// =========================
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

  /// =========================
  /// BUILD
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false, // 🔥 elimina stretch
              ),
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildHeader(context),
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

  /// =========================
  /// HEADER
  /// =========================
  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: top + 20, left: 20, right: 20, bottom: 30),
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

  /// =========================
  /// SEARCH
  /// =========================
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

  /// =========================
  /// FILTERS
  /// =========================
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

  /// =========================
  /// ORDERS LIST
  /// =========================
  Widget _buildOrders() {
    final list = pedidosFiltrados;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _orderCard(list[index]);
      },
    );
  }

  /// =========================
  /// CARD
  /// =========================
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
            Text("#${p.id}", style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 5),

            Text(
              cliente?.nombre ?? "Cliente",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text("${p.cantidad} garrafones"),
            Text("\$${p.total} MXN"),

            const SizedBox(height: 5),

            Text(
              p.direccionEntrega,
              style: const TextStyle(color: Colors.grey),
            ),

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

  /// =========================
  /// ASIGNAR
  /// =========================
  Future<void> _asignar(String pedidoId) async {
    try {
      await _adminService.asignarRepartidorAutomatico(pedidoId);

      if (!mounted) return;

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
