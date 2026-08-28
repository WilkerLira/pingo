import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:controle_gastos/models/despesa_recorrente_model.dart';
import 'package:controle_gastos/models/despesa_mensal_model.dart';

class ServicoDespesasRecorrentes {
  late final FirebaseFirestore bancoDeDados;

  // =========================================================
  // CONSTRUTOR
  // =========================================================

  ServicoDespesasRecorrentes({FirebaseFirestore? bancoDeDadosRecebido}) {
    if (bancoDeDadosRecebido != null) {
      bancoDeDados = bancoDeDadosRecebido;
    } else {
      bancoDeDados = FirebaseFirestore.instance;
    }
  }

  // =========================================================
  // BUSCAR DESPESAS RECORRENTES
  // =========================================================

  Future<List<DespesaRecorrenteModel>> buscarDespesasRecorrentes() async {
    QuerySnapshot<Map<String, dynamic>> documentos = await bancoDeDados
        .collection('despesas_recorrentes')
        .where('estaAtiva', isEqualTo: true)
        .orderBy('diaVencimento')
        .get();

    List<DespesaRecorrenteModel> despesas = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentos.docs) {
      DespesaRecorrenteModel despesa = converterDocumentoParaDespesaRecorrente(
        documento,
      );

      despesas.add(despesa);
    }

    return despesas;
  }

  // =========================================================
  // CONVERTER DOCUMENTO PARA DESPESA RECORRENTE
  // =========================================================

  DespesaRecorrenteModel converterDocumentoParaDespesaRecorrente(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    Map<String, dynamic> dados = documento.data();

    String nome = '';
    String categoria = 'Outros';

    int diaVencimento = 1;

    bool estaAtiva = true;

    String? observacao;

    if (dados['nome'] != null) {
      nome = dados['nome'].toString();
    }

    if (dados['categoria'] != null) {
      categoria = dados['categoria'].toString();
    }

    if (dados['diaVencimento'] != null) {
      num diaRecebido = dados['diaVencimento'];

      diaVencimento = diaRecebido.toInt();
    }

    if (dados['estaAtiva'] != null) {
      estaAtiva = dados['estaAtiva'];
    }

    if (dados['observacao'] != null) {
      observacao = dados['observacao'].toString();
    }

    return DespesaRecorrenteModel(
      id: documento.id,
      nome: nome,
      categoria: categoria,
      diaVencimento: diaVencimento,
      estaAtiva: estaAtiva,
      observacao: observacao,
    );
  }

  // =========================================================
  // ADICIONAR DESPESA RECORRENTE
  // =========================================================

  Future<void> adicionarDespesaRecorrente(
    DespesaRecorrenteModel despesa,
  ) async {
    Map<String, dynamic> dados = {
      'nome': despesa.nome,
      'categoria': despesa.categoria,
      'diaVencimento': despesa.diaVencimento,
      'estaAtiva': despesa.estaAtiva,
      'observacao': despesa.observacao,
    };

    await bancoDeDados.collection('despesas_recorrentes').add(dados);
  }

  // =========================================================
  // EDITAR DESPESA RECORRENTE
  // =========================================================

  Future<void> editarDespesaRecorrente(DespesaRecorrenteModel despesa) async {
    Map<String, dynamic> dados = {
      'nome': despesa.nome,
      'categoria': despesa.categoria,
      'diaVencimento': despesa.diaVencimento,
      'estaAtiva': despesa.estaAtiva,
      'observacao': despesa.observacao,
    };

    await bancoDeDados
        .collection('despesas_recorrentes')
        .doc(despesa.id)
        .update(dados);
  }

  // =========================================================
  // EXCLUIR DESPESA RECORRENTE
  // =========================================================

  Future<void> excluirDespesaRecorrente(DespesaRecorrenteModel despesa) async {
    await bancoDeDados
        .collection('despesas_recorrentes')
        .doc(despesa.id)
        .delete();
  }

  // =========================================================
  // BUSCAR DESPESAS DO MÊS
  // =========================================================

  Future<List<DespesaMensalModel>> buscarDespesasDoMes(
    DateTime mesSelecionado,
  ) async {
    DateTime inicioDoMes = DateTime(
      mesSelecionado.year,
      mesSelecionado.month,
      1,
    );

    DateTime inicioDoProximoMes = DateTime(
      mesSelecionado.year,
      mesSelecionado.month + 1,
      1,
    );

    QuerySnapshot<Map<String, dynamic>> documentos = await bancoDeDados
        .collection('despesas_mensais')
        .where(
          'dataVencimento',
          isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoMes),
        )
        .where(
          'dataVencimento',
          isLessThan: Timestamp.fromDate(inicioDoProximoMes),
        )
        .orderBy('dataVencimento')
        .get();

    List<DespesaMensalModel> despesas = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentos.docs) {
      DespesaMensalModel despesa = converterDocumentoParaDespesaMensal(
        documento,
      );

      despesas.add(despesa);
    }

    return despesas;
  }

  // =========================================================
  // BUSCAR PRÓXIMOS VENCIMENTOS
  // =========================================================

  Future<List<DespesaMensalModel>> buscarProximosVencimentos() async {
    DateTime agora = DateTime.now();

    DateTime inicioDeHoje = DateTime(agora.year, agora.month, agora.day);

    QuerySnapshot<Map<String, dynamic>> documentos = await bancoDeDados
        .collection('despesas_mensais')
        .where('estaPaga', isEqualTo: false)
        .where(
          'dataVencimento',
          isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDeHoje),
        )
        .orderBy('dataVencimento')
        .limit(3)
        .get();

    List<DespesaMensalModel> proximosVencimentos = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentos.docs) {
      DespesaMensalModel despesa = converterDocumentoParaDespesaMensal(
        documento,
      );

      proximosVencimentos.add(despesa);
    }

    return proximosVencimentos;
  }

  // =========================================================
  // CONVERTER DOCUMENTO PARA DESPESA MENSAL
  // =========================================================

  DespesaMensalModel converterDocumentoParaDespesaMensal(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    Map<String, dynamic> dados = documento.data();

    String idDespesaRecorrente = '';
    String nome = '';
    String categoria = 'Outros';

    double valor = 0.0;

    bool estaPaga = false;

    DateTime dataVencimento = DateTime.now();
    DateTime? dataPagamento;

    String? idLancamento;
    String? observacao;

    if (dados['idDespesaRecorrente'] != null) {
      idDespesaRecorrente = dados['idDespesaRecorrente'].toString();
    }

    if (dados['nome'] != null) {
      nome = dados['nome'].toString();
    }

    if (dados['categoria'] != null) {
      categoria = dados['categoria'].toString();
    }

    if (dados['valor'] != null) {
      num valorRecebido = dados['valor'];

      valor = valorRecebido.toDouble();
    }

    if (dados['estaPaga'] != null) {
      estaPaga = dados['estaPaga'];
    }

    if (dados['dataVencimento'] is Timestamp) {
      Timestamp dataRecebida = dados['dataVencimento'];

      dataVencimento = dataRecebida.toDate();
    }

    if (dados['dataPagamento'] is Timestamp) {
      Timestamp dataRecebida = dados['dataPagamento'];

      dataPagamento = dataRecebida.toDate();
    }

    if (dados['idLancamento'] != null) {
      idLancamento = dados['idLancamento'].toString();
    }

    if (dados['observacao'] != null) {
      observacao = dados['observacao'].toString();
    }

    return DespesaMensalModel(
      id: documento.id,
      idDespesaRecorrente: idDespesaRecorrente,
      nome: nome,
      categoria: categoria,
      valor: valor,
      dataVencimento: dataVencimento,
      estaPaga: estaPaga,
      dataPagamento: dataPagamento,
      idLancamento: idLancamento,
      observacao: observacao,
    );
  }

  // =========================================================
  // ADICIONAR DESPESA MENSAL
  // =========================================================

  Future<void> adicionarDespesaMensal(DespesaMensalModel despesa) async {
    Map<String, dynamic> dados = {
      'idDespesaRecorrente': despesa.idDespesaRecorrente,
      'nome': despesa.nome,
      'categoria': despesa.categoria,
      'valor': despesa.valor,
      'dataVencimento': Timestamp.fromDate(despesa.dataVencimento),
      'estaPaga': despesa.estaPaga,
      'dataPagamento': converterDataPagamento(despesa.dataPagamento),
      'idLancamento': despesa.idLancamento,
      'observacao': despesa.observacao,
    };

    await bancoDeDados.collection('despesas_mensais').add(dados);
  }

  // =========================================================
  // EDITAR DESPESA MENSAL
  // =========================================================

  Future<void> editarDespesaMensal(DespesaMensalModel despesa) async {
    Map<String, dynamic> dados = {
      'idDespesaRecorrente': despesa.idDespesaRecorrente,
      'nome': despesa.nome,
      'categoria': despesa.categoria,
      'valor': despesa.valor,
      'dataVencimento': Timestamp.fromDate(despesa.dataVencimento),
      'estaPaga': despesa.estaPaga,
      'dataPagamento': converterDataPagamento(despesa.dataPagamento),
      'idLancamento': despesa.idLancamento,
      'observacao': despesa.observacao,
    };

    await bancoDeDados
        .collection('despesas_mensais')
        .doc(despesa.id)
        .update(dados);
  }

  // =========================================================
  // EXCLUIR DESPESA MENSAL
  // =========================================================

  Future<void> excluirDespesaMensal(DespesaMensalModel despesa) async {
    await bancoDeDados.collection('despesas_mensais').doc(despesa.id).delete();
  }

  // =========================================================
  // CONVERTER DATA DE PAGAMENTO
  // =========================================================

  Timestamp? converterDataPagamento(DateTime? dataPagamento) {
    if (dataPagamento == null) {
      return null;
    }

    return Timestamp.fromDate(dataPagamento);
  }
}
