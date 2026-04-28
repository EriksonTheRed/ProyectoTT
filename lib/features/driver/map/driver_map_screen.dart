import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/delivery_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:purificadora_app/data/services/tracking_service.dart';

class DriverMapScreen extends StatefulWidget {
  final Usuario usuario;

  const DriverMapScreen({super.key, required this.usuario});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  final PedidoService _pedidoService = PedidoService();
  final UserService _userService = UserService();
  final TrackingService _trackingService = TrackingService();
  final DeliveryService _deliveryService = DeliveryService(
    PedidoService(),
    UserService(),
  );

  Pedido? pedido;
  Usuario? cliente;

  LatLng? origin;
  LatLng? destination;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      /// 1. Pedido actual (correcto)
      final pedidoActual = await _deliveryService.getPedidoEnCurso(
        widget.usuario.uid,
      );

      if (pedidoActual == null) {
        setState(() => isLoading = false);
        return;
      }

      pedido = pedidoActual;

      /// 2. Cliente
      cliente = await _userService.getUserById(pedido!.clienteId);

      /// 3. Ubicación actual
      origin = await _trackingService.getCurrentLocation();

      /// ⚠️ TEMPORAL (debes usar GeoPoint después)
      destination = const LatLng(19.4326, -99.1332);

      /// 4. Ruta
      final route = await _trackingService.getRoute(
        origin: origin!,
        destination: destination!,
      );

      /// 5. Markers
      markers = _trackingService.buildMarkers(
        origin: origin!,
        destination: destination!,
      );

      /// 6. Polyline
      polylines = _trackingService.buildPolyline(route);
    } catch (e) {
      debugPrint("Error mapa: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (pedido == null) {
      return const Scaffold(body: Center(child: Text("Sin pedido activo")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: origin ?? const LatLng(19.4326, -99.1332),
          zoom: 14,
        ),
        markers: markers,
        polylines: polylines,
        myLocationEnabled: true,
      ),
    );
  }

  /// HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
      ),
      child: const Text(
        "Mapa de Ruta",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// DESTINO
  Widget _buildDestinationCard() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(cliente?.nombre ?? "-"),
          Text(cliente?.telefono ?? "-"),
          Text(pedido!.direccionEntrega),
        ],
      ),
    );
  }

  /// RESUMEN
  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Text("${pedido!.cantidad} garrafones"),
          Text("\$${pedido!.total} MXN"),
        ],
      ),
    );
  }
}
