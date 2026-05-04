import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminService {
  final PedidoService _pedidoService;
  final UserService _userService;

  AdminService(this._pedidoService, this._userService);

  /// =========================
  /// ASIGNAR REPARTIDOR MANUAL
  /// =========================
  Future<void> asignarRepartidorManual({
    required String pedidoId,
    required String repartidorId,
  }) async {
    await _pedidoService.assignRepartidor(
      pedidoId: pedidoId,
      repartidorId: repartidorId,
    );

  }

  /// =========================
  /// CAMBIAR ESTADOS
  /// =========================
  Future<void> marcarComoEntregado(String pedidoId) async {
    await _pedidoService.updateEstado(
      pedidoId: pedidoId,
      nuevoEstado: EstadoPedido.completado,
    );
  }

  Future<void> cancelarPedido(String pedidoId) async {
    await _pedidoService.updateEstado(
      pedidoId: pedidoId,
      nuevoEstado: EstadoPedido.cancelado,
    );
  }

  /// =========================
  /// OBTENER PEDIDOS
  /// =========================
  Future<List<Pedido>> getPedidosActivos() async {
    return await _pedidoService.getPedidos();
  }

  /// =========================
  /// PEDIDOS COMPLETADOS HOY
  /// =========================
  Future<List<Pedido>> getPedidosHoy() async {
    final pedidos = await getPedidosActivos();

    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);

    return pedidos.where((p) {
      return p.estado == EstadoPedido.completado &&
          p.fechaCreacion != null &&
          p.fechaCreacion!.isAfter(inicioDia);
    }).toList();
  }

  /// =========================
  /// USUARIOS
  /// =========================

  /// Activar / desactivar repartidor
  Future<void> setUserActivo({
    required String uid,
    required bool activo,
  }) async {
    await _userService.updateUserActiveStatus(
      uid: uid,
      isActive: activo,
    );
  }

  /// Obtener usuario por ID (IMPORTANTE para Home)
  Future<Usuario?> getUsuarioById(String uid) async {
    return await _userService.getUserById(uid);
  }

  /// Todos los repartidores
  Future<List<Usuario>> getRepartidores() async {
    return await _userService.getDeliveryUsers();
  }

  Future<List<Usuario>> getRepartidoresActivos() async {
    final reps = await _userService.getDeliveryUsers();
    return reps.where((r) => r.activo == true).toList();
  }

  /// =========================
  /// DASHBOARD
  /// =========================
  Future<Map<String, dynamic>> getResumenAdmin() async {
    final clientes = await _userService.getClients();

    final repartidoresActivos = await getRepartidoresActivos();

    final pedidos = await getPedidosActivos();
    final pedidosHoy = await getPedidosHoy();

    double ventas = 0;

    for (var p in pedidos) {
      if (p.estado == EstadoPedido.completado) {
        ventas += p.total;
      }
    }

    return {
      'clientes': clientes.length,
      'repartidores': repartidoresActivos.length,
      'pedidosHoy': pedidosHoy.length,
      'ventas': ventas,
    };
  }
}