import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'clientes_screen.dart';
import 'servicos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _fazerLogout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildMenuCard(BuildContext context, String titulo, IconData icone, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oficina APP', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _fazerLogout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(context, 'Clientes', Icons.people, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClientesScreen()),
              );
            }),
            _buildMenuCard(context, 'Estoque', Icons.inventory_2, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo de Estoque')));
            }),
            _buildMenuCard(context, 'Serviços', Icons.build, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServicosScreen()),
              );
            }),
            _buildMenuCard(context, 'Orçamentos', Icons.request_quote, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo de Orçamentos')));
            }),
            _buildMenuCard(context, 'Ordens de Serviço', Icons.assignment, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo de Ordens de Serviço')));
            }),
          ],
        ),
      ),
    );
  }
}