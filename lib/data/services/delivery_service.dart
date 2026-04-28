import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';

class DeliveryService {
  final PedidoService _pedidoService;
  final UserService _userService;

  DeliveryService(this._pedidoService, this._userService);

  /// =========================
  /// OBTENER REPARTIDOR POR ID
  /// =========================
  Future<Usuario?> getDeliveryById(String uid) async {
    final user = await _userService.getUserById(uid);

    if (user == null) return null;

    if (user.rol != 'repartidor') {
      throw Exception('El usuario no es repartidor');
    }

    return user;
  }

  /// =========================
  /// CAMBIAR DISPONIBILIDAD
  /// =========================
  Future<void> updateDisponibilidad({
    required String repartidorId,
    required bool disponible,
  }) async {
    final user = await getDeliveryById(repartidorId);

    if (user == null) {
      throw Exception('Repartidor no encontrado');
    }

    await _userService.updateDeliveryAvailability(
      uid: repartidorId,
      isAvailable: disponible,
    );
  }

  /// =========================
  /// OBTENER PEDIDOS ASIGNADOS (EN PROCESO)
  /// =========================
  Future<List<Pedido>> getPedidosAsignados(String repartidorId) async {
    final pedidos = await _pedidoService.getPedidosByRepartidor(repartidorId);

    return pedidos.where((p) => p.estado == EstadoPedido.proceso).toList();
  }

  /// =========================
  /// OBTENER PEDIDO EN CURSO
  /// =========================
  Future<Pedido?> getPedidoEnCurso(String repartidorId) async {
    final pedidos = await getPedidosAsignados(repartidorId);

    if (pedidos.isEmpty) return null;

    /// Regla: solo uno activo
    return pedidos.first;
  }

  /// =========================
  /// MARCAR COMO ENTREGADO
  /// =========================
  Future<void> marcarComoEntregado({
    required String pedidoId,
    required String repartidorId,
  }) async {
    final pedido = await _pedidoService.getPedidoById(pedidoId);

    if (pedido == null) {
      throw Exception('Pedido no encontrado');
    }

    /// Validar propiedad
    if (pedido.repartidorId != repartidorId) {
      throw Exception('No autorizado');
    }

    /// Delegar transición al core
    await _pedidoService.updateEstado(
      pedidoId: pedidoId,
      nuevoEstado: EstadoPedido.completado,
    );

    /// Liberar repartidor
    await _userService.updateDeliveryAvailability(
      uid: repartidorId,
      isAvailable: true,
    );
  }

  /// =========================
  /// MARCAR COMO NO ENTREGADO
  /// =========================
  Future<void> marcarComoNoEntregado({
    required String pedidoId,
    required String repartidorId,
  }) async {
    final pedido = await _pedidoService.getPedidoById(pedidoId);

    if (pedido == null) {
      throw Exception('Pedido no encontrado');
    }

    /// Validar propiedad
    if (pedido.repartidorId != repartidorId) {
      throw Exception('No autorizado');
    }

    /// Cancelar pedido (transición válida)
    await _pedidoService.updateEstado(
      pedidoId: pedidoId,
      nuevoEstado: EstadoPedido.cancelado,
    );

    /// Liberar repartidor
    await _userService.updateDeliveryAvailability(
      uid: repartidorId,
      isAvailable: true,
    );
  }
}
