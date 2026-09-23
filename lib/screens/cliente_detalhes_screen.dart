import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/api_service.dart';
import '../widgets/modal_cadastro_veiculo.dart';

class ClienteDetalhesScreen extends StatefulWidget {
  final Cliente cliente;

  const ClienteDetalhesScreen({super.key, required this.cliente});

  @override
  State<ClienteDetalhesScreen> createState() => _ClienteDetalhesScreenState();
}

class _ClienteDetalhesScreenState extends State<ClienteDetalhesScreen> {
  late Cliente _clienteAtual;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clienteAtual = widget.cliente;
    _recarregarCliente();
  }


  Future<void> _recarregarCliente() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().getRequest('/clientes/${_clienteAtual.idCliente}');
      if (response.statusCode == 200) {
        setState(() {
          _clienteAtual = Cliente.fromJson(jsonDecode(response.body));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao recarregar dados do cliente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _abrirModalCadastroVeiculo() async {
    final bool? recarregar = await showDialog<bool>(
      context: context,
      builder: (context) => ModalCadastroVeiculo(idCliente: _clienteAtual.idCliente!),
    );

    if (recarregar == true) {
      _recarregarCliente();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_clienteAtual.nome, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informações Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.badge, 'CPF/CNPJ', _clienteAtual.cpfCnpj),
                    _buildInfoRow(Icons.phone, 'Telefone', _clienteAtual.telefone ?? 'Não informado'),
                    _buildInfoRow(Icons.email, 'Email', _clienteAtual.email ?? 'Não informado'),
                    _buildInfoRow(Icons.location_on, 'Endereço', _clienteAtual.endereco ?? 'Não informado'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cabeçalho de Veículos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Veículos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _abrirModalCadastroVeiculo,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Adicionar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _clienteAtual.veiculos.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Nenhum veículo vinculado.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _clienteAtual.veiculos.length,
              itemBuilder: (context, index) {
                final veiculo = _clienteAtual.veiculos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.directions_car, color: Colors.white),
                    ),
                    title: Text('${veiculo.marca} ${veiculo.modelo} (${veiculo.ano})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Placa: ${veiculo.placa} | Cor: ${veiculo.cor ?? "N/A"}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Função para deletar veículo a ser implementada
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}