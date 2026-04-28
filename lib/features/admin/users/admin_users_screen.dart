import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/pedido.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/admin_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:purificadora_app/data/services/auth_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService(
    PedidoService(),
    UserService(),
  );
  final UserService _userService = UserService();

  int selectedType = 0;
  int selectedTab = 0;

  List<Usuario> usuarios = [];
  bool isLoading = true;

  String _getRol() {
    const roles = ['cliente', 'repartidor', 'admin'];
    return roles[selectedTab];
  }

  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final rol = _getRol();

      final users = await _userService.getUsersByRole(rol);

      setState(() {
        usuarios = users;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Users error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

  /// HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
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
          Text("Crear nuevo usuario", style: TextStyle(color: Colors.white70)),
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
        onTap: () async {
          setState(() {
            selectedType = index;
            isLoading = true;
          });
          await _loadUsers();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
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
          _inputField("Nombre", nombreCtrl),
          const SizedBox(height: 10),
          _inputField("Teléfono", telefonoCtrl),
          const SizedBox(height: 10),
          _inputField("Correo", correoCtrl),
          const SizedBox(height: 10),
          _inputField("Dirección", direccionCtrl),
          const SizedBox(height: 10),
          _inputField("Password", passwordCtrl),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _registrarUsuario,
            child: Text("Registrar ${_getRol()}"),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarUsuario() async {
    final error = await _authService.createUserByAdmin(
      nombre: nombreCtrl.text,
      email: correoCtrl.text,
      password: passwordCtrl.text,
      telefono: telefonoCtrl.text,
      rol: _getRol(),
    );

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    _clearForm();
    await _loadUsers();
  }

  void _clearForm() {
    nombreCtrl.clear();
    telefonoCtrl.clear();
    correoCtrl.clear();
    direccionCtrl.clear();
    passwordCtrl.clear();
  }

  Widget _inputField(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(hintText: hint),
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
              "Usuarios",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        ...usuarios.map(_userCard),
      ],
    );
  }

  Widget _userCard(Usuario u) {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                u.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("${u.rol} • ${u.telefono}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }
}
