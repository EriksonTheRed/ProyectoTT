import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purificadora_app/core/navigation/admin_navigation.dart';
import 'package:purificadora_app/core/navigation/client_navigation.dart';
import 'package:purificadora_app/core/navigation/driver_navigation.dart';
import 'package:purificadora_app/data/services/auth_service.dart';
import 'package:purificadora_app/features/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();

  // Controladores actualizados según tu BD
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); // Específico para Cliente

  String _selectedRole =
      'cliente'; // Valor por defecto en minúsculas como en tu BD
  bool _isLoading = false;
  bool isPasswordHidden = true;

  void _signup() async {
    // Validación básica
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena todos los campos obligatorios'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Llamada al AuthService reacondicionado
    String? result = await _authService.signup(
      nombre: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      telefono: _phoneController.text,
      direccion: _addressController.text,
      rol: _selectedRole,
    );

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro Exitoso! Inicia sesión ahora.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrar: $result')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(child: Image.asset("assets/PruebaLogo.jpg", height: 150)),
              const Text(
                "Crear Cuenta",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nombre
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Correo
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Teléfono (Nuevo)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: isPasswordHidden,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => isPasswordHidden = !isPasswordHidden),
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown de Roles
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (value) {
                  print("CAMBIO DE ROL: $value"); //
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  DropdownMenuItem(
                    value: 'repartidor',
                    child: Text('Repartidor'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                ],
              ),

              // CAMPO CONDICIONAL: Solo aparece si es cliente
              if (_selectedRole == 'cliente') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección de Entrega',
                    hintText: 'Ej. Calle Falsa 123, Col. Centro',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: _signup,
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes cuenta? "),
                  InkWell(
                    onTap: () =>
                        Navigator.pop(context), // O pushReplacement a Login
                    child: const Text(
                      "Inicia Sesión",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
