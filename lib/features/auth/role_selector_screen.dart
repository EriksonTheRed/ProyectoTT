import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/client_navigation.dart';
import '../../core/navigation/driver_navigation.dart';
import '../../core/navigation/admin_navigation.dart';

// 🔥 IMPORTAMOS MODELOS (los que ya usas)
import '../../core/navigation/client_navigation.dart' show Usuario;
import '../../features/driver/profile/driver_profile_screen.dart' show Repartidor;

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Purificadora",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Selecciona tu tipo de usuario",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            /// 👤 CLIENTE
            _roleButton(
              context,
              icon: Icons.person,
              text: "Cliente",
              onTap: () {
                final usuario = Usuario(
                  nombre: "Christian",
                  email: "cliente@email.com",
                  telefono: "+52 123 456 7890",
                  direccion: "Calle Principal 456",
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientNavigation(usuario: usuario),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            /// 🚚 REPARTIDOR
            _roleButton(
              context,
              icon: Icons.local_shipping,
              text: "Repartidor",
              onTap: () {
                final repartidor = Repartidor(
                  nombre: "Erick Castañeda",
                  telefono: "+52 123 456 7890",
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverNavigation(repartidor: repartidor),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            /// 🛠 ADMIN
            _roleButton(
              context,
              icon: Icons.admin_panel_settings,
              text: "Administrador",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminNavigation(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
      ),
    );
  }
}