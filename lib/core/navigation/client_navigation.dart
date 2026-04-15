import 'package:flutter/material.dart';
import '../../features/client/home/home_screen.dart';
import '../../features/client/orders/order_screen.dart';
import '../../features/client/history/history_screen.dart';
import '../../features/client/profile/profile_screen.dart';

class Usuario {
  final String nombre;
  final String email;
  final String telefono;
  final String direccion;

  Usuario({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.direccion,
  });
}

class ClientNavigation extends StatefulWidget {
  final Usuario usuario;

  const ClientNavigation({
    super.key,
    required this.usuario,
  });

  @override
  State<ClientNavigation> createState() => _ClientNavigationState();
}

class _ClientNavigationState extends State<ClientNavigation> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final usuario = widget.usuario;

    final screens = [
      HomeScreen(
        onNavigate: changeTab,
        usuario: usuario,
      ),

      OrderScreen(
        usuario: usuario,
      ),

      HistoryScreen(
        usuario: usuario,
      ),

      ProfileScreen(
        usuario: usuario,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: changeTab,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Pedido",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}