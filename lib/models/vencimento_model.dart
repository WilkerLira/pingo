class VencimentoModel {
  final String id;
  final String nome;
  final double valor;
  final DateTime dataVencimento;
  final bool estaPago;

  VencimentoModel({
    required this.id,
    required this.nome,
    required this.valor,
    required this.dataVencimento,
    required this.estaPago,
  });
}
