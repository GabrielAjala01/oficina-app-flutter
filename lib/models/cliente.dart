import 'veiculo.dart';
class Cliente {
  final int? idCliente;
  final String nome;
  final String? telefone;
  final String cpfCnpj;
  final String? email;
  final String? endereco;
  final String? inscricaoEstadual;
  final List<Veiculo> veiculos;

  factory Cliente.fromJson(Map<String, dynamic> json) {

    var veiculosJson = json['veiculos'] as List<dynamic>?;

    List<Veiculo> veiculosList = veiculosJson != null
        ? veiculosJson.map((i) => Veiculo.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    return Cliente(
      idCliente: json['idCliente'],
      nome: json['nome'] ?? '',
      telefone: json['telefone'],
      cpfCnpj: json['cpfCnpj'] ?? '',
      email: json['email'],
      endereco: json['endereco'],
      inscricaoEstadual: json['inscricaoEstadual'],
      veiculos: veiculosList,
    );
  }


  Cliente({
    this.idCliente,
    required this.nome,
    this.telefone,
    required this.cpfCnpj,
    this.email,
    this.endereco,
    this.inscricaoEstadual,
    this.veiculos = const [],
  });

}