import 'package:flutter/material.dart';
import '../../features/admin/home/admin_home_screen.dart';
import '../../features/admin/users/admin_users_screen.dart';
import '../../features/admin/orders/admin_orders_screen.dart';
import '../../features/admin/monitor/admin_monitor_screen.dart';
import '../../features/admin/config/admin_config_screen.dart' as config;

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final usuarioAdmin = config.Usuario(
      nombre: "Admin Principal",
      email: "admin@purificadora.com",
    );

    final screens = [
      const AdminHomeScreen(),      
      const AdminUsersScreen(),    
      const AdminOrdersScreen(),    
      const AdminMonitorScreen(),   

      config.AdminConfigScreen(
        usuario: usuarioAdmin,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Panel",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Usuarios",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Monitor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Config",
          ),
        ],
      ),
    );
  }
}