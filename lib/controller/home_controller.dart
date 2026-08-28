import 'package:flutter/material.dart';

import 'package:controle_gastos/models/lancamento_model.dart';
import 'package:controle_gastos/services/servico_lancamentos.dart';

class HomeController extends ChangeNotifier {
  final ServicoLancamentos servicoLancamentos = ServicoLancamentos();

  DateTime dataSelecionada = DateTime.now();

  bool estaCarregando = false;

  List<LancamentoModel> lancamentosDoDia = [];

  double totalEntradas = 0.0;
  double totalDespesas = 0.0;
  double saldoDoDia = 0.0;

  double totalUber = 0.0;
  double total99 = 0.0;
  double totalTaxi = 0.0;

  // =========================================================
  // CARREGAR DADOS
  // =========================================================

  Future<void> carregarDados() async {
    estaCarregando = true;

    notifyListeners();

    try {
      List<LancamentoModel> lancamentosEncontrados = await servicoLancamentos
          .buscarLancamentosDoDia(dataSelecionada);

      lancamentosDoDia = lancamentosEncontrados;

      calcularTotais();
      calcularRendaPorFonte();
    } finally {
      estaCarregando = false;

      notifyListeners();
    }
  }

  // =========================================================
  // CALCULAR TOTAIS
  // =========================================================

  void calcularTotais() {
    double entradas = 0.0;
    double despesas = 0.0;

    for (LancamentoModel lancamento in lancamentosDoDia) {
      if (lancamento.ehEntrada) {
        entradas = entradas + lancamento.valor;
      }

      if (lancamento.ehSaida) {
        despesas = despesas + lancamento.valor;
      }
    }

    totalEntradas = entradas;
    totalDespesas = despesas;

    saldoDoDia = totalEntradas - totalDespesas;
  }

  // =========================================================
  // CALCULAR RENDA POR FONTE
  // =========================================================
  void calcularRendaPorFonte() {
    double uber = 0.0;
    double noventaENove = 0.0;
    double taxi = 0.0;

    for (LancamentoModel lancamento in lancamentosDoDia) {
      if (!lancamento.ehEntrada) {
        continue;
      }

      if (lancamento.categoria == 'Uber') {
        uber = uber + lancamento.valor;
      }

      if (lancamento.categoria == '99') {
        noventaENove = noventaENove + lancamento.valor;
      }

      if (lancamento.categoria == 'Táxi') {
        taxi = taxi + lancamento.valor;
      }
    }

    totalUber = uber;
    total99 = noventaENove;
    totalTaxi = taxi;
  }

  // =========================================================
  // ALTERAR DATA
  // =========================================================

  Future<void> alterarDataSelecionada(DateTime novaData) async {
    dataSelecionada = novaData;

    await carregarDados();
  }

  // =========================================================
  // ADICIONAR LANÇAMENTO
  // =========================================================

  Future<void> adicionarLancamento(LancamentoModel lancamento) async {
    await servicoLancamentos.adicionarLancamento(lancamento);

    await carregarDados();
  }

  // =========================================================
  // EDITAR LANÇAMENTO
  // =========================================================

  Future<void> editarLancamento(LancamentoModel lancamento) async {
    await servicoLancamentos.editarLancamento(lancamento);

    await carregarDados();
  }

  // =========================================================
  // EXCLUIR LANÇAMENTO
  // =========================================================

  Future<void> excluirLancamento(LancamentoModel lancamento) async {
    await servicoLancamentos.excluirLancamento(lancamento);

    await carregarDados();
  }
}
