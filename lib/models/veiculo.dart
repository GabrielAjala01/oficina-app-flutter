class Veiculo {
  final String placa;
  final String modelo;
  final int ano;
  final String? cor;
  final String marca;
  final int? idCliente;

  Veiculo({
    required this.placa,
    required this.modelo,
    required this.ano,
    this.cor,
    required this.marca,
    this.idCliente,
  });

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      placa: json['placa'] ?? '',
      modelo: json['modelo'] ?? '',
      ano: json['ano'] ?? 0,
      cor: json['cor'],
      marca: json['marca'] ?? '',
      idCliente: json['idCliente'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placa': placa,
      'modelo': modelo,
      'ano': ano,
      'cor': cor,
      'marca': marca,
      'idCliente': idCliente,
    };
  }
}