class DespesaMensalModel {
  final String id;

  final String idDespesaRecorrente;

  final String nome;

  final String categoria;

  final double valor;

  final DateTime dataVencimento;

  final bool estaPaga;

  final DateTime? dataPagamento;

  final String? idLancamento;

  final String? observacao;

  DespesaMensalModel({
    required this.id,
    required this.idDespesaRecorrente,
    required this.nome,
    required this.categoria,
    required this.valor,
    required this.dataVencimento,
    required this.estaPaga,
    this.dataPagamento,
    this.idLancamento,
    this.observacao,
  });
}
