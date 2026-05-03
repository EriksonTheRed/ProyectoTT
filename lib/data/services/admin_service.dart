import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminService {
  final PedidoService _pedidoService;
  final UserService _userService;

  AdminService(this._pedidoService, this._userService);

  /// =========================
  /// ASIGNAR REPARTIDOR A PEDIDO (AUTOMATICO
  /// =========================
  Future<void> asignarRepartidorAutomatico(String pedidoId) async {
    final repartidores = await _userService.getAvailableDeliveryUsers();
    final pedido = await _pedidoService.getPedidoById(pedidoId);

    if (pedido == null) throw Exception("Pedido no encontrado");

    if (pedido.estado != EstadoPedido.pendiente ||
        pedido.repartidorId != null) {
      throw Exception("Pedido ya no disponible");
    }

    final repartidor = repartidores.first;

    await _pedidoService.assignRepartidor(
      pedidoId: pedidoId,
      repartidorId: repartidor.uid,
    );

    await _userService.updateDeliveryAvailability(
      uid: repartidor.uid,
      isAvailable: false,
    );
  }

  /// =========================
  /// OBTENER PEDIDOS ACTIVOS
  /// =========================
  Future<List<Pedido>> getPedidosActivos() async {
    final pedidos = await _pedidoService.getPedidos();

    // 👉 NO filtrar aquí
    return pedidos;
  }

  /// =========================
  /// PEDIDOS DEL DÍA
  /// =========================
  Future<List<Pedido>> getPedidosHoy() async {
    final activos = await getPedidosActivos();

    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);

    return activos.where((p) {
      return p.fechaCreacion != null && p.fechaCreacion!.isAfter(inicioDia);
    }).toList();
  }

  /// =========================
  /// ACTIVAR / DESACTIVAR USUARIO
  /// =========================
  Future<void> setUserActivo({
    required String uid,
    required bool activo,
  }) async {
    await _userService.updateUserActiveStatus(uid: uid, isActive: activo);
  }

  /// =========================
  /// OBTENER USUARIO POR ID
  /// =========================
  Future<Usuario?> getUsuarioById(String uid) async {
    return await _userService.getUserById(uid);
  }

  /// =========================
  /// OBTENER REPARTIDORES
  /// =========================
  Future<List<Usuario>> getRepartidores() async {
    return await _userService.getDeliveryUsers();
  }

  /// =========================
  /// OBTENER REPARTIDORES DISPONIBLES
  /// =========================
  Future<List<Usuario>> getRepartidoresDisponibles() async {
    return await _userService.getAvailableDeliveryUsers();
  }

  /// =========================
  /// RESUMEN ADMIN (DASHBOARD)
  /// =========================
  Future<Map<String, dynamic>> getResumenAdmin() async {
    final clientes = await _userService.getClients();
    final repartidores = await _userService.getDeliveryUsers();

    final pedidosActivos = await getPedidosActivos();
    final pedidosHoy = await getPedidosHoy();

    double ventas = 0;

    for (var p in pedidosActivos) {
      ventas += p.total;
    }

    return {
      'clientes': clientes.length,
      'repartidores': repartidores.length,
      'pedidosHoy': pedidosHoy.length,
      'ventas': ventas,
    };
  }
}
