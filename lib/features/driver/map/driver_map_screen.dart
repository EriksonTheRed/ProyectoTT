import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
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
      /// 1. Pedido actual
      final pedidos = await _pedidoService.obtenerPedidosAsignados(
        widget.usuario.uid,
      );

      if (pedidos.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      pedido = pedidos.first;

      /// 2. Cliente
      cliente = await _userService.getUserById(pedido!.clienteId);

      /// 3. Ubicación actual
      origin = await _trackingService.getCurrentLocation();

      /// ⚠️ Aquí necesitas lat/lng del cliente
      /// TEMPORAL (puedes cambiar luego por GeoPoint)
      destination = const LatLng(19.4326, -99.1332);

      /// 4. Ruta
      final route = await _trackingService.getRoute(
        origin: origin!,
        destination: destination!,
      );

      /// 5. Markers y polyline
      markers = _trackingService.buildMarkers(
        origin: origin!,
        destination: destination!,
      );

      polylines = _trackingService.buildPolyline(route);
    } catch (e) {
      debugPrint("Error mapa: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pedido == null
          ? const Center(child: Text("No hay pedido asignado"))
          : Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),

                /// MAPA REAL
                SizedBox(
                  height: 250,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: origin!,
                      zoom: 14,
                    ),
                    markers: markers,
                    polylines: polylines,
                  ),
                ),

                const SizedBox(height: 10),
                _buildDestinationCard(),
                const SizedBox(height: 10),
                _buildSummaryCard(),
              ],
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
