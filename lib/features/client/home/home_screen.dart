import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../tracking/tracking_screen.dart';
import '../../../core/navigation/client_navigation.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigate;
  final Usuario usuario;

  const HomeScreen({
    super.key,
    this.onNavigate,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightBackground,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildActionCards(context),
            const SizedBox(height: 20),
            _buildCurrentOrderCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.darkBlue,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Purificadora",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),

          Text(
            "Hola,\n${usuario.nombre}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            "¿Qué deseas hacer hoy?",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _ActionCard(
            icon: Icons.shopping_cart_outlined,
            title: "Hacer Pedido",
            subtitle: "Solicita tus garrafones",
            color: Colors.blue,
            onTap: () => onNavigate?.call(1),
          ),

          const SizedBox(height: 15),

          _ActionCard(
            icon: Icons.water_drop_outlined,
            title: "Seguimiento",
            subtitle: "Rastrea tu pedido actual",
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: TrackingScreen(
                      usuario: usuario,
                    ),

                    bottomNavigationBar: BottomNavigationBar(
                      currentIndex: 0,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.grey,
                      onTap: (index) {
                        Navigator.pop(context);
                      },
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
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          _ActionCard(
            icon: Icons.access_time,
            title: "Historial",
            subtitle: "Ver pedidos anteriores",
            color: Colors.blueAccent,
            onTap: () => onNavigate?.call(2),
          ),

          const SizedBox(height: 15),

          _ActionCard(
            icon: Icons.person_outline,
            title: "Mi Perfil",
            subtitle: "Editar información",
            color: Colors.blue,
            onTap: () => onNavigate?.call(3),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F2FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pedido actual",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tienes un pedido en camino",
              style: TextStyle(color: Colors.blueAccent),
            ),
            SizedBox(height: 8),
            Text(
              "Ver seguimiento →",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}