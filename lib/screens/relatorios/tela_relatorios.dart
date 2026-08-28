import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:controle_gastos/controller/relatorios_controller.dart';

class TelaRelatorios extends StatefulWidget {
  const TelaRelatorios({super.key});

  @override
  State<TelaRelatorios> createState() {
    return _TelaRelatoriosState();
  }
}

class _TelaRelatoriosState extends State<TelaRelatorios> {
  // ============================================================
  // FORMATAÇÃO
  // ============================================================

  final NumberFormat formatoMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(executarCarregamentoInicial);
  }

  void executarCarregamentoInicial(Duration tempo) {
    carregarRelatorioInicial();
  }

  // ============================================================
  // CARREGAMENTO INICIAL
  // ============================================================

  void carregarRelatorioInicial() {
    RelatoriosController controller = Provider.of<RelatoriosController>(
      context,
      listen: false,
    );

    controller.carregarRelatorio();
  }

  // ============================================================
  // ALTERAR TIPO DE PERÍODO
  // ============================================================

  void selecionarSemana() {
    RelatoriosController controller = Provider.of<RelatoriosController>(
      context,
      listen: false,
    );

    controller.selecionarSemana();
  }

  void selecionarMes() {
    RelatoriosController controller = Provider.of<RelatoriosController>(
      context,
      listen: false,
    );

    controller.selecionarMes();
  }

  // ============================================================
  // NAVEGAÇÃO DO PERÍODO
  // ============================================================

  void periodoAnterior() {
    RelatoriosController controller = Provider.of<RelatoriosController>(
      context,
      listen: false,
    );

    controller.periodoAnterior();
  }

  void proximoPeriodo() {
    RelatoriosController controller = Provider.of<RelatoriosController>(
      context,
      listen: false,
    );

    controller.proximoPeriodo();
  }

  // ============================================================
  // TEXTO DO PERÍODO
  // ============================================================

  String obterTextoPeriodo(RelatoriosController controller) {
    if (controller.visualizarPorMes) {
      DateFormat formato = DateFormat('MMMM \'de\' yyyy', 'pt_BR');

      String texto = formato.format(controller.periodoSelecionado);

      if (texto.isEmpty) {
        return '';
      }

      String primeiraLetra = texto.substring(0, 1).toUpperCase();

      String restante = texto.substring(1);

      return '$primeiraLetra$restante';
    }

    DateTime inicioSemana = controller.periodoSelecionado.subtract(
      Duration(days: controller.periodoSelecionado.weekday - 1),
    );

    DateTime fimSemana = inicioSemana.add(const Duration(days: 6));

    DateFormat formato = DateFormat('dd/MM', 'pt_BR');

    return '${formato.format(inicioSemana)} a ${formato.format(fimSemana)}';
  }

  // ============================================================
  // CONSTRUÇÃO DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    RelatoriosController controller = Provider.of<RelatoriosController>(
      context,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      appBar: AppBar(
        title: const Text(
          'Relatórios',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(child: construirConteudo(controller)),
    );
  }

  // ============================================================
  // CONTEÚDO
  // ============================================================

  Widget construirConteudo(RelatoriosController controller) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      children: [
        construirSeletorPeriodo(controller),

        const SizedBox(height: 18),

        construirNavegacaoPeriodo(controller),

        if (controller.estaCarregando) ...[
          const SizedBox(height: 4),

          const LinearProgressIndicator(minHeight: 2),
        ],

        const SizedBox(height: 24),

        construirResumoPeriodo(controller),

        const SizedBox(height: 24),

        construirDestinoDinheiro(controller),

        const SizedBox(height: 24),

        construirCustosTrabalho(controller),

        const SizedBox(height: 24),

        construirRendaTrabalho(controller),
      ],
    );
  }

  // ============================================================
  // SELETOR SEMANA / MÊS
  // ============================================================

  Widget construirSeletorPeriodo(RelatoriosController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: construirBotaoPeriodo(
              texto: 'Semana',
              selecionado: !controller.visualizarPorMes,
              aoSelecionar: selecionarSemana,
            ),
          ),

          Expanded(
            child: construirBotaoPeriodo(
              texto: 'Mês',
              selecionado: controller.visualizarPorMes,
              aoSelecionar: selecionarMes,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTÃO DO PERÍODO
  // ============================================================

  Widget construirBotaoPeriodo({
    required String texto,
    required bool selecionado,
    required VoidCallback aoSelecionar,
  }) {
    Color corFundo = Colors.transparent;

    Color corTexto = Colors.black54;

    if (selecionado) {
      corFundo = Colors.white;

      corTexto = const Color(0xFF1E3A5F);
    }

    return InkWell(
      onTap: aoSelecionar,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: corTexto,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVEGAÇÃO ENTRE PERÍODOS
  // ============================================================

  Widget construirNavegacaoPeriodo(RelatoriosController controller) {
    return Row(
      children: [
        IconButton(
          onPressed: periodoAnterior,
          icon: const Icon(Icons.chevron_left_rounded),
        ),

        Expanded(
          child: Text(
            obterTextoPeriodo(controller),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ),

        IconButton(
          onPressed: proximoPeriodo,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  // ============================================================
  // RESUMO DO PERÍODO
  // ============================================================

  Widget construirResumoPeriodo(RelatoriosController controller) {
    return construirCartao(
      titulo: 'Resumo do período',
      conteudo: Column(
        children: [
          construirLinhaValor('Entradas', controller.totalEntradas),

          construirLinhaValor('Despesas pagas', controller.totalDespesas),

          const Divider(height: 24),

          construirLinhaValor(
            'Saldo atual',
            controller.saldoAtual,
            destaque: true,
          ),

          const SizedBox(height: 16),

          construirLinhaValor(
            'Compromissos pendentes',
            controller.totalCompromissosPendentes,
          ),

          const Divider(height: 24),

          construirLinhaValor(
            'Saldo projetado',
            controller.saldoProjetado,
            destaque: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PARA ONDE FOI O DINHEIRO
  // ============================================================

  Widget construirDestinoDinheiro(RelatoriosController controller) {
    return construirCartao(
      titulo: 'Para onde foi o dinheiro?',
      conteudo: Column(
        children: [
          construirBarraDespesa(
            nome: 'Aluguel do veículo',
            valor: controller.totalAluguelVeiculo,
            totalDespesas: controller.totalDespesas,
          ),

          construirBarraDespesa(
            nome: 'Combustível',
            valor: controller.totalCombustivel,
            totalDespesas: controller.totalDespesas,
          ),

          construirBarraDespesa(
            nome: 'Alimentação',
            valor: controller.totalAlimentacao,
            totalDespesas: controller.totalDespesas,
          ),

          construirBarraDespesa(
            nome: 'Moradia',
            valor: controller.totalMoradia,
            totalDespesas: controller.totalDespesas,
          ),

          construirBarraDespesa(
            nome: 'Transporte',
            valor: controller.totalTransporte,
            totalDespesas: controller.totalDespesas,
          ),

          construirBarraDespesa(
            nome: 'Comunicação',
            valor: controller.totalComunicacao,
            totalDespesas: controller.totalDespesas,
          ),

          construirBarraDespesa(
            nome: 'Financeiro',
            valor: controller.totalFinanceiro,
            totalDespesas: controller.totalDespesas,
          ),

          construirBarraDespesa(
            nome: 'Outros',
            valor: controller.totalOutros,
            totalDespesas: controller.totalDespesas,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARRA HORIZONTAL DE DESPESA
  // ============================================================

  Widget construirBarraDespesa({
    required String nome,
    required double valor,
    required double totalDespesas,
  }) {
    double percentual = 0.0;

    if (totalDespesas > 0) {
      percentual = valor / totalDespesas;
    }

    if (percentual > 1) {
      percentual = 1;
    }

    if (percentual < 0) {
      percentual = 0;
    }

    double percentualExibicao = 0.0;

    if (totalDespesas > 0) {
      percentualExibicao = (valor / totalDespesas) * 100;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                formatoMoeda.format(valor),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A5F),
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 38,
                child: Text(
                  '${percentualExibicao.toStringAsFixed(0)}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentual,
              minHeight: 8,
              backgroundColor: const Color(0xFFE9EDF2),
              color: const Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOS DO TRABALHO
  // ============================================================

  Widget construirCustosTrabalho(RelatoriosController controller) {
    return construirCartao(
      titulo: 'Custos do trabalho',
      conteudo: Column(
        children: [
          construirLinhaValor(
            'Aluguel do veículo',
            controller.totalAluguelVeiculo,
          ),

          construirLinhaValor('Combustível', controller.totalCombustivel),

          const Divider(height: 24),

          construirLinhaValor(
            'Total',
            controller.custosDoTrabalho,
            destaque: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RENDA DO TRABALHO
  // ============================================================

  Widget construirRendaTrabalho(RelatoriosController controller) {
    return construirCartao(
      titulo: 'Renda do trabalho',
      conteudo: Column(
        children: [
          construirLinhaValor('Uber', controller.totalUber),

          construirLinhaValor('99', controller.total99),

          construirLinhaValor('Táxi', controller.totalTaxi),

          if (controller.totalOutrasEntradas > 0)
            construirLinhaValor('Outros', controller.totalOutrasEntradas),

          const Divider(height: 24),

          construirLinhaValor(
            'Renda bruta',
            controller.rendaBrutaTrabalho,
            destaque: true,
          ),

          const SizedBox(height: 12),

          construirLinhaValor(
            'Custos do trabalho',
            -controller.custosDoTrabalho,
          ),

          const Divider(height: 24),

          construirLinhaValor(
            'Resultado do trabalho',
            controller.resultadoDoTrabalho,
            destaque: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTÃO PADRÃO
  // ============================================================

  Widget construirCartao({required String titulo, required Widget conteudo}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A5F),
            ),
          ),

          const SizedBox(height: 18),

          conteudo,
        ],
      ),
    );
  }

  // ============================================================
  // LINHA DE VALOR
  // ============================================================

  Widget construirLinhaValor(
    String titulo,
    double valor, {
    bool destaque = false,
  }) {
    FontWeight pesoFonte = FontWeight.w500;

    double tamanhoFonte = 13;

    Color corTexto = Colors.black87;

    if (destaque) {
      pesoFonte = FontWeight.w800;

      tamanhoFonte = 14;

      corTexto = const Color(0xFF1E3A5F);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: tamanhoFonte,
                fontWeight: pesoFonte,
                color: corTexto,
              ),
            ),
          ),

          Text(
            formatoMoeda.format(valor),
            style: TextStyle(
              fontSize: tamanhoFonte,
              fontWeight: pesoFonte,
              color: corTexto,
            ),
          ),
        ],
      ),
    );
  }
}
