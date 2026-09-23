import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/servico.dart';

class CadastroServicoScreen extends StatefulWidget {
  final Servico? servicoPai;
  final Servico? servicoEdicao;

  const CadastroServicoScreen({super.key, this.servicoPai, this.servicoEdicao});

  @override
  State<CadastroServicoScreen> createState() => _CadastroServicoScreenState();
}

class _CadastroServicoScreenState extends State<CadastroServicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.servicoEdicao != null) {
      _nomeController.text = widget.servicoEdicao!.nome;
      _descricaoController.text = widget.servicoEdicao!.descricao;
      _valorController.text = widget.servicoEdicao!.valor.toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String valorTexto = _valorController.text.replaceAll(',', '.');
      double valor = double.tryParse(valorTexto) ?? 0.0;

      final Map<String, dynamic> body = {
        "nome": _nomeController.text,
        "descricao": _descricaoController.text,
        "valor": valor,
        "idsSubServicos": widget.servicoEdicao != null
            ? widget.servicoEdicao!.subservicos.map((s) => s.id).toList()
            : []
      };

      http.Response response;

      if (widget.servicoEdicao != null) {
        response = await _apiService.putRequest('/servicos/${widget.servicoEdicao!.idServico}', body);
      } else {
        response = await _apiService.postRequest('/servicos', body);
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (widget.servicoPai != null && widget.servicoEdicao == null) {
          final novoServicoJson = jsonDecode(response.body);
          int idNovoServico = novoServicoJson['idServico'] ?? novoServicoJson['id'];
          List<int> idsAtuaisDoPai = widget.servicoPai!.subservicos.map((s) => s.id!).toList();
          idsAtuaisDoPai.add(idNovoServico);

          await _apiService.putListRequest(
              '/servicos/${widget.servicoPai!.idServico}/sub-servicos',
              idsAtuaisDoPai
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Salvo com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar o serviço.'), backgroundColor: Colors.red),
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
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSub = widget.servicoPai != null;
    final bool isEdit = widget.servicoEdicao != null;

    final String titulo = isEdit
        ? 'Editar Serviço'
        : (isSub ? 'Nova Etapa' : 'Novo Serviço');

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (isSub && !isEdit)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Adicionando etapa em:\n${widget.servicoPai!.nome}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: (isSub && !isEdit) ? 'Nome da Etapa' : 'Nome do Serviço',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.build),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'O nome é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'O valor é obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvarServico,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}