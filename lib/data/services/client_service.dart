import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';

class ClientService {
  final PedidoService _pedidoService;

  ClientService(this._pedidoService);

  /// =========================
  /// CREAR PEDIDO (CLIENTE)
  /// =========================
  Future<void> crearPedido({
    required String clienteId,
    required String direccionEntrega,
    required String telefono,
    required int cantidad,
    required double total,
    required dynamic ubicacion,
  }) async {
    await _pedidoService.createPedido(
      clienteId: clienteId,
      direccionEntrega: direccionEntrega,
      telefono: telefono,
      cantidad: cantidad,
      total: total,
      ubicacion: ubicacion,
    );
  }

  /// =========================
  /// OBTENER PEDIDOS DEL CLIENTE
  /// =========================
  Future<List<Pedido>> getMyPedidos(String clienteId) async {
    return await _pedidoService.getPedidosByCliente(clienteId);
  }

  /// =========================
  /// VER ESTADO DE UN PEDIDO
  /// =========================
  Future<EstadoPedido> getPedidoStatus({
    required String pedidoId,
    required String clienteId,
  }) async {
    final pedido = await _pedidoService.getPedidoById(pedidoId);

    if (pedido == null) {
      throw Exception('Pedido no encontrado');
    }

    if (pedido.clienteId != clienteId) {
      throw Exception('No autorizado');
    }

    return pedido.estado;
  }

  /// =========================
  /// CANCELAR PEDIDO
  /// =========================
  Future<void> cancelarPedido({
    required String pedidoId,
    required String clienteId,
  }) async {
    final pedido = await _pedidoService.getPedidoById(pedidoId);

    if (pedido == null) {
      throw Exception('Pedido no encontrado');
    }

    /// Validar que el pedido pertenece al cliente
    if (pedido.clienteId != clienteId) {
      throw Exception('No autorizado');
    }

    /// Delegar transición al core
    await _pedidoService.updateEstado(
      pedidoId: pedidoId,
      nuevoEstado: EstadoPedido.cancelado,
    );
  }
}
