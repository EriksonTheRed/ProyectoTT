import 'package:flutter/material.dart';
import '../../features/client/home/home_screen.dart';
import '../../features/client/orders/order_screen.dart';
import '../../features/client/history/history_screen.dart';
import '../../features/client/profile/profile_screen.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/features/client/tracking/tracking_screen.dart';

class ClientNavigation extends StatefulWidget {
  final Usuario usuario;

  const ClientNavigation({super.key, required this.usuario});

  @override
  State<ClientNavigation> createState() => _ClientNavigationState();
}

class _ClientNavigationState extends State<ClientNavigation> {
  int currentIndex = 0;

  // 🔥 Estado para tracking
  Pedido? pedidoTracking;

  /// =========================
  /// CONTROL DE NAVEGACIÓN
  /// =========================
  void changeTab(int index, {Pedido? pedido}) {
    setState(() {
      if (pedido != null) {
        // 👉 Activar pantalla de tracking
        pedidoTracking = pedido;
      } else {
        // 👉 Navegación normal
        pedidoTracking = null;
        currentIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    /// =========================
    /// BODY DINÁMICO
    /// =========================
    Widget body;

    if (pedidoTracking != null) {
      body = TrackingScreen(
        usuario: usuario,
        pedido: pedidoTracking!,
        onNavigate: changeTab,
      );
    } else {
      body = IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(onNavigate: changeTab, usuario: usuario),
          OrderScreen(usuario: usuario),
          HistoryScreen(usuario: usuario),
          ProfileScreen(usuario: usuario),
        ],
      );
    }

    return Scaffold(
      body: body,

      /// =========================
      /// BOTTOM NAVIGATION
      /// =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => changeTab(index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Pedido",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Historial",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
