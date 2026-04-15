import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class Usuario {
  final String nombre;
  final String rol;
  final String telefono;
  final String tiempo;

  Usuario({
    required this.nombre,
    required this.rol,
    required this.telefono,
    required this.tiempo,
  });
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  //  Tipo de usuario seleccionado (0: cliente, 1: repartidor, 2: admin)
  int selectedType = 0;

  final List<Usuario> usuarios = [
    Usuario(
      nombre: "Carmen Flores",
      rol: "Cliente",
      telefono: "333-555-1234",
      tiempo: "Hace 25 min",
    ),
    Usuario(
      nombre: "Roberto Díaz",
      rol: "Repartidor",
      telefono: "333-555-5678",
      tiempo: "Hace 1 hora",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildUserTypeSelector(),
            const SizedBox(height: 20),
            _buildForm(),
            const SizedBox(height: 20),
            _buildRecentUsers(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🔵 Encabezado
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Registro de Usuarios",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Crear nuevo usuario en el sistema",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _typeButton("Cliente", 0),
          const SizedBox(width: 10),
          _typeButton("Repartidor", 1),
          const SizedBox(width: 10),
          _typeButton("Administrador", 2),
        ],
      ),
    );
  }

  Widget _typeButton(String text, int index) {
    final isSelected = selectedType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return _card(
      Column(
        children: [
          _inputField("Nombre completo *", Icons.person),
          const SizedBox(height: 15),
          _inputField("Teléfono *", Icons.phone),
          const SizedBox(height: 15),
          _inputField("Correo Electrónico", Icons.email),
          const SizedBox(height: 15),
          _inputField("Dirección", Icons.location_on),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // 🚀 Aquí después se hará POST al backend
              },
              child: Text(
                "Registrar ${_getRoleName()}",
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔤 Nombre del rol seleccionado
  String _getRoleName() {
    switch (selectedType) {
      case 0:
        return "Cliente";
      case 1:
        return "Repartidor";
      default:
        return "Administrador";
    }
  }

  Widget _inputField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F6FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRecentUsers() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Últimos Registros",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 🔁 Lista dinámica
        ...usuarios.map((usuario) => _userCard(usuario)).toList(),
      ],
    );
  }

  /// 👤 Tarjeta de usuario (DINÁMICA)
  Widget _userCard(Usuario usuario) {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Nombre
              Text(
                usuario.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              Text("${usuario.rol} • ${usuario.telefono}"),
            ],
          ),

          Text(
            usuario.tiempo,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}