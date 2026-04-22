import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purificadora_app/core/navigation/admin_navigation.dart';
import 'package:purificadora_app/core/navigation/client_navigation.dart';
import 'package:purificadora_app/core/navigation/driver_navigation.dart';
import 'package:purificadora_app/data/services/auth_service.dart';
import 'package:purificadora_app/features/auth/signup_screen.dart';
import 'package:purificadora_app/domain/models/usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool isPasswordHidden = true; // Control para mostrar/ocultar contraseña

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa correo y contraseña')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final usuario = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (usuario == null) {
        throw Exception("Error desconocido");
      }

      // 🔥 Redirección directa usando modelo
      switch (usuario.rol) {
        case 'admin':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminNavigation(usuario: usuario),
            ),
          );
          break;

        case 'repartidor':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DriverNavigation(usuario: usuario),
            ),
          );
          break;

        case 'cliente':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ClientNavigation(usuario: usuario),
            ),
          );
          break;

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rol desconocido'),
              backgroundColor: Colors.redAccent,
            ),
          );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            // Evita errores de overflow con el teclado
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("assets/PruebaLogo.jpg", height: 200),
                const SizedBox(height: 30),
                const Text(
                  "Bienvenido",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
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
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón de Login
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),

                const SizedBox(height: 25),

                // Link a Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No tienes cuenta? ",
                      style: TextStyle(fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Regístrate aquí",
                        style: TextStyle(
                          fontSize: 16,
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
      ),
    );
  }
}
