import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/controller/despesas_recorrentes_controller.dart';
import 'package:controle_gastos/models/despesa_recorrente_model.dart';
import 'package:controle_gastos/models/despesa_mensal_model.dart';

class TelaEditarDespesaRecorrente extends StatefulWidget {
  final DespesaRecorrenteModel despesa;

  const TelaEditarDespesaRecorrente({super.key, required this.despesa});

  @override
  State<TelaEditarDespesaRecorrente> createState() {
    return _TelaEditarDespesaRecorrenteState();
  }
}

class _TelaEditarDespesaRecorrenteState
    extends State<TelaEditarDespesaRecorrente> {
  late final TextEditingController controladorNome;

  late final TextEditingController controladorObservacao;

  late String categoriaSelecionada;

  late DateTime dataVencimento;

  final List<String> categorias = [
    'Moradia',
    'Alimentação',
    'Transporte',
    'Comunicação',
    'Financeiro',
    'Outros',
  ];

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();

    prepararDadosIniciais();
  }

  void prepararDadosIniciais() {
    controladorNome = TextEditingController(text: widget.despesa.nome);

    controladorObservacao = TextEditingController(
      text: widget.despesa.observacao,
    );

    categoriaSelecionada = widget.despesa.categoria;

    DateTime hoje = DateTime.now();

    dataVencimento = DateTime(
      hoje.year,
      hoje.month,
      widget.despesa.diaVencimento,
    );
  }

  // ============================================================
  // ENCERRAMENTO
  // ============================================================

  @override
  void dispose() {
    controladorNome.dispose();
    controladorObservacao.dispose();

    super.dispose();
  }

  // ============================================================
  // CONSTRUÇÃO DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Editar despesa recorrente')),
      body: construirFormulario(),
    );
  }

  // ============================================================
  // FORMULÁRIO
  // ============================================================

  Widget construirFormulario() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        construirCampoNome(),

        const SizedBox(height: 18),

        construirCampoCategoria(),

        const SizedBox(height: 18),

        construirCampoVencimento(),

        const SizedBox(height: 18),

        construirCampoObservacao(),

        const SizedBox(height: 28),

        construirBotaoSalvar(),

        const SizedBox(height: 18),

        construirBotaoDesativar(),
      ],
    );
  }

  // ============================================================
  // CAMPO NOME
  // ============================================================

  Widget construirCampoNome() {
    return TextField(
      controller: controladorNome,
      decoration: const InputDecoration(
        labelText: 'Nome da despesa',
        border: OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // CAMPO CATEGORIA
  // ============================================================

  Widget construirCampoCategoria() {
    return DropdownButtonFormField<String>(
      initialValue: categoriaSelecionada,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
      ),
      items: construirItensCategorias(),
      onChanged: alterarCategoria,
    );
  }

  List<DropdownMenuItem<String>> construirItensCategorias() {
    List<DropdownMenuItem<String>> itens = [];

    for (String categoria in categorias) {
      DropdownMenuItem<String> item = DropdownMenuItem<String>(
        value: categoria,
        child: Text(categoria),
      );

      itens.add(item);
    }

    return itens;
  }

  void alterarCategoria(String? novaCategoria) {
    if (novaCategoria == null) {
      return;
    }

    setState(() {
      categoriaSelecionada = novaCategoria;
    });
  }

  // ============================================================
  // CAMPO VENCIMENTO
  // ============================================================

  Widget construirCampoVencimento() {
    DateFormat formatoData = DateFormat('dd/MM/yyyy', 'pt_BR');

    String dataFormatada = formatoData.format(dataVencimento);

    return InkWell(
      onTap: selecionarDataVencimento,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de vencimento',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_month_outlined),
        ),
        child: Text(dataFormatada),
      ),
    );
  }

  Future<void> selecionarDataVencimento() async {
    DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: dataVencimento,
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

    setState(() {
      dataVencimento = novaData;
    });
  }

  // ============================================================
  // CAMPO OBSERVAÇÃO
  // ============================================================

  Widget construirCampoObservacao() {
    return TextField(
      controller: controladorObservacao,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Observação',
        border: OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // BOTÃO SALVAR
  // ============================================================

  Widget construirBotaoSalvar() {
    return FilledButton(
      onPressed: salvarAlteracoes,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A5F),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: const Text(
        'Salvar alterações',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  // ============================================================
  // SALVAR ALTERAÇÕES
  // ============================================================

  Future<void> salvarAlteracoes() async {
    String nome = controladorNome.text.trim();

    if (nome.isEmpty) {
      mostrarMensagem('Informe o nome da despesa.');

      return;
    }

    DespesaRecorrenteModel despesaAtualizada = DespesaRecorrenteModel(
      id: widget.despesa.id,
      nome: nome,
      categoria: categoriaSelecionada,
      diaVencimento: dataVencimento.day,
      estaAtiva: true,
      observacao: controladorObservacao.text.trim(),
    );

    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    try {
      // ----------------------------------------------------------
      // 1. ATUALIZAR A RECORRÊNCIA
      // ----------------------------------------------------------

      await controller.editarDespesaRecorrente(despesaAtualizada);

      // ----------------------------------------------------------
      // 2. PROCURAR COMPROMISSO PENDENTE DO MÊS
      // ----------------------------------------------------------

      DespesaMensalModel? compromissoPendente = controller
          .buscarCompromissoPendente(despesaAtualizada.id);

      // ----------------------------------------------------------
      // 3. SE EXISTIR, PERGUNTAR SE DESEJA ATUALIZÁ-LO
      // ----------------------------------------------------------

      if (compromissoPendente != null) {
        bool atualizarCompromisso = await perguntarAtualizacaoCompromisso();

        if (!mounted) {
          return;
        }

        if (atualizarCompromisso) {
          await controller.atualizarCompromissoPendente(
            compromissoPendente,
            despesaAtualizada,
          );
        }
      }

      // ----------------------------------------------------------
      // 4. FECHAR A TELA DE EDIÇÃO
      // ----------------------------------------------------------

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (erro) {
      debugPrint('ERRO AO EDITAR DESPESA RECORRENTE: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível salvar as alterações.');
    }
  }

  // ============================================================
  // BOTÃO DESATIVAR
  // ============================================================

  Widget construirBotaoDesativar() {
    return OutlinedButton.icon(
      onPressed: confirmarDesativacao,
      icon: const Icon(Icons.block_outlined),
      label: const Text('Desativar recorrência'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE76F51),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // ============================================================
  // CONFIRMAR DESATIVAÇÃO
  // ============================================================

  Future<void> confirmarDesativacao() async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: construirDialogoDesativacao,
    );

    if (!mounted) {
      return;
    }

    if (confirmar != true) {
      return;
    }

    await desativarDespesa();
  }

  Widget construirDialogoDesativacao(BuildContext contexto) {
    return AlertDialog(
      title: const Text('Desativar recorrência?'),
      content: Text(
        'A despesa "${widget.despesa.nome}" deixará de aparecer '
        'nas recorrências ativas. O histórico mensal será mantido.',
      ),
      actions: [
        TextButton(
          onPressed: fecharDialogoSemConfirmar,
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: fecharDialogoConfirmando,
          child: const Text('Desativar'),
        ),
      ],
    );
  }

  void fecharDialogoSemConfirmar() {
    Navigator.pop(context, false);
  }

  void fecharDialogoConfirmando() {
    Navigator.pop(context, true);
  }

  // ============================================================
  // DESATIVAR DESPESA
  // ============================================================

  Future<void> desativarDespesa() async {
    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    try {
      await controller.desativarDespesaRecorrente(widget.despesa);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (erro) {
      debugPrint('ERRO AO DESATIVAR DESPESA RECORRENTE: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível desativar a recorrência.');
    }
  }

  // ============================================================
  // PERGUNTAR SOBRE COMPROMISSO PENDENTE
  // ============================================================

  Future<bool> perguntarAtualizacaoCompromisso() async {
    bool? resposta = await showDialog<bool>(
      context: context,
      builder: construirDialogoAtualizacaoCompromisso,
    );

    if (resposta == true) {
      return true;
    }

    return false;
  }

  Widget construirDialogoAtualizacaoCompromisso(BuildContext contexto) {
    return AlertDialog(
      title: const Text('Atualizar compromisso deste mês?'),
      content: const Text(
        'Existe um compromisso pendente deste mês ligado a esta recorrência. '
        'Deseja atualizar também nome, categoria e vencimento desse compromisso?',
      ),
      actions: [
        TextButton(
          onPressed: manterCompromissoAtual,
          child: const Text('Manter como está'),
        ),
        FilledButton(
          onPressed: atualizarCompromissoAtual,
          child: const Text('Atualizar'),
        ),
      ],
    );
  }

  void manterCompromissoAtual() {
    Navigator.pop(context, false);
  }

  void atualizarCompromissoAtual() {
    Navigator.pop(context, true);
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
