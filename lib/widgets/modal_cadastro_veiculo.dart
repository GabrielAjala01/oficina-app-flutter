import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/veiculo.dart';

class ModalCadastroVeiculo extends StatefulWidget {
  final int idCliente;

  const ModalCadastroVeiculo({super.key, required this.idCliente});

  @override
  State<ModalCadastroVeiculo> createState() => _ModalCadastroVeiculoState();
}

class _ModalCadastroVeiculoState extends State<ModalCadastroVeiculo> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _corController = TextEditingController();

  bool _isSaving = false;

  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final veiculo = Veiculo(
        placa: _placaController.text.trim(),
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: int.parse(_anoController.text.trim()),
        cor: _corController.text.trim(),
        idCliente: widget.idCliente,
      );

      final response = await _apiService.postRequest(
        '/veiculos',
        veiculo.toJson(),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veículo vinculado com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Retorna true para recarregar a tela do cliente
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao cadastrar veículo.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _corController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Veículo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => value == null || value.trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marcaController,
                      decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modeloController,
                      decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _anoController,
                      decoration: const InputDecoration(labelText: 'Ano', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Obrigatório';
                        int? ano = int.tryParse(value);
                        if (ano == null || ano < 1900 || ano > DateTime.now().year + 1) return 'Ano inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _corController,
                      decoration: const InputDecoration(labelText: 'Cor (Opcional)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _salvarVeiculo,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Salvar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}