import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/controller/despesas_recorrentes_controller.dart';

import 'package:controle_gastos/models/despesa_mensal_model.dart';
import 'package:controle_gastos/models/despesa_recorrente_model.dart';

import 'package:controle_gastos/screens/recorrentes/tela_nova_despesa_recorrente.dart';
import 'package:controle_gastos/screens/recorrentes/tela_informar_valor_mensal.dart';
import 'package:controle_gastos/screens/recorrentes/tela_editar_despesa_recorrente.dart';
import 'package:controle_gastos/screens/recorrentes/tela_editar_despesa_mensal.dart';

import 'package:controle_gastos/widgets/recorrentes/resumo_recorrentes.dart';
import 'package:controle_gastos/widgets/recorrentes/item_despesa_recorrente.dart';

class TelaDespesasRecorrentes extends StatefulWidget {
  const TelaDespesasRecorrentes({super.key});

  @override
  State<TelaDespesasRecorrentes> createState() {
    return _TelaDespesasRecorrentesState();
  }
}

class _TelaDespesasRecorrentesState extends State<TelaDespesasRecorrentes> {
  final DateFormat formatoMes = DateFormat('MMMM yyyy', 'pt_BR');

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(executarCarregamentoInicial);
  }

  // ============================================================
  // EXECUTAR CARREGAMENTO APÓS PRIMEIRO FRAME
  // ============================================================

  void executarCarregamentoInicial(Duration tempo) {
    carregarDadosIniciais();
  }

  // ============================================================
  // CARREGAMENTO INICIAL
  // ============================================================

  Future<void> carregarDadosIniciais() async {
    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    await controller.carregarDespesasRecorrentes();

    await controller.carregarDados();
  }

  // ============================================================
  // NAVEGAÇÃO PARA NOVA DESPESA
  // ============================================================

  Future<void> abrirNovaDespesaRecorrente() async {
    bool? despesaFoiSalva = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: construirTelaNovaDespesa),
    );

    if (!mounted) {
      return;
    }

    if (despesaFoiSalva != true) {
      return;
    }

    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    await controller.carregarDespesasRecorrentes();

    await controller.carregarDados();

    await controller.carregarProximosVencimentos();
  }

  Widget construirTelaNovaDespesa(BuildContext contexto) {
    return const TelaNovaDespesaRecorrente();
  }

  // ============================================================
  // INFORMAR VALOR MENSAL
  // ============================================================

  Future<void> abrirTelaInformarValorMensal(
    DespesaRecorrenteModel despesa,
    DespesasRecorrentesController controller,
  ) async {
    double? valorInformado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: construirTelaInformarValorMensal(
          despesa,
          controller.mesSelecionado,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (valorInformado == null) {
      return;
    }

    DateTime dataVencimento = construirDataVencimento(
      controller.mesSelecionado,
      despesa.diaVencimento,
    );

    DespesaMensalModel despesaMensal = DespesaMensalModel(
      id: '',
      idDespesaRecorrente: despesa.id,
      nome: despesa.nome,
      categoria: despesa.categoria,
      valor: valorInformado,
      dataVencimento: dataVencimento,
      estaPaga: false,
      dataPagamento: null,
      idLancamento: null,
      observacao: despesa.observacao,
    );

    try {
      await controller.adicionarDespesaMensal(despesaMensal);

      if (!mounted) {
        return;
      }

      mostrarMensagem('Despesa do mês adicionada.');
    } catch (erro) {
      debugPrint('ERRO AO ADICIONAR DESPESA MENSAL: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível adicionar a despesa do mês.');
    }
  }

  // ============================================================
  // EDITAR DESPESA RECORRENTE
  // ============================================================

  Future<void> abrirTelaEditarDespesaRecorrente(
    DespesaRecorrenteModel despesa,
  ) async {
    bool? despesaFoiAlterada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: construirTelaEditarDespesaRecorrente(despesa)),
    );

    if (!mounted) {
      return;
    }

    if (despesaFoiAlterada != true) {
      return;
    }

    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    await controller.carregarDespesasRecorrentes();

    await controller.carregarDados();

    await controller.carregarProximosVencimentos();
  }

  WidgetBuilder construirTelaEditarDespesaRecorrente(
    DespesaRecorrenteModel despesa,
  ) {
    Widget construirTela(BuildContext contexto) {
      return TelaEditarDespesaRecorrente(despesa: despesa);
    }

    return construirTela;
  }

  // ============================================================
  // CONSTRUIR TELA INFORMAR VALOR
  // ============================================================

  WidgetBuilder construirTelaInformarValorMensal(
    DespesaRecorrenteModel despesa,
    DateTime mesSelecionado,
  ) {
    Widget construirTela(BuildContext contexto) {
      return TelaInformarValorMensal(
        despesaRecorrente: despesa,
        mesSelecionado: mesSelecionado,
      );
    }

    return construirTela;
  }

  // ============================================================
  // EDITAR COMPROMISSO DO MÊS
  // ============================================================

  Future<void> abrirTelaEditarDespesaMensal(
    DespesaMensalModel despesa,
    DespesasRecorrentesController controller,
  ) async {
    DespesaMensalModel? despesaAtualizada =
        await Navigator.push<DespesaMensalModel>(
          context,
          MaterialPageRoute(builder: construirTelaEditarDespesaMensal(despesa)),
        );

    if (!mounted) {
      return;
    }

    if (despesaAtualizada == null) {
      return;
    }

    try {
      await controller.editarDespesaMensal(despesaAtualizada);

      if (!mounted) {
        return;
      }

      mostrarMensagem('Compromisso atualizado com sucesso.');
    } catch (erro) {
      debugPrint('ERRO AO EDITAR COMPROMISSO DO MÊS: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível atualizar o compromisso.');
    }
  }

  // ============================================================
  // CONSTRUIR TELA DE EDIÇÃO DO COMPROMISSO
  // ============================================================

  WidgetBuilder construirTelaEditarDespesaMensal(DespesaMensalModel despesa) {
    Widget construirTela(BuildContext contexto) {
      return TelaEditarDespesaMensal(despesa: despesa);
    }

    return construirTela;
  }

  // ============================================================
  // CONSTRUIR DATA DE VENCIMENTO
  // ============================================================

  DateTime construirDataVencimento(DateTime mesSelecionado, int diaVencimento) {
    int ultimoDiaDoMes = DateTime(
      mesSelecionado.year,
      mesSelecionado.month + 1,
      0,
    ).day;

    int diaAjustado = diaVencimento;

    if (diaAjustado > ultimoDiaDoMes) {
      diaAjustado = ultimoDiaDoMes;
    }

    DateTime dataVencimento = DateTime(
      mesSelecionado.year,
      mesSelecionado.month,
      diaAjustado,
    );

    return dataVencimento;
  }

  // ============================================================
  // PAGAMENTO
  // ============================================================

  Future<void> iniciarPagamento(
    DespesaMensalModel despesa,
    DespesasRecorrentesController controller,
  ) async {
    DateTime dataAtual = DateTime.now();

    DateTime? dataPagamento = await showDatePicker(
      context: context,
      initialDate: dataAtual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (!mounted) {
      return;
    }

    if (dataPagamento == null) {
      return;
    }

    try {
      await controller.marcarDespesaComoPaga(despesa, dataPagamento);

      if (!mounted) {
        return;
      }

      mostrarMensagem('${despesa.nome} foi marcada como paga.');
    } catch (erro) {
      debugPrint('ERRO AO REGISTRAR PAGAMENTO: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível registrar o pagamento.');
    }
  }

  // ============================================================
  // DESFAZER PAGAMENTO
  // ============================================================

  Future<void> iniciarDesfazerPagamento(
    DespesaMensalModel despesa,
    DespesasRecorrentesController controller,
  ) async {
    try {
      await controller.desfazerPagamento(despesa);

      if (!mounted) {
        return;
      }

      mostrarMensagem('Pagamento de ${despesa.nome} desfeito.');
    } catch (erro) {
      debugPrint('ERRO AO DESFAZER PAGAMENTO: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível desfazer o pagamento.');
    }
  }

  // ============================================================
  // MENSAGENS
  // ============================================================

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // ============================================================
  // CONSTRUÇÃO DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Despesas recorrentes')),
      body: construirConteudo(controller),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirNovaDespesaRecorrente,
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Nova despesa',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ============================================================
  // CONTEÚDO PRINCIPAL
  // ============================================================

  Widget construirConteudo(DespesasRecorrentesController controller) {
    if (controller.estaCarregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        construirCabecalhoMes(controller),

        const SizedBox(height: 20),

        construirTituloRecorrencias(),

        const SizedBox(height: 12),

        construirListaRecorrencias(controller),

        const SizedBox(height: 24),

        ResumoRecorrentes(
          totalPrevisto: controller.totalPrevisto,
          totalPago: controller.totalPago,
          totalPendente: controller.totalPendente,
        ),

        const SizedBox(height: 24),

        construirTituloDespesas(),

        const SizedBox(height: 12),

        construirListaDespesas(controller),
      ],
    );
  }

  // ============================================================
  // CABEÇALHO DO MÊS
  // ============================================================

  Widget construirCabecalhoMes(DespesasRecorrentesController controller) {
    String mesFormatado = formatoMes.format(controller.mesSelecionado);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: voltarMes,
          tooltip: 'Mês anterior',
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 30,
            color: Color(0xFF1E3A5F),
          ),
        ),

        Expanded(
          child: Text(
            mesFormatado,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ),

        IconButton(
          onPressed: avancarMes,
          tooltip: 'Próximo mês',
          icon: const Icon(
            Icons.chevron_right_rounded,
            size: 30,
            color: Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VOLTAR MÊS
  // ============================================================

  Future<void> voltarMes() async {
    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    DateTime mesAtual = controller.mesSelecionado;

    DateTime mesAnterior = DateTime(mesAtual.year, mesAtual.month - 1, 1);

    await controller.alterarMesSelecionado(mesAnterior);
  }

  // ============================================================
  // AVANÇAR MÊS
  // ============================================================

  Future<void> avancarMes() async {
    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    DateTime mesAtual = controller.mesSelecionado;

    DateTime proximoMes = DateTime(mesAtual.year, mesAtual.month + 1, 1);

    await controller.alterarMesSelecionado(proximoMes);
  }
  // ============================================================
  // TÍTULO DAS RECORRÊNCIAS
  // ============================================================

  Widget construirTituloRecorrencias() {
    return const Text(
      'Despesas cadastradas',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E3A5F),
      ),
    );
  }

  // ============================================================
  // LISTA DAS RECORRÊNCIAS
  // ============================================================

  Widget construirListaRecorrencias(DespesasRecorrentesController controller) {
    if (controller.despesasRecorrentes.isEmpty) {
      return construirEstadoVazioRecorrencias();
    }

    List<Widget> itens = [];

    for (DespesaRecorrenteModel despesa in controller.despesasRecorrentes) {
      Widget item = construirItemRecorrencia(despesa, controller);

      itens.add(item);

      itens.add(const SizedBox(height: 10));
    }

    return Column(children: itens);
  }

  // ============================================================
  // ITEM DE RECORRÊNCIA
  // ============================================================

  Widget construirItemRecorrencia(
    DespesaRecorrenteModel despesa,
    DespesasRecorrentesController controller,
  ) {
    void abrirValorMensal() {
      abrirTelaInformarValorMensal(despesa, controller);
    }

    void editarRecorrencia() {
      abrirTelaEditarDespesaRecorrente(despesa);
    }

    return InkWell(
      onTap: abrirValorMensal,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F3F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.repeat_rounded, color: Color(0xFF1E3A5F)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    despesa.nome,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${despesa.categoria} • vence dia ${despesa.diaVencimento}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: editarRecorrencia,
              tooltip: 'Editar recorrência',
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E3A5F)),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO VAZIO DAS RECORRÊNCIAS
  // ============================================================

  Widget construirEstadoVazioRecorrencias() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.repeat_rounded, size: 30, color: Colors.black38),

          SizedBox(height: 8),

          Text(
            'Nenhuma despesa recorrente cadastrada.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO DAS DESPESAS DO MÊS
  // ============================================================

  Widget construirTituloDespesas() {
    return const Text(
      'Compromissos do mês',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E3A5F),
      ),
    );
  }

  // ============================================================
  // LISTA DE DESPESAS DO MÊS
  // ============================================================

  Widget construirListaDespesas(DespesasRecorrentesController controller) {
    if (controller.despesasDoMes.isEmpty) {
      return construirEstadoVazioDespesasDoMes();
    }

    List<Widget> itens = [];

    for (DespesaMensalModel despesa in controller.despesasDoMes) {
      void pagarDespesa() {
        iniciarPagamento(despesa, controller);
      }

      void desfazerPagamento() {
        iniciarDesfazerPagamento(despesa, controller);
      }

      void editarCompromisso() {
        abrirTelaEditarDespesaMensal(despesa, controller);
      }

      ItemDespesaRecorrente item = ItemDespesaRecorrente(
        despesa: despesa,
        aoPagar: pagarDespesa,
        aoDesfazerPagamento: desfazerPagamento,
        aoEditar: editarCompromisso,
      );

      itens.add(item);

      itens.add(const SizedBox(height: 10));
    }

    return Column(children: itens);
  }

  // ============================================================
  // ESTADO VAZIO DAS DESPESAS DO MÊS
  // ============================================================

  Widget construirEstadoVazioDespesasDoMes() {
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
            'Nenhuma despesa lançada neste mês.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
