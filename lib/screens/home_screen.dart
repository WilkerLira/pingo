import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:controle_gastos/controller/home_controller.dart';
import 'package:controle_gastos/controller/despesas_recorrentes_controller.dart';

import 'package:controle_gastos/screens/recorrentes/tela_despesas_recorrentes.dart';
import 'package:controle_gastos/screens/lancamentos/tela_lancamentos.dart';
import 'package:controle_gastos/screens/lancamentos/tela_adicionar_lancamento.dart';
import 'package:controle_gastos/screens/relatorios/tela_relatorios.dart';

import 'package:controle_gastos/widgets/home/cabecalho_home.dart';
import 'package:controle_gastos/widgets/home/cartao_saldo_home.dart';
import 'package:controle_gastos/widgets/home/acoes_rapidas_home.dart';
import 'package:controle_gastos/widgets/home/minha_renda_home.dart';
import 'package:controle_gastos/widgets/home/proximos_vencimentos_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(executarCarregamentoInicial);
  }

  void executarCarregamentoInicial(Duration tempo) {
    carregarDadosIniciais();
  }

  // ============================================================
  // CARREGAMENTO INICIAL
  // ============================================================

  void carregarDadosIniciais() {
    HomeController homeController = Provider.of<HomeController>(
      context,
      listen: false,
    );

    DespesasRecorrentesController despesasController =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    homeController.carregarDados();

    despesasController.carregarProximosVencimentos();
  }

  // ============================================================
  // ADICIONAR ENTRADA
  // ============================================================

  void adicionarEntrada() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: construirTelaAdicionarEntrada),
    );
  }

  Widget construirTelaAdicionarEntrada(BuildContext contexto) {
    return const TelaAdicionarLancamento(tipoLancamento: 'entrada');
  }

  // ============================================================
  // ADICIONAR SAÍDA
  // ============================================================

  void adicionarDespesa() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: construirTelaAdicionarSaida),
    );
  }

  Widget construirTelaAdicionarSaida(BuildContext contexto) {
    return const TelaAdicionarLancamento(tipoLancamento: 'saida');
  }

  void mostrarMensagemTemporaria(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // ============================================================
  // SELEÇÃO DE DATA
  // ============================================================

  Future<void> selecionarData() async {
    HomeController homeController = Provider.of<HomeController>(
      context,
      listen: false,
    );

    DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: homeController.dataSelecionada,
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

    await homeController.alterarDataSelecionada(novaData);
  }

  // ============================================================
  // NAVEGAÇÃO PARA DESPESAS RECORRENTES
  // ============================================================

  void abrirTelaDespesasRecorrentes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: construirTelaDespesasRecorrentes),
    );
  }

  Widget construirTelaDespesasRecorrentes(BuildContext contexto) {
    return const TelaDespesasRecorrentes();
  }

  // ============================================================
  // NAVEGAÇÃO PARA LANÇAMENTOS
  // ============================================================

  void abrirTelaLancamentos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: construirTelaLancamentos),
    );
  }

  Widget construirTelaLancamentos(BuildContext contexto) {
    return const TelaLancamentos();
  }

  // ============================================================
  // NAVEGAÇÃO PARA RELATÓRIOS
  // ============================================================

  void abrirTelaRelatorios() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: construirTelaRelatorios),
    );
  }

  Widget construirTelaRelatorios(BuildContext contexto) {
    return const TelaRelatorios();
  }

  // ============================================================
  // MENU ADICIONAR
  // ============================================================

  void abrirMenuAdicionar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: construirMenuAdicionar,
    );
  }

  // ============================================================
  // CONSTRUÇÃO DO MENU ADICIONAR
  // ============================================================

  Widget construirMenuAdicionar(BuildContext contexto) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adicionar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A5F),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'O que você deseja registrar?',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(height: 20),

          construirOpcaoMenuAdicionar(
            icone: Icons.add_circle_outline_rounded,
            titulo: 'Entrada',
            descricao: 'Registrar um novo ganho',
            aoSelecionar: selecionarAdicionarEntrada,
          ),

          const SizedBox(height: 10),

          construirOpcaoMenuAdicionar(
            icone: Icons.remove_circle_outline_rounded,
            titulo: 'Saída',
            descricao: 'Registrar uma nova despesa',
            aoSelecionar: selecionarAdicionarSaida,
          ),

          const SizedBox(height: 10),

          construirOpcaoMenuAdicionar(
            icone: Icons.autorenew_rounded,
            titulo: 'Despesa recorrente',
            descricao: 'Cadastrar um novo compromisso',
            aoSelecionar: selecionarAdicionarRecorrente,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPÇÃO DO MENU ADICIONAR
  // ============================================================

  Widget construirOpcaoMenuAdicionar({
    required IconData icone,
    required String titulo,
    required String descricao,
    required VoidCallback aoSelecionar,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: aoSelecionar,
        leading: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: const Color(0xFF1E3A5F)),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          descricao,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black38,
        ),
      ),
    );
  }

  // ============================================================
  // AÇÕES DO MENU ADICIONAR
  // ============================================================

  void selecionarAdicionarEntrada() {
    Navigator.pop(context);

    adicionarEntrada();
  }

  void selecionarAdicionarSaida() {
    Navigator.pop(context);

    adicionarDespesa();
  }

  void selecionarAdicionarRecorrente() {
    Navigator.pop(context);

    abrirTelaDespesasRecorrentes();
  }

  // ============================================================
  // NAVEGAÇÃO INFERIOR
  // ============================================================

  void alterarDestinoNavegacao(int indice) {
    if (indice == 0) {
      return;
    }

    if (indice == 1) {
      abrirTelaLancamentos();

      return;
    }

    if (indice == 2) {
      abrirMenuAdicionar();

      return;
    }

    if (indice == 3) {
      abrirTelaRelatorios();

      return;
    }

    if (indice == 4) {
      mostrarTelaEmConstrucao('Mais');
    }
  }

  void mostrarTelaEmConstrucao(String nomeTela) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nomeTela será desenvolvido em breve.')),
    );
  }

  // ============================================================
  // CONSTRUÇÃO DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Provider.of<HomeController>(context);

    DespesasRecorrentesController despesasController =
        Provider.of<DespesasRecorrentesController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: homeController.carregarDados,
          child: construirConteudoHome(homeController, despesasController),
        ),
      ),
      bottomNavigationBar: construirNavegacaoInferior(),
    );
  }

  // ============================================================
  // CONTEÚDO DA HOME
  // ============================================================

  Widget construirConteudoHome(
    HomeController homeController,
    DespesasRecorrentesController despesasController,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        // ------------------------------------------------------
        // 1. CABEÇALHO
        // ------------------------------------------------------

        CabecalhoHome(
          dataSelecionada: homeController.dataSelecionada,
          aoSelecionarData: selecionarData,
        ),

        const SizedBox(height: 22),

        // ------------------------------------------------------
        // 2. SALDO
        // ------------------------------------------------------
        CartaoSaldoHome(
          saldo: homeController.saldoDoDia,
          totalEntradas: homeController.totalEntradas,
          totalDespesas: homeController.totalDespesas,
          estaCarregando: homeController.estaCarregando,
        ),

        const SizedBox(height: 24),

        // ------------------------------------------------------
        // 3. AÇÕES RÁPIDAS
        // ------------------------------------------------------
        AcoesRapidasHome(
          aoAdicionarEntrada: adicionarEntrada,
          aoAdicionarDespesa: adicionarDespesa,
        ),

        const SizedBox(height: 28),

        // ------------------------------------------------------
        // 4. MINHA RENDA
        // ------------------------------------------------------
        MinhaRendaHome(
          valorUber: homeController.totalUber,
          valor99: homeController.total99,
          valorTaxi: homeController.totalTaxi,
        ),

        const SizedBox(height: 28),

        // ------------------------------------------------------
        // 5. PRÓXIMOS VENCIMENTOS
        // ------------------------------------------------------
        ProximosVencimentosHome(
          vencimentos: despesasController.proximosVencimentos,
        ),
      ],
    );
  }

  // ============================================================
  // BARRA DE NAVEGAÇÃO INFERIOR
  // ============================================================

  Widget construirNavegacaoInferior() {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: alterarDestinoNavegacao,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),

        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Lançamentos',
        ),

        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Adicionar',
        ),

        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: 'Relatórios',
        ),

        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'Mais',
        ),
      ],
    );
  }
}
