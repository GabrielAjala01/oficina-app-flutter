import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cliente.dart';
import '../screens/cliente_detalhes_screen.dart';
import 'cadastro_cliente_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ApiService _apiService = ApiService();
  List<Cliente> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    try {
      final response = await _apiService.getRequest('/clientes');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _clientes = data.map((json) => Cliente.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar clientes do servidor.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Erro de conexão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Clientes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clientes.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _clientes.length,
        itemBuilder: (context, index) {
          final cliente = _clientes[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(cliente.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('CPF/CNPJ: ${cliente.cpfCnpj}\nTel: ${cliente.telefone ?? "Não informado"}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClienteDetalhesScreen(cliente: cliente),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? recarregar = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroClienteScreen(),
            ),
          );
          if (recarregar == true) {
            setState(() => _isLoading = true);
            _carregarClientes();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}