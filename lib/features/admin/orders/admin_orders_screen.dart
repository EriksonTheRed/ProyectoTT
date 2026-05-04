import 'package:flutter/material.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:purificadora_app/data/services/admin_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final PedidoService _pedidoService = PedidoService();
  final UserService _userService = UserService();
  final AdminService _adminService =
      AdminService(PedidoService(), UserService());

  List<Pedido> pedidos = [];
  Map<String, Usuario> usuariosCache = {};

  bool loading = true;

  String filtro = "todos";
  String busqueda = "";

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    final data = await _pedidoService.getPedidos();

    Map<String, Usuario> cacheTemp = {};

    for (var p in data) {
      if (!cacheTemp.containsKey(p.clienteId)) {
        final user = await _userService.getUserById(p.clienteId);
        if (user != null) cacheTemp[p.clienteId] = user;
      }

      if (p.repartidorId != null &&
          !cacheTemp.containsKey(p.repartidorId)) {
        final user = await _userService.getUserById(p.repartidorId!);
        if (user != null) cacheTemp[p.repartidorId!] = user;
      }
    }

    setState(() {
      pedidos = data;
      usuariosCache = cacheTemp;
      loading = false;
    });
  }

  List<Pedido> get pedidosFiltrados {
    return pedidos.where((p) {
      final coincideFiltro =
          filtro == "todos" ? true : p.estado.name.contains(filtro);

      final nombreCliente =
          usuariosCache[p.clienteId]?.nombre.toLowerCase() ?? "";

      return coincideFiltro && nombreCliente.contains(busqueda);
    }).toList();
  }

  /// =========================
  ///  SELECTOR DE REPARTIDOR
  /// =========================
  Future<void> asignar(String pedidoId) async {
  final repartidores =
      await _adminService.getRepartidoresActivos();

  if (repartidores.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No hay repartidores activos")),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    builder: (_) {
      return ListView(
        padding: const EdgeInsets.all(10),
        children: repartidores.map((r) {
          return ListTile(
            title: Text(r.nombre),
            leading: const Icon(Icons.delivery_dining),
            onTap: () async {
              Navigator.pop(context);

              await _adminService.asignarRepartidorManual(
                pedidoId: pedidoId,
                repartidorId: r.uid,
              );

              cargarPedidos();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Asignado a ${r.nombre}")),
              );
            },
          );
        }).toList(),
      );
    },
  );
}

  Future<void> entregar(String id) async {
    await _adminService.marcarComoEntregado(id);
    cargarPedidos();
  }

  Future<void> cancelar(String id) async {
    await _adminService.cancelarPedido(id);
    cargarPedidos();
  }

  Widget _estadoBadge(EstadoPedido estado) {
    Color color;
    String texto;

    switch (estado) {
      case EstadoPedido.pendiente:
        color = Colors.orange;
        texto = "pendiente";
        break;
      case EstadoPedido.proceso:
        color = Colors.amber;
        texto = "proceso";
        break;
      case EstadoPedido.completado:
        color = Colors.green;
        texto = "completado";
        break;
      case EstadoPedido.cancelado:
        color = Colors.red;
        texto = "cancelado";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _busqueda() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        onChanged: (v) => setState(() => busqueda = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Buscar por cliente",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _filtros() {
    return Wrap(
      spacing: 8,
      children: [
        _chip("todos"),
        _chip("pendiente"),
        _chip("proceso"),
        _chip("completado"),
        _chip("cancelado"),
      ],
    );
  }

  Widget _chip(String v) {
    return ChoiceChip(
      label: Text(v),
      selected: filtro == v,
      onSelected: (_) => setState(() => filtro = v),
    );
  }

  Widget _cardPedido(Pedido p) {
    final cliente =
        usuariosCache[p.clienteId]?.nombre ?? "Cargando...";

    final repartidor = p.repartidorId != null
        ? usuariosCache[p.repartidorId!]?.nombre
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#${p.id}",
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                _estadoBadge(p.estado),
              ],
            ),
            const SizedBox(height: 8),
            Text("Cliente: $cliente"),
            Text("\$${p.total}"),
            if (repartidor != null)
              Text("Repartidor: $repartidor",
                  style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 10),

            if (p.estado == EstadoPedido.pendiente)
              ElevatedButton(
                onPressed: () => asignar(p.id),
                child: const Text("Asignar Repartidor"),
              ),

            if (p.estado == EstadoPedido.proceso)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () => entregar(p.id),
                      child: const Text("Entregado"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () => cancelar(p.id),
                      child: const Text("Cancelar"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Pedidos")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _busqueda(),
                _filtros(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(10),
                    children:
                        pedidosFiltrados.map((p) => _cardPedido(p)).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}