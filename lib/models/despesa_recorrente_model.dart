class DespesaRecorrenteModel {
  final String id;
  final String nome;
  final String categoria;
  final int diaVencimento;
  final bool estaAtiva;
  final String? observacao;

  DespesaRecorrenteModel({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.diaVencimento,
    required this.estaAtiva,
    this.observacao,
  });
}
