import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LancamentoModel {
  final String id;
  final String tipoLancamento;
  final String categoria;
  final double valor;
  final DateTime data; // ← data financeira
  final DateTime? criadoEm; //← momento do cadastro
  final String? observacao;

  LancamentoModel({
    required this.id,
    required this.tipoLancamento,
    required this.categoria,
    required this.valor,
    required this.data,
    this.criadoEm,
    this.observacao,
  });

  factory LancamentoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
    String tipoLancamento,
  ) {
    Map<String, dynamic>? dadosDocumento = documento.data();

    if (dadosDocumento == null) {
      throw StateError(
        'O documento ${documento.id} não possui dados no Firestore.',
      );
    }

    Map<String, dynamic> dados = dadosDocumento;

    String categoria = 'Outros';

    if (dados['tipo'] != null) {
      categoria = dados['tipo'].toString();
    }

    double valor = 0.0;

    if (dados['valor'] != null) {
      valor = (dados['valor'] as num).toDouble();
    }

    DateTime data = _converterData(dados['data']);

    DateTime? criadoEm;

    if (dados['criadoEm'] != null) {
      criadoEm = _converterData(dados['criadoEm']);
    }

    String? observacao;

    if (dados['observacao'] != null) {
      observacao = dados['observacao'].toString();
    }

    return LancamentoModel(
      id: documento.id,
      tipoLancamento: tipoLancamento,
      categoria: categoria,
      valor: valor,
      data: data,
      criadoEm: criadoEm,
      observacao: observacao,
    );
  }

  static DateTime _converterData(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is int) {
      return DateTime.fromMillisecondsSinceEpoch(valor);
    }

    return DateTime.now();
  }

  bool get ehEntrada {
    return tipoLancamento == 'entrada';
  }

  bool get ehSaida {
    return tipoLancamento == 'saida';
  }

  String obterDataFormatada() {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(data);
  }

  String obterHoraFormatada() {
    DateTime dataHora = data;

    if (criadoEm != null) {
      dataHora = criadoEm!;
    }

    return DateFormat('HH:mm', 'pt_BR').format(dataHora);
  }
}
