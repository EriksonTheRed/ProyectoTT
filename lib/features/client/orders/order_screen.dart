import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/client_navigation.dart';

class Producto {
  final String nombre;
  final String descripcion;
  final double precio;

  Producto({
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });
}

class OrderScreen extends StatefulWidget {
  final Usuario usuario; 

  const OrderScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int quantity = 1;

  final producto = Producto(
    nombre: "Garrafón de Agua",
    descripcion: "19 litros de agua purificada",
    precio: 35,
  );

  @override
  Widget build(BuildContext context) {
    double total = quantity * producto.precio;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text("Hacer Pedido"),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _productCard(),
            const SizedBox(height: 20),
            _addressCard(),
            const SizedBox(height: 20),
            _summaryCard(total),
            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _confirmButton(),
      ),
    );
  }

  Widget _productCard() {
    return _cardContainer(
      Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      producto.descripcion,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$${producto.precio} MXN",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text("Cantidad de garrafones"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(
                      icon: Icons.remove,
                      onTap: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                      filled: false,
                    ),
                    const SizedBox(width: 25),
                    Text(
                      "$quantity",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 25),
                    _circleButton(
                      icon: Icons.add,
                      onTap: () {
                        setState(() => quantity++);
                      },
                      filled: true,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _addressCard() {
    return _cardContainer(
      Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dirección de entrega",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                Text(
                  widget.usuario.direccion,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(double total) {
    return _cardContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen del pedido",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Garrafones"),
              Text("\$${(quantity * producto.precio).toStringAsFixed(0)} MXN"),
            ],
          ),

          const SizedBox(height: 5),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Envío"),
              Text("Gratis", style: TextStyle(color: Colors.green)),
            ],
          ),

          const Divider(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${total.toStringAsFixed(0)} MXN",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // enviarPedido(widget.usuario, quantity, total)
        },
        icon: const Icon(Icons.water_drop),
        label: const Text("Confirmar Pedido"),
      ),
    );
  }

  Widget _cardContainer(Widget child) {
    return Container(
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
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: filled ? AppTheme.primaryBlue : Colors.transparent,
          shape: BoxShape.circle,
          border: filled
              ? null
              : Border.all(color: AppTheme.primaryBlue),
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : AppTheme.primaryBlue,
        ),
      ),
    );
  }
}