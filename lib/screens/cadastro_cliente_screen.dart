import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../services/api_service.dart';
import '../models/cliente.dart';

class CadastroClienteScreen extends StatefulWidget {
  final Cliente? clienteEdicao;

  const CadastroClienteScreen({super.key, this.clienteEdicao});

  @override
  State<CadastroClienteScreen> createState() => _CadastroClienteScreenState();
}

class _CadastroClienteScreenState extends State<CadastroClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _inscricaoEstadualController = TextEditingController();

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
  );

  final _cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: { "#": RegExp(r'[0-9]') },
  );

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.clienteEdicao != null) {
      _nomeController.text = widget.clienteEdicao!.nome;
      _cpfCnpjController.text = widget.clienteEdicao!.cpfCnpj;
      _telefoneController.text = widget.clienteEdicao!.telefone ?? '';
      _emailController.text = widget.clienteEdicao!.email ?? '';
      _enderecoController.text = widget.clienteEdicao!.endereco ?? '';
      _inscricaoEstadualController.text = widget.clienteEdicao!.inscricaoEstadual ?? '';
      _cpfCnpjFormatter.formatEditUpdate(
          const TextEditingValue(text: ''),
          TextEditingValue(text: _cpfCnpjController.text)
      );
      _telefoneFormatter.formatEditUpdate(
          const TextEditingValue(text: ''),
          TextEditingValue(text: _telefoneController.text)
      );
    }
  }

  Future<void> _salvarCliente() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final String cpfCnpjLimpo = _cpfCnpjFormatter.getUnmaskedText();
      final String telefoneLimpo = _telefoneFormatter.getUnmaskedText();

      final Map<String, dynamic> dadosCliente = {
        "nome": _nomeController.text.trim(),
        "cpfCnpj": cpfCnpjLimpo.isNotEmpty ? cpfCnpjLimpo : _cpfCnpjController.text.trim(),
        "telefone": telefoneLimpo.isNotEmpty ? telefoneLimpo : _telefoneController.text.trim(),
        "email": _emailController.text.trim(),
        "endereco": _enderecoController.text.trim(),
        "inscricaoEstadual": _inscricaoEstadualController.text.trim(),
      };

      final response = widget.clienteEdicao == null
          ? await _apiService.postRequest('/clientes', dadosCliente)
          : await _apiService.putRequest('/clientes/${widget.clienteEdicao!.idCliente}', dadosCliente);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente salvo com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else if (response.statusCode == 400 || response.statusCode == 500) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar. Verifique se o documento já está cadastrado.'), backgroundColor: Colors.red),
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
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _inscricaoEstadualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.clienteEdicao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Cliente' : 'Novo Cliente', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo / Razão Social *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (value) => value == null || value.trim().isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfCnpjController,
                inputFormatters: [_cpfCnpjFormatter],
                decoration: const InputDecoration(
                    labelText: 'CPF ou CNPJ *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                    hintText: 'Apenas números'
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final unmasked = _cpfCnpjFormatter.getUnmaskedText();
                  if (unmasked.length > 11) {
                    _cpfCnpjFormatter.updateMask(mask: '##.###.###/####-##');
                  } else {
                    _cpfCnpjFormatter.updateMask(mask: '###.###.###-##');
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'O documento é obrigatório';
                  final unmasked = _cpfCnpjFormatter.getUnmaskedText();
                  if (unmasked.length < 11) return 'Documento incompleto';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _telefoneController,
                      inputFormatters: [_telefoneFormatter],
                      decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          hintText: '(00) 00000-0000'
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _inscricaoEstadualController,
                      decoration: const InputDecoration(labelText: 'Insc. Estadual', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvarCliente,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Salvar Cliente', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}