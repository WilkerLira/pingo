import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RelatoriosController extends ChangeNotifier {
  // ============================================================
  // FIRESTORE
  // ============================================================

  final FirebaseFirestore bancoDeDados = FirebaseFirestore.instance;

  // ============================================================
  // ESTADO
  // ============================================================

  bool estaCarregando = false;

  bool visualizarPorMes = true;

  DateTime periodoSelecionado = DateTime.now();

  // ============================================================
  // RESUMO DO PERÍODO
  // ============================================================

  double totalEntradas = 0.0;

  double totalDespesas = 0.0;

  double saldoAtual = 0.0;

  double totalCompromissosPendentes = 0.0;

  double saldoProjetado = 0.0;

  // ============================================================
  // DESPESAS POR CATEGORIA
  // ============================================================

  double totalAluguelVeiculo = 0.0;

  double totalCombustivel = 0.0;

  double totalAlimentacao = 0.0;

  double totalMoradia = 0.0;

  double totalTransporte = 0.0;

  double totalComunicacao = 0.0;

  double totalFinanceiro = 0.0;

  double totalOutros = 0.0;

  // ============================================================
  // RENDA POR FONTE
  // ============================================================

  double totalUber = 0.0;

  double total99 = 0.0;

  double totalTaxi = 0.0;

  double totalOutrasEntradas = 0.0;

  // ============================================================
  // TRABALHO
  // ============================================================

  double custosDoTrabalho = 0.0;

  double rendaBrutaTrabalho = 0.0;

  double resultadoDoTrabalho = 0.0;

  // ============================================================
  // CARREGAR RELATÓRIO
  // ============================================================

  Future<void> carregarRelatorio() async {
    estaCarregando = true;

    notifyListeners();

    try {
      DateTime inicioPeriodo = obterInicioPeriodo();

      DateTime fimPeriodo = obterFimPeriodo();

      limparTotais();

      await buscarGanhosDoPeriodo(
        inicioPeriodo: inicioPeriodo,
        fimPeriodo: fimPeriodo,
      );

      await buscarGastosDoPeriodo(
        inicioPeriodo: inicioPeriodo,
        fimPeriodo: fimPeriodo,
      );

      totalCompromissosPendentes = await buscarTotalCompromissosPendentes(
        inicioPeriodo: inicioPeriodo,
        fimPeriodo: fimPeriodo,
      );

      calcularTotais();
    } finally {
      estaCarregando = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LIMPAR TOTAIS
  // ============================================================

  void limparTotais() {
    totalEntradas = 0.0;

    totalDespesas = 0.0;

    saldoAtual = 0.0;

    totalCompromissosPendentes = 0.0;

    saldoProjetado = 0.0;

    totalAluguelVeiculo = 0.0;

    totalCombustivel = 0.0;

    totalAlimentacao = 0.0;

    totalMoradia = 0.0;

    totalTransporte = 0.0;

    totalComunicacao = 0.0;

    totalFinanceiro = 0.0;

    totalOutros = 0.0;

    totalUber = 0.0;

    total99 = 0.0;

    totalTaxi = 0.0;

    totalOutrasEntradas = 0.0;

    custosDoTrabalho = 0.0;

    rendaBrutaTrabalho = 0.0;

    resultadoDoTrabalho = 0.0;
  }

  // ============================================================
  // BUSCAR GANHOS DO PERÍODO
  // ============================================================

  Future<void> buscarGanhosDoPeriodo({
    required DateTime inicioPeriodo,
    required DateTime fimPeriodo,
  }) async {
    QuerySnapshot<Map<String, dynamic>> documentos = await bancoDeDados
        .collection('ganhos')
        .where(
          'data',
          isGreaterThanOrEqualTo: Timestamp.fromDate(inicioPeriodo),
        )
        .where('data', isLessThan: Timestamp.fromDate(fimPeriodo))
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentos.docs) {
      Map<String, dynamic> dados = documento.data();

      if (dados['valor'] == null) {
        continue;
      }

      double valor = (dados['valor'] as num).toDouble();

      String categoria = 'Outros';

      if (dados['tipo'] != null) {
        categoria = dados['tipo'].toString();
      }

      totalEntradas = totalEntradas + valor;

      adicionarGanhoPorCategoria(categoria: categoria, valor: valor);
    }
  }

  // ============================================================
  // ADICIONAR GANHO POR CATEGORIA
  // ============================================================

  void adicionarGanhoPorCategoria({
    required String categoria,
    required double valor,
  }) {
    if (categoria == 'Uber') {
      totalUber = totalUber + valor;

      return;
    }

    if (categoria == '99') {
      total99 = total99 + valor;

      return;
    }

    if (categoria == 'Táxi') {
      totalTaxi = totalTaxi + valor;

      return;
    }

    totalOutrasEntradas = totalOutrasEntradas + valor;
  }

  // ============================================================
  // BUSCAR GASTOS DO PERÍODO
  // ============================================================

  Future<void> buscarGastosDoPeriodo({
    required DateTime inicioPeriodo,
    required DateTime fimPeriodo,
  }) async {
    QuerySnapshot<Map<String, dynamic>> documentos = await bancoDeDados
        .collection('gastos')
        .where(
          'data',
          isGreaterThanOrEqualTo: Timestamp.fromDate(inicioPeriodo),
        )
        .where('data', isLessThan: Timestamp.fromDate(fimPeriodo))
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentos.docs) {
      Map<String, dynamic> dados = documento.data();

      if (dados['valor'] == null) {
        continue;
      }

      double valor = (dados['valor'] as num).toDouble();

      String categoria = 'Outros';

      if (dados['tipo'] != null) {
        categoria = dados['tipo'].toString();
      }

      totalDespesas = totalDespesas + valor;

      adicionarGastoPorCategoria(categoria: categoria, valor: valor);
    }
  }

  // ============================================================
  // ADICIONAR GASTO POR CATEGORIA
  // ============================================================

  void adicionarGastoPorCategoria({
    required String categoria,
    required double valor,
  }) {
    if (categoria == 'Aluguel do veículo') {
      totalAluguelVeiculo = totalAluguelVeiculo + valor;

      return;
    }

    if (categoria == 'Combustível') {
      totalCombustivel = totalCombustivel + valor;

      return;
    }

    if (categoria == 'Alimentação') {
      totalAlimentacao = totalAlimentacao + valor;

      return;
    }

    if (categoria == 'Moradia') {
      totalMoradia = totalMoradia + valor;

      return;
    }

    if (categoria == 'Transporte') {
      totalTransporte = totalTransporte + valor;

      return;
    }

    if (categoria == 'Comunicação') {
      totalComunicacao = totalComunicacao + valor;

      return;
    }

    if (categoria == 'Financeiro') {
      totalFinanceiro = totalFinanceiro + valor;

      return;
    }

    totalOutros = totalOutros + valor;
  }

  // ============================================================
  // BUSCAR COMPROMISSOS PENDENTES
  // ============================================================

  Future<double> buscarTotalCompromissosPendentes({
    required DateTime inicioPeriodo,
    required DateTime fimPeriodo,
  }) async {
    QuerySnapshot<Map<String, dynamic>> documentos = await bancoDeDados
        .collection('despesas_mensais')
        .where('estaPaga', isEqualTo: false)
        .where(
          'dataVencimento',
          isGreaterThanOrEqualTo: Timestamp.fromDate(inicioPeriodo),
        )
        .where('dataVencimento', isLessThan: Timestamp.fromDate(fimPeriodo))
        .get();

    double total = 0.0;

    for (QueryDocumentSnapshot<Map<String, dynamic>> documento
        in documentos.docs) {
      Map<String, dynamic> dados = documento.data();

      if (dados['valor'] == null) {
        continue;
      }

      double valor = (dados['valor'] as num).toDouble();

      total = total + valor;
    }

    return total;
  }

  // ============================================================
  // CALCULAR TOTAIS
  // ============================================================

  void calcularTotais() {
    saldoAtual = totalEntradas - totalDespesas;

    saldoProjetado = saldoAtual - totalCompromissosPendentes;

    custosDoTrabalho = totalAluguelVeiculo + totalCombustivel;

    rendaBrutaTrabalho = totalUber + total99 + totalTaxi;

    resultadoDoTrabalho = rendaBrutaTrabalho - custosDoTrabalho;
  }

  // ============================================================
  // INÍCIO DO PERÍODO
  // ============================================================

  DateTime obterInicioPeriodo() {
    if (visualizarPorMes) {
      return DateTime(periodoSelecionado.year, periodoSelecionado.month, 1);
    }

    DateTime inicioDoDia = DateTime(
      periodoSelecionado.year,
      periodoSelecionado.month,
      periodoSelecionado.day,
    );

    int diasDesdeSegunda = inicioDoDia.weekday - 1;

    return inicioDoDia.subtract(Duration(days: diasDesdeSegunda));
  }

  // ============================================================
  // FIM DO PERÍODO
  // ============================================================

  DateTime obterFimPeriodo() {
    DateTime inicioPeriodo = obterInicioPeriodo();

    if (visualizarPorMes) {
      return DateTime(inicioPeriodo.year, inicioPeriodo.month + 1, 1);
    }

    return inicioPeriodo.add(const Duration(days: 7));
  }

  // ============================================================
  // SELECIONAR SEMANA
  // ============================================================

  Future<void> selecionarSemana() async {
    visualizarPorMes = false;

    await carregarRelatorio();
  }

  // ============================================================
  // SELECIONAR MÊS
  // ============================================================

  Future<void> selecionarMes() async {
    visualizarPorMes = true;

    await carregarRelatorio();
  }

  // ============================================================
  // PERÍODO ANTERIOR
  // ============================================================

  Future<void> periodoAnterior() async {
    if (visualizarPorMes) {
      periodoSelecionado = DateTime(
        periodoSelecionado.year,
        periodoSelecionado.month - 1,
        1,
      );
    } else {
      periodoSelecionado = periodoSelecionado.subtract(const Duration(days: 7));
    }

    await carregarRelatorio();
  }

  // ============================================================
  // PRÓXIMO PERÍODO
  // ============================================================

  Future<void> proximoPeriodo() async {
    if (visualizarPorMes) {
      periodoSelecionado = DateTime(
        periodoSelecionado.year,
        periodoSelecionado.month + 1,
        1,
      );
    } else {
      periodoSelecionado = periodoSelecionado.add(const Duration(days: 7));
    }

    await carregarRelatorio();
  }
}
