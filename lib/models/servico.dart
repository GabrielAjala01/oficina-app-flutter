class Subservico {
  final int? id;
  final String descricao;
  final List<Subservico> subservicos;

  Subservico({
    this.id,
    required this.descricao,
    this.subservicos = const []
  });

  factory Subservico.fromJson(Map<String, dynamic> json) {
    var list = json['subServicosDetalhes'] as List? ?? [];
    List<Subservico> filhos = list.map((i) => Subservico.fromJson(i)).toList();
    return Subservico(
      id: json['id'],
      descricao: json['nome'] ?? 'Sem descrição',
      subservicos: filhos,
    );
  }
}

class Servico {
  final int? idServico;
  final String nome; // Adicionado para espelhar o DTO do Java
  final String descricao;
  final double valor;
  final List<Subservico> subservicos;

  Servico({
    this.idServico,
    required this.nome,
    required this.descricao,
    required this.valor,
    this.subservicos = const [],
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    var list = json['subServicosDetalhes'] as List? ?? [];
    List<Subservico> subservicosList = list.map((i) => Subservico.fromJson(i)).toList();

    return Servico(
      idServico: json['idServico'] ?? json['id'],
      nome: json['nome'] ?? 'Sem nome',
      descricao: json['descricao'] ?? 'Nenhuma descrição informada.',
      valor: (json['valor'] ?? 0).toDouble(),
      subservicos: subservicosList,
    );
  }
}