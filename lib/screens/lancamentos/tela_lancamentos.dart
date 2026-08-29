import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:controle_gastos/controller/home_controller.dart';
import 'package:controle_gastos/models/lancamento_model.dart';

import 'package:controle_gastos/screens/lancamentos/tela_editar_lancamento.dart';

class TelaLancamentos extends StatefulWidget {
  const TelaLancamentos({super.key});

  @override
  State<TelaLancamentos> createState() {
    return _TelaLancamentosState();
  }
}

class _TelaLancamentosState extends State<TelaLancamentos> {
  final DateFormat formatoData = DateFormat('dd/MM/yyyy', 'pt_BR');

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

    WidgetsBinding.instance.addPostFrameCallback(
      carregarDadosDepoisDoPrimeiroFrame,
    );
  }

  void carregarDadosDepoisDoPrimeiroFrame(Duration duracao) {
    carregarDataAtual();
  }

  // ============================================================
  // CARREGAR DATA ATUAL AO ABRIR A TELA
  // ============================================================

  Future<void> carregarDataAtual() async {
    HomeController controller = Provider.of<HomeController>(
      context,
      listen: false,
    );

    DateTime agora = DateTime.now();

    DateTime hoje = DateTime(agora.year, agora.month, agora.day);

    await controller.alterarDataSelecionada(hoje);
  }

  // ============================================================
  // ATUALIZAR DADOS DA DATA SELECIONADA
  // ============================================================

  Future<void> carregarDados() async {
    HomeController controller = Provider.of<HomeController>(
      context,
      listen: false,
    );

    await controller.carregarDados();
  }

  // ============================================================
  // CONSTRUÇÃO DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    HomeController controller = Provider.of<HomeController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Lançamentos')),
      body: construirConteudo(controller),
    );
  }

  // ============================================================
  // CONTEÚDO PRINCIPAL
  // ============================================================

  Widget construirConteudo(HomeController controller) {
    if (controller.estaCarregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: carregarDados,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          construirSeletorData(controller),

          const SizedBox(height: 20),

          construirResumo(controller),

          const SizedBox(height: 28),

          construirTituloLista(),

          const SizedBox(height: 12),

          construirListaLancamentos(controller),
        ],
      ),
    );
  }

  // ============================================================
  // SELETOR DE DATA
  // ============================================================

  Widget construirSeletorData(HomeController controller) {
    String dataFormatada = formatoData.format(controller.dataSelecionada);

    return InkWell(
      onTap: abrirCalendario,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: Color(0xFF1E3A5F)),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                dataFormatada,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ABRIR CALENDÁRIO
  // ============================================================

  Future<void> abrirCalendario() async {
    HomeController controller = Provider.of<HomeController>(
      context,
      listen: false,
    );

    DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: controller.dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (!mounted) {
      return;
    }

    if (novaData == null) {
      return;
    }

    await controller.alterarDataSelecionada(novaData);
  }

  // ============================================================
  // RESUMO
  // ============================================================

  Widget construirResumo(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          construirLinhaResumo(
            titulo: 'Entradas',
            valor: controller.totalEntradas,
            icone: Icons.arrow_downward_rounded,
          ),

          const SizedBox(height: 14),

          construirLinhaResumo(
            titulo: 'Saídas',
            valor: controller.totalDespesas,
            icone: Icons.arrow_upward_rounded,
          ),

          const Divider(height: 30),

          construirLinhaResumo(
            titulo: 'Saldo do dia',
            valor: controller.saldoDoDia,
            icone: Icons.account_balance_wallet_outlined,
            destacar: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LINHA DO RESUMO
  // ============================================================

  Widget construirLinhaResumo({
    required String titulo,
    required double valor,
    required IconData icone,
    bool destacar = false,
  }) {
    return Row(
      children: [
        Icon(icone, size: 20, color: const Color(0xFF1E3A5F)),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: destacar ? 16 : 14,
              fontWeight: destacar ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),

        Flexible(
          child: Text(
            formatoMoeda.format(valor),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: destacar ? 18 : 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E3A5F),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TÍTULO DA LISTA
  // ============================================================

  Widget construirTituloLista() {
    return const Text(
      'Lançamentos do dia',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E3A5F),
      ),
    );
  }

  // ============================================================
  // LISTA DE LANÇAMENTOS
  // ============================================================

  Widget construirListaLancamentos(HomeController controller) {
    if (controller.lancamentosDoDia.isEmpty) {
      return construirEstadoVazio();
    }

    List<Widget> itens = [];

    for (LancamentoModel lancamento in controller.lancamentosDoDia) {
      itens.add(construirItemLancamento(lancamento));

      itens.add(const SizedBox(height: 10));
    }

    return Column(children: itens);
  }

  // ============================================================
  // ITEM DO LANÇAMENTO
  // ============================================================

  Widget construirItemLancamento(LancamentoModel lancamento) {
    HomeController controller = Provider.of<HomeController>(
      context,
      listen: false,
    );

    bool entrada = lancamento.tipoLancamento == 'entrada';

    String sinal = '-';
    IconData icone = Icons.arrow_upward_rounded;

    if (entrada) {
      sinal = '+';
      icone = Icons.arrow_downward_rounded;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          abrirTelaEditarLancamento(lancamento, controller);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // PARTE SUPERIOR DO CARD
              // ============================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  construirIconeLancamento(icone),

                  const SizedBox(width: 12),

                  Expanded(child: construirInformacoesLancamento(lancamento)),
                ],
              ),

              const SizedBox(height: 12),

              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

              const SizedBox(height: 8),

              // ============================================================
              // PARTE INFERIOR DO CARD
              // ============================================================
              construirRodapeLancamento(
                lancamento: lancamento,
                controller: controller,
                sinal: sinal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ÍCONE DO LANÇAMENTO
  // ============================================================

  Widget construirIconeLancamento(IconData icone) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F3F7),
        shape: BoxShape.circle,
      ),
      child: Icon(icone, color: const Color(0xFF1E3A5F)),
    );
  }

  // ============================================================
  // INFORMAÇÕES DO LANÇAMENTO
  // ============================================================

  Widget construirInformacoesLancamento(LancamentoModel lancamento) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // CATEGORIA
        // ============================================================

        Text(
          lancamento.categoria,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202124),
          ),
        ),

        // ============================================================
        // OBSERVAÇÃO
        // ============================================================
        if (lancamento.observacao != null &&
            lancamento.observacao!.isNotEmpty) ...[
          const SizedBox(height: 4),

          Text(
            lancamento.observacao!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Colors.black54,
            ),
          ),
        ],

        // ============================================================
        // DATA E HORA
        // ============================================================
        if (lancamento.criadoEm != null) ...[
          const SizedBox(height: 7),

          construirDataHoraLancamento(lancamento),
        ],
      ],
    );
  }

  // ============================================================
  // RODAPÉ DO LANÇAMENTO
  // ============================================================

  Widget construirRodapeLancamento({
    required LancamentoModel lancamento,
    required HomeController controller,
    required String sinal,
  }) {
    return Row(
      children: [
        // ============================================================
        // VALOR
        // ============================================================

        Expanded(
          child: Text(
            '$sinal ${formatoMoeda.format(lancamento.valor)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ============================================================
        // EDITAR
        // ============================================================
        construirBotaoEditar(lancamento, controller),

        const SizedBox(width: 2),

        // ============================================================
        // EXCLUIR
        // ============================================================
        construirBotaoExcluir(lancamento, controller),
      ],
    );
  }

  // ============================================================
  // BOTÃO EDITAR
  // ============================================================

  Widget construirBotaoEditar(
    LancamentoModel lancamento,
    HomeController controller,
  ) {
    return IconButton(
      onPressed: () {
        abrirTelaEditarLancamento(lancamento, controller);
      },
      tooltip: 'Editar lançamento',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(8),
      icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1E3A5F)),
    );
  }

  // ============================================================
  // BOTÃO EXCLUIR
  // ============================================================

  Widget construirBotaoExcluir(
    LancamentoModel lancamento,
    HomeController controller,
  ) {
    return IconButton(
      onPressed: () {
        confirmarExclusao(lancamento, controller);
      },
      tooltip: 'Excluir lançamento',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(8),
      icon: const Icon(
        Icons.delete_outline_rounded,
        size: 20,
        color: Colors.redAccent,
      ),
    );
  }

  // ============================================================
  // EDITAR LANÇAMENTO
  // ============================================================

  Future<void> abrirTelaEditarLancamento(
    LancamentoModel lancamento,
    HomeController controller,
  ) async {
    LancamentoModel? lancamentoAtualizado =
        await Navigator.push<LancamentoModel>(
          context,
          MaterialPageRoute(builder: construirTelaEditarLancamento(lancamento)),
        );

    if (!mounted) {
      return;
    }

    if (lancamentoAtualizado == null) {
      return;
    }

    try {
      await controller.editarLancamento(lancamentoAtualizado);

      if (!mounted) {
        return;
      }

      mostrarMensagem('Lançamento atualizado com sucesso.');
    } catch (erro) {
      debugPrint('ERRO AO EDITAR LANÇAMENTO: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível atualizar o lançamento.');
    }
  }

  WidgetBuilder construirTelaEditarLancamento(LancamentoModel lancamento) {
    Widget construirTela(BuildContext contexto) {
      return TelaEditarLancamento(lancamento: lancamento);
    }

    return construirTela;
  }

  // ============================================================
  // EXCLUIR LANÇAMENTO
  // ============================================================

  Future<void> confirmarExclusao(
    LancamentoModel lancamento,
    HomeController controller,
  ) async {
    bool? confirmouExclusao = await showDialog<bool>(
      context: context,
      builder: (BuildContext contextoDialogo) {
        return AlertDialog(
          title: const Text('Excluir lançamento?'),
          content: Text('Deseja realmente excluir "${lancamento.categoria}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(contextoDialogo, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmouExclusao != true) {
      return;
    }

    await controller.excluirLancamento(lancamento);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lançamento excluído com sucesso.')),
    );
  }

  // ============================================================
  // ESTADO VAZIO
  // ============================================================

  Widget construirEstadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 34, color: Colors.black38),

          SizedBox(height: 10),

          Text(
            'Nenhum lançamento nesta data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATA E HORA DO LANÇAMENTO
  // ============================================================

  Widget construirDataHoraLancamento(LancamentoModel lancamento) {
    if (lancamento.criadoEm == null) {
      return const SizedBox.shrink();
    }

    String dataFormatada = lancamento.obterDataFormatada();
    String horaFormatada = lancamento.obterHoraFormatada();

    return Row(
      children: [
        const Icon(Icons.schedule_outlined, size: 14, color: Colors.black45),

        const SizedBox(width: 4),

        Expanded(
          child: Text(
            '$dataFormatada • $horaFormatada',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MENSAGENS
  // ============================================================

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
