import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class AdminService {
  final PedidoService _pedidoService;
  final UserService _userService;

  AdminService(this._pedidoService, this._userService);

  /// =========================
  /// ASIGNAR REPARTIDOR A PEDIDO
  /// =========================
  Future<void> asignarRepartidor({
    required String pedidoId,
    required String repartidorId,
  }) async {
    final pedido = await _pedidoService.getPedidoById(pedidoId);

    if (pedido == null) {
      throw Exception('Pedido no encontrado');
    }

    /// Validar estado
    if (pedido.estado != EstadoPedido.pendiente) {
      throw Exception('El pedido no está disponible para asignación');
    }

    final repartidor = await _userService.getUserById(repartidorId);

    if (repartidor == null) {
      throw Exception('Repartidor no encontrado');
    }

    /// Validar rol
    if (repartidor.rol != 'repartidor') {
      throw Exception('El usuario no es repartidor');
    }

    /// Validar disponibilidad
    if (repartidor.disponible != true) {
      throw Exception('Repartidor no disponible');
    }

    /// Asignar pedido
    await _pedidoService.assignRepartidor(
      pedidoId: pedidoId,
      repartidorId: repartidorId,
    );

    /// Marcar repartidor como ocupado
    await _userService.updateDeliveryAvailability(
      uid: repartidorId,
      isAvailable: false,
    );
  }

  /// =========================
  /// OBTENER PEDIDOS ACTIVOS
  /// =========================
  Future<List<Pedido>> getPedidosActivos() async {
    final pendientes = await _pedidoService.getPedidosPendientes();
    final enProceso = await _getPedidosEnProceso();

    return [...pendientes, ...enProceso];
  }

  /// =========================
  /// PEDIDOS EN PROCESO
  /// =========================
  Future<List<Pedido>> _getPedidosEnProceso() async {
    final repartidores = await _userService.getDeliveryUsers();

    List<Pedido> pedidos = [];

    for (var r in repartidores) {
      final pedidosRepartidor = await _pedidoService.getPedidosByRepartidor(
        r.uid,
      );

      pedidos.addAll(
        pedidosRepartidor.where((p) => p.estado == EstadoPedido.proceso),
      );
    }

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
