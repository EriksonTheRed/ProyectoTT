import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:purificadora_app/domain/models/usuario.dart';
import 'package:purificadora_app/data/services/admin_service.dart';
import 'package:purificadora_app/data/services/pedido_service.dart';
import 'package:purificadora_app/data/services/user_service.dart';
import 'package:purificadora_app/data/services/auth_service.dart';
import 'package:purificadora_app/features/auth/login_screen.dart';

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

  List<Usuario> usuarios = [];
  bool isLoading = true;

  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String _getRol() {
    const roles = ['cliente', 'repartidor', 'admin'];
    return roles[selectedType];
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getUsersByRole(_getRol());

      if (!mounted) return;

      setState(() {
        usuarios = users;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Users error: $e");
      setState(() => isLoading = false);
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> _logout() async {
    try {
      await _authService.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al cerrar sesión")));
    }
  }

  /// =========================
  /// BUILD
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildUserTypeSelector(),
                    const SizedBox(height: 20),
                    _buildForm(),
                    const SizedBox(height: 20),
                    _buildUsersList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  /// =========================
  /// HEADER
  /// =========================
  Widget _buildHeader() {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: top + 20, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
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
              Text(
                "Crear nuevo usuario",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// SELECTOR
  /// =========================
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          setState(() {
            selectedType = index;
            isLoading = true;
          });
          await _loadUsers();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(12),
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

  /// =========================
  /// FORM
  /// =========================
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _registrarUsuario,
              child: Text("Registrar ${_getRol()}"),
            ),
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

  /// =========================
  /// USERS LIST
  /// =========================
  Widget _buildUsersList() {
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

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            return _userCard(usuarios[index]);
          },
        ),
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

  /// =========================
  /// CARD BASE
  /// =========================
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
