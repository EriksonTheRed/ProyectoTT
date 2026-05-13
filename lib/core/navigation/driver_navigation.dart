import 'package:flutter/material.dart';
import '../../features/driver/profile/driver_profile_screen.dart';
import '../../features/driver/home/driver_home_screen.dart';
import '../../features/driver/history/driver_history_screen.dart';
import '../../features/driver/orders/driver_order_screen.dart';
import '../../features/driver/map/driver_map_screen.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class DriverNavigation extends StatefulWidget {
  final Usuario usuario;

  const DriverNavigation({super.key, required this.usuario});

  @override
  State<DriverNavigation> createState() => _DriverNavigationState();
}

class _DriverNavigationState extends State<DriverNavigation> {
  int currentIndex = 0;

  void changeTab(int index) {
    if (currentIndex == index) return;

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    final screens = [
      DriverHomeScreen(usuario: usuario),
      DriverOrderScreen(usuario: usuario),
      DriverHistoryScreen(usuario: usuario),
      DriverMapScreen(usuario: usuario),
      DriverProfileScreen(usuario: usuario),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: changeTab,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pedidos"),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Historial",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
