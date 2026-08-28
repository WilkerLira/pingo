import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:controle_gastos/models/lancamento_model.dart';

class ServicoLancamentos {
  late final FirebaseFirestore bancoDeDados;

  ServicoLancamentos({FirebaseFirestore? bancoDeDadosRecebido}) {
    if (bancoDeDadosRecebido != null) {
      bancoDeDados = bancoDeDadosRecebido;
    } else {
      bancoDeDados = FirebaseFirestore.instance;
    }
  }

  // =========================================================
  // BUSCAR LANÇAMENTOS
  // =========================================================

  Future<List<LancamentoModel>> buscarLancamentosDoDia(
    DateTime dataSelecionada,
  ) async {
    DateTime inicioDoDia = DateTime(
      dataSelecionada.year,
      dataSelecionada.month,
      dataSelecionada.day,
    );

    DateTime fimDoDia = inicioDoDia.add(const Duration(days: 1));

    QuerySnapshot<Map<String, dynamic>> documentosEntradas = await bancoDeDados
        .collection('ganhos')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoDia))
        .where('data', isLessThan: Timestamp.fromDate(fimDoDia))
        .orderBy('data', descending: true)
        .get();

    QuerySnapshot<Map<String, dynamic>> documentosSaidas = await bancoDeDados
        .collection('gastos')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoDia))
        .where('data', isLessThan: Timestamp.fromDate(fimDoDia))
        .orderBy('data', descending: true)
        .get();

    List<LancamentoModel> lancamentos = [];

    adicionarEntradasNaLista(documentosEntradas, lancamentos);

    adicionarSaidasNaLista(documentosSaidas, lancamentos);

    lancamentos.sort(compararLancamentosPorData);

    return lancamentos;
  }

  // =========================================================
  // ADICIONAR LANÇAMENTO
  // =========================================================

  Future<String> adicionarLancamento(LancamentoModel lancamento) async {
    String nomeColecao = obterNomeColecao(lancamento.tipoLancamento);

    Map<String, dynamic> dados = {
      'tipo': lancamento.categoria,
      'valor': lancamento.valor,
      'data': Timestamp.fromDate(lancamento.data),
      'criadoEm': FieldValue.serverTimestamp(),
      'observacao': lancamento.observacao,
    };

    DocumentReference<Map<String, dynamic>> documentoCriado = await bancoDeDados
        .collection(nomeColecao)
        .add(dados);

    return documentoCriado.id;
  }

  // =========================================================
  // EDITAR LANÇAMENTO
  // =========================================================

  Future<void> editarLancamento(LancamentoModel lancamento) async {
    String nomeColecao = obterNomeColecao(lancamento.tipoLancamento);

    Map<String, dynamic> dados = {
      'tipo': lancamento.categoria,
      'valor': lancamento.valor,
      'data': Timestamp.fromDate(lancamento.data),
      'observacao': lancamento.observacao,
    };

    await bancoDeDados.collection(nomeColecao).doc(lancamento.id).update(dados);
  }

  // =========================================================
  // EXCLUIR LANÇAMENTO
  // =========================================================

  Future<void> excluirLancamento(LancamentoModel lancamento) async {
    String nomeColecao = obterNomeColecao(lancamento.tipoLancamento);

    await bancoDeDados.collection(nomeColecao).doc(lancamento.id).delete();
  }

  // ============================================================
  // EXCLUIR LANÇAMENTO PELO ID
  // ============================================================

  Future<void> excluirLancamentoPorId(
    String idLancamento,
    String tipoLancamento,
  ) async {
    String nomeColecao = obterNomeColecao(tipoLancamento);

    await bancoDeDados.collection(nomeColecao).doc(idLancamento).delete();
  }

  // =========================================================
  // CONVERTER ENTRADAS DO FIREBASE
  // =========================================================

  void adicionarEntradasNaLista(
    QuerySnapshot<Map<String, dynamic>> documentosEntradas,
    List<LancamentoModel> lancamentos,
  ) {
    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentosEntradas.docs) {
      LancamentoModel lancamento = LancamentoModel.fromFirestore(
        documento,
        'entrada',
      );

      lancamentos.add(lancamento);
    }
  }

  // =========================================================
  // CONVERTER DESPESAS DO FIREBASE
  // =========================================================

  void adicionarSaidasNaLista(
    QuerySnapshot<Map<String, dynamic>> documentosSaidas,
    List<LancamentoModel> lancamentos,
  ) {
    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentosSaidas.docs) {
      LancamentoModel lancamento = LancamentoModel.fromFirestore(
        documento,
        'saida',
      );

      lancamentos.add(lancamento);
    }
  }

  // =========================================================
  // ORDENAR LANÇAMENTOS PELA DATA
  // =========================================================

  int compararLancamentosPorData(
    LancamentoModel primeiroLancamento,
    LancamentoModel segundoLancamento,
  ) {
    return segundoLancamento.data.compareTo(primeiroLancamento.data);
  }

  // =========================================================
  // DESCOBRIR QUAL COLEÇÃO DO FIREBASE UTILIZAR
  // =========================================================

  String obterNomeColecao(String tipoLancamento) {
    if (tipoLancamento == 'entrada') {
      return 'ganhos';
    }

    return 'gastos';
  }
}
