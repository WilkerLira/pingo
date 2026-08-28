import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/controller/despesas_recorrentes_controller.dart';
import 'package:controle_gastos/models/despesa_recorrente_model.dart';

class TelaNovaDespesaRecorrente extends StatefulWidget {
  const TelaNovaDespesaRecorrente({super.key});

  @override
  State<TelaNovaDespesaRecorrente> createState() {
    return _TelaNovaDespesaRecorrenteState();
  }
}

class _TelaNovaDespesaRecorrenteState extends State<TelaNovaDespesaRecorrente> {
  final TextEditingController controladorNome = TextEditingController();

  final TextEditingController controladorObservacao = TextEditingController();

  String categoriaSelecionada = 'Moradia';

  DateTime dataVencimento = DateTime.now();

  final List<String> categorias = [
    'Moradia',
    'Alimentação',
    'Transporte',
    'Comunicação',
    'Financeiro',
    'Outros',
  ];

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
      appBar: AppBar(title: const Text('Nova despesa recorrente')),
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
        hintText: 'Ex: Aluguel, Luz, Internet',
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

  // ============================================================
  // ITENS DAS CATEGORIAS
  // ============================================================

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

  // ============================================================
  // ALTERAR CATEGORIA
  // ============================================================

  void alterarCategoria(String? novaCategoria) {
    if (novaCategoria == null) {
      return;
    }

    setState(() {
      categoriaSelecionada = novaCategoria;
    });
  }

  // ============================================================
  // CAMPO DATA DE VENCIMENTO
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
        child: Text(dataFormatada, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // ============================================================
  // SELECIONAR DATA DE VENCIMENTO
  // ============================================================

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
        hintText: 'Opcional',
        border: OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // BOTÃO SALVAR
  // ============================================================

  Widget construirBotaoSalvar() {
    return FilledButton(
      onPressed: salvarDespesa,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A5F),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: const Text(
        'Salvar despesa recorrente',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  // ============================================================
  // SALVAR DESPESA
  // ============================================================

  Future<void> salvarDespesa() async {
    String nome = controladorNome.text.trim();

    if (nome.isEmpty) {
      mostrarMensagem('Informe o nome da despesa.');

      return;
    }

    DespesaRecorrenteModel novaDespesa = DespesaRecorrenteModel(
      id: '',
      nome: nome,
      categoria: categoriaSelecionada,

      // A recorrência precisa apenas do dia.
      // O calendário é usado para facilitar a escolha.
      diaVencimento: dataVencimento.day,

      estaAtiva: true,
      observacao: controladorObservacao.text.trim(),
    );

    DespesasRecorrentesController controller =
        Provider.of<DespesasRecorrentesController>(context, listen: false);

    try {
      await controller.adicionarDespesaRecorrente(novaDespesa);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (erro) {
      debugPrint('ERRO NOVA DESPESA RECORRENTE: $erro');

      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível salvar a despesa.');
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
}
