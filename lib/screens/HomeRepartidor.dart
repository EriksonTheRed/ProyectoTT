import 'package:flutter/material.dart';

class HomeRepartidor extends StatelessWidget {
  const HomeRepartidor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Repartidor")),
      body: const Center(child: Text("Home Repartidor")),
    );
  }
}
