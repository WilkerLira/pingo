import 'package:flutter/material.dart';

import 'package:controle_gastos/models/despesa_mensal_model.dart';
import 'package:controle_gastos/models/despesa_recorrente_model.dart';
import 'package:controle_gastos/models/lancamento_model.dart';

import 'package:controle_gastos/services/servico_despesas_recorrentes.dart';
import 'package:controle_gastos/services/servico_lancamentos.dart';

class DespesasRecorrentesController extends ChangeNotifier {
  final ServicoDespesasRecorrentes servicoDespesasRecorrentes =
      ServicoDespesasRecorrentes();

  final ServicoLancamentos servicoLancamentos = ServicoLancamentos();

  DateTime mesSelecionado = DateTime.now();

  bool estaCarregando = false;

  List<DespesaRecorrenteModel> despesasRecorrentes = [];

  List<DespesaMensalModel> despesasDoMes = [];

  List<DespesaMensalModel> proximosVencimentos = [];

  double totalPrevisto = 0.0;
  double totalPago = 0.0;
  double totalPendente = 0.0;

  // ============================================================
  // CARREGAR DESPESAS RECORRENTES
  // ============================================================

  Future<void> carregarDespesasRecorrentes() async {
    List<DespesaRecorrenteModel> despesasEncontradas =
        await servicoDespesasRecorrentes.buscarDespesasRecorrentes();

    despesasRecorrentes = despesasEncontradas;

    notifyListeners();
  }

  // ============================================================
  // CARREGAR DADOS DO MÊS
  // ============================================================

  Future<void> carregarDados() async {
    estaCarregando = true;

    notifyListeners();

    try {
      List<DespesaMensalModel> despesasEncontradas =
          await servicoDespesasRecorrentes.buscarDespesasDoMes(mesSelecionado);

      despesasDoMes = despesasEncontradas;

      calcularTotais();
    } finally {
      estaCarregando = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CARREGAR PRÓXIMOS VENCIMENTOS
  // ============================================================

  Future<void> carregarProximosVencimentos() async {
    List<DespesaMensalModel> vencimentosEncontrados =
        await servicoDespesasRecorrentes.buscarProximosVencimentos();

    proximosVencimentos = vencimentosEncontrados;

    notifyListeners();
  }

  // ============================================================
  // ADICIONAR DESPESA RECORRENTE
  // ============================================================

  Future<void> adicionarDespesaRecorrente(
    DespesaRecorrenteModel despesa,
  ) async {
    await servicoDespesasRecorrentes.adicionarDespesaRecorrente(despesa);

    await carregarDespesasRecorrentes();
  }

  // ============================================================
  // EDITAR DESPESA RECORRENTE
  // ============================================================

  Future<void> editarDespesaRecorrente(DespesaRecorrenteModel despesa) async {
    await servicoDespesasRecorrentes.editarDespesaRecorrente(despesa);

    await carregarDespesasRecorrentes();
  }

  // ============================================================
  // BUSCAR COMPROMISSO PENDENTE DA RECORRÊNCIA
  // ============================================================

  DespesaMensalModel? buscarCompromissoPendente(String idDespesaRecorrente) {
    for (DespesaMensalModel despesa in despesasDoMes) {
      bool pertenceARecorrencia =
          despesa.idDespesaRecorrente == idDespesaRecorrente;

      bool estaPendente = !despesa.estaPaga;

      if (pertenceARecorrencia && estaPendente) {
        return despesa;
      }
    }

    return null;
  }

  // ============================================================
  // ATUALIZAR COMPROMISSO PENDENTE
  // ============================================================

  Future<void> atualizarCompromissoPendente(
    DespesaMensalModel compromisso,
    DespesaRecorrenteModel recorrencia,
  ) async {
    DateTime dataVencimentoAtualizada = construirDataVencimento(
      compromisso.dataVencimento,
      recorrencia.diaVencimento,
    );

    DespesaMensalModel compromissoAtualizado = DespesaMensalModel(
      id: compromisso.id,
      idDespesaRecorrente: compromisso.idDespesaRecorrente,
      nome: recorrencia.nome,
      categoria: recorrencia.categoria,
      valor: compromisso.valor,
      dataVencimento: dataVencimentoAtualizada,
      estaPaga: compromisso.estaPaga,
      dataPagamento: compromisso.dataPagamento,
      idLancamento: compromisso.idLancamento,
      observacao: recorrencia.observacao,
    );

    await servicoDespesasRecorrentes.editarDespesaMensal(compromissoAtualizado);

    await carregarDados();

    await carregarProximosVencimentos();
  }

  // ============================================================
  // CONSTRUIR DATA DE VENCIMENTO
  // ============================================================

  DateTime construirDataVencimento(DateTime mesReferencia, int diaVencimento) {
    int ultimoDiaDoMes = DateTime(
      mesReferencia.year,
      mesReferencia.month + 1,
      0,
    ).day;

    int diaAjustado = diaVencimento;

    if (diaAjustado > ultimoDiaDoMes) {
      diaAjustado = ultimoDiaDoMes;
    }

    return DateTime(mesReferencia.year, mesReferencia.month, diaAjustado);
  }

  // ============================================================
  // DESATIVAR DESPESA RECORRENTE
  // ============================================================

  Future<void> desativarDespesaRecorrente(
    DespesaRecorrenteModel despesa,
  ) async {
    DespesaRecorrenteModel despesaDesativada = DespesaRecorrenteModel(
      id: despesa.id,
      nome: despesa.nome,
      categoria: despesa.categoria,
      diaVencimento: despesa.diaVencimento,
      estaAtiva: false,
      observacao: despesa.observacao,
    );

    await servicoDespesasRecorrentes.editarDespesaRecorrente(despesaDesativada);

    await carregarDespesasRecorrentes();
  }

  // ============================================================
  // ADICIONAR DESPESA MENSAL
  // ============================================================

  Future<void> adicionarDespesaMensal(DespesaMensalModel despesa) async {
    await servicoDespesasRecorrentes.adicionarDespesaMensal(despesa);

    await carregarDados();

    await carregarProximosVencimentos();
  }

  // ============================================================
  // EDITAR DESPESA MENSAL
  // ============================================================

  Future<void> editarDespesaMensal(DespesaMensalModel despesa) async {
    if (despesa.estaPaga) {
      throw StateError('Uma despesa paga não pode ser editada diretamente.');
    }

    await servicoDespesasRecorrentes.editarDespesaMensal(despesa);

    await carregarDados();

    await carregarProximosVencimentos();
  }

  // ============================================================
  // MARCAR DESPESA COMO PAGA
  // ============================================================

  Future<void> marcarDespesaComoPaga(
    DespesaMensalModel despesa,
    DateTime dataPagamento,
  ) async {
    debugPrint('PAGAMENTO - Despesa: ${despesa.nome}');

    debugPrint('PAGAMENTO - Valor: ${despesa.valor}');

    debugPrint('PAGAMENTO - Data: $dataPagamento');

    debugPrint('PAGAMENTO - ID lançamento atual: ${despesa.idLancamento}');

    if (despesa.idLancamento != null) {
      throw StateError('Esta despesa já possui um lançamento financeiro.');
    }

    LancamentoModel novoLancamento = LancamentoModel(
      id: '',
      tipoLancamento: 'saida',
      categoria: despesa.categoria,
      valor: despesa.valor,
      data: dataPagamento,
      observacao: despesa.nome,
    );

    debugPrint('PAGAMENTO - Criando lançamento em gastos...');

    String idLancamentoCriado = await servicoLancamentos.adicionarLancamento(
      novoLancamento,
    );

    debugPrint('PAGAMENTO - Lançamento criado: $idLancamentoCriado');

    DespesaMensalModel despesaAtualizada = DespesaMensalModel(
      id: despesa.id,
      idDespesaRecorrente: despesa.idDespesaRecorrente,
      nome: despesa.nome,
      categoria: despesa.categoria,
      valor: despesa.valor,
      dataVencimento: despesa.dataVencimento,
      estaPaga: true,
      dataPagamento: dataPagamento,
      idLancamento: idLancamentoCriado,
      observacao: despesa.observacao,
    );

    debugPrint('PAGAMENTO - Atualizando despesa mensal...');

    await servicoDespesasRecorrentes.editarDespesaMensal(despesaAtualizada);

    debugPrint('PAGAMENTO - Processo concluído.');

    await carregarDados();

    await carregarProximosVencimentos();
  }

  // ============================================================
  // DESFAZER PAGAMENTO
  // ============================================================

  Future<void> desfazerPagamento(DespesaMensalModel despesa) async {
    String? idLancamento = despesa.idLancamento;

    if (idLancamento != null) {
      await servicoLancamentos.excluirLancamentoPorId(idLancamento, 'saida');
    }

    DespesaMensalModel despesaAtualizada = DespesaMensalModel(
      id: despesa.id,
      idDespesaRecorrente: despesa.idDespesaRecorrente,
      nome: despesa.nome,
      categoria: despesa.categoria,
      valor: despesa.valor,
      dataVencimento: despesa.dataVencimento,
      estaPaga: false,
      dataPagamento: null,
      idLancamento: null,
      observacao: despesa.observacao,
    );

    await servicoDespesasRecorrentes.editarDespesaMensal(despesaAtualizada);

    await carregarDados();

    await carregarProximosVencimentos();
  }

  // ============================================================
  // CALCULAR TOTAIS
  // ============================================================

  void calcularTotais() {
    double previsto = 0.0;
    double pago = 0.0;
    double pendente = 0.0;

    for (DespesaMensalModel despesa in despesasDoMes) {
      previsto = previsto + despesa.valor;

      if (despesa.estaPaga) {
        pago = pago + despesa.valor;
      } else {
        pendente = pendente + despesa.valor;
      }
    }

    totalPrevisto = previsto;
    totalPago = pago;
    totalPendente = pendente;
  }

  // ============================================================
  // ALTERAR MÊS
  // ============================================================

  Future<void> alterarMesSelecionado(DateTime novoMes) async {
    mesSelecionado = novoMes;

    await carregarDados();
  }
}
