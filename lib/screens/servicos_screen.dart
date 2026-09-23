import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/servico.dart';
import 'cadastro_servico_screen.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final ApiService _apiService = ApiService();
  List<Servico> _servicos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    try {
      final response = await _apiService.getRequest('/servicos');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _servicos = data.map((json) => Servico.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar serviços.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Erro de conexão: $e');
    }
  }

  Future<void> _excluirServico(int? idServico) async {
    if (idServico == null) return;

    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta etapa?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.deleteRequest('/servicos/$idServico');
      if (response.statusCode == 204 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excluído com sucesso!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir.'), backgroundColor: Colors.red),
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
      _carregarServicos();
    }
  }
  void _mostrarOpcoesAdicionarEtapa(Servico servicoPai) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Adicionar Etapa', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Deseja criar uma nova etapa do zero ou vincular um serviço que já existe no catálogo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selecionarEtapaExistente(servicoPai);
              },
              child: const Text('Vincular Existente', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                Navigator.pop(context);
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CadastroServicoScreen(servicoPai: servicoPai),
                  ),
                );
                if (resultado == true) {
                  setState(() => _isLoading = true);
                  _carregarServicos();
                }
              },
              child: const Text('Nova Etapa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _selecionarEtapaExistente(Servico servicoPai) {
    List<Servico> opcoes = _servicos.where((s) => s.idServico != servicoPai.idServico).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecione o Serviço'),
          content: SizedBox(
            width: double.maxFinite,
            child: opcoes.isEmpty
                ? const Text('Não há outros serviços disponíveis para vincular.')
                : ListView.builder(
              shrinkWrap: true,
              itemCount: opcoes.length,
              itemBuilder: (context, index) {
                final servicoExistente = opcoes[index];
                return ListTile(
                  leading: const Icon(Icons.build, color: Colors.blue),
                  title: Text(servicoExistente.nome),
                  subtitle: Text('R\$ ${servicoExistente.valor.toStringAsFixed(2)}'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _vincularServicoExistente(servicoPai, servicoExistente.idServico!);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')
            ),
          ],
        );
      },
    );
  }

  Future<void> _vincularServicoExistente(Servico servicoPai, int idExistente) async {
    setState(() => _isLoading = true);
    try {
      List<int> idsAtuais = servicoPai.subservicos.map((s) => s.id!).toList();

      if (idsAtuais.contains(idExistente)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta etapa já está vinculada ao serviço.'), backgroundColor: Colors.orange),
        );
        setState(() => _isLoading = false);
        return;
      }

      idsAtuais.add(idExistente);
      final response = await _apiService.putListRequest('/servicos/${servicoPai.idServico}/sub-servicos', idsAtuais);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Etapa vinculada com sucesso!'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao vincular etapa.'), backgroundColor: Colors.red),
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
      _carregarServicos();
    }
  }

  void _navegarParaEdicao(Servico servico) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroServicoScreen(servicoEdicao: servico)),
    );
    if (resultado == true) {
      setState(() => _isLoading = true);
      _carregarServicos();
    }
  }

  Widget _construirListaFilhos(List<Subservico> filhos, double recuoEsquerdo) {
    if (filhos.isEmpty) return const SizedBox.shrink();
    return Column(
      children: filhos.map((sub) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: recuoEsquerdo, right: 16.0, top: 2, bottom: 2),
              child: Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: ListTile(
                  leading: const Icon(Icons.subdirectory_arrow_right, color: Colors.blue, size: 20),
                  title: Text(
                    sub.descricao,
                    style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  dense: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _excluirServico(sub.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (sub.subservicos.isNotEmpty)
              _construirListaFilhos(sub.subservicos, recuoEsquerdo + 24.0),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Serviços', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servicos.isEmpty
          ? const Center(child: Text('Nenhum serviço cadastrado.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _servicos.length,
        itemBuilder: (context, index) {
          final servico = _servicos[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.build, color: Colors.white),
              ),
              title: Text(
                servico.nome,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                'R\$ ${servico.valor.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              children: [
                _construirListaFilhos(servico.subservicos, 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => _mostrarOpcoesAdicionarEtapa(servico),
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        label: const Text('Adicionar Etapa', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Editar Serviço',
                        onPressed: () => _navegarParaEdicao(servico),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir Serviço',
                        onPressed: () => _excluirServico(servico.idServico),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CadastroServicoScreen()),
          );
          if (resultado == true) {
            setState(() => _isLoading = true);
            _carregarServicos();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}