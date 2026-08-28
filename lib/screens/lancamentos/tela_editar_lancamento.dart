import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/models/lancamento_model.dart';

class TelaEditarLancamento extends StatefulWidget {
  final LancamentoModel lancamento;

  const TelaEditarLancamento({super.key, required this.lancamento});

  @override
  State<TelaEditarLancamento> createState() {
    return _TelaEditarLancamentoState();
  }
}

class _TelaEditarLancamentoState extends State<TelaEditarLancamento> {
  late final TextEditingController controladorValor;

  late final TextEditingController controladorObservacao;

  late String categoriaSelecionada;

  late DateTime dataSelecionada;

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();

    prepararDadosIniciais();
  }

  void prepararDadosIniciais() {
    categoriaSelecionada = widget.lancamento.categoria;

    dataSelecionada = widget.lancamento.data;

    controladorValor = TextEditingController(
      text: formatarMoeda(widget.lancamento.valor),
    );

    controladorObservacao = TextEditingController(
      text: widget.lancamento.observacao ?? '',
    );
  }

  // ============================================================
  // ENCERRAMENTO
  // ============================================================

  @override
  void dispose() {
    controladorValor.dispose();
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
      appBar: AppBar(title: const Text('Editar lançamento')),
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
        construirTipoLancamento(),

        const SizedBox(height: 20),

        construirCampoCategoria(),

        const SizedBox(height: 18),

        construirCampoValor(),

        const SizedBox(height: 18),

        construirCampoData(),

        const SizedBox(height: 18),

        construirCampoObservacao(),

        const SizedBox(height: 28),

        construirBotaoSalvar(),
      ],
    );
  }

  // ============================================================
  // TIPO DO LANÇAMENTO
  // ============================================================

  Widget construirTipoLancamento() {
    String titulo = 'Saída';

    IconData icone = Icons.arrow_upward_rounded;

    if (widget.lancamento.tipoLancamento == 'entrada') {
      titulo = 'Entrada';

      icone = Icons.arrow_downward_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F3F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: const Color(0xFF1E3A5F)),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo do lançamento',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),

              const SizedBox(height: 3),

              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
        ],
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
      items: construirCategorias(),
      onChanged: alterarCategoria,
    );
  }

  List<DropdownMenuItem<String>> construirCategorias() {
    List<String> categorias = obterCategorias();

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

  List<String> obterCategorias() {
    if (widget.lancamento.tipoLancamento == 'entrada') {
      return ['Uber', '99', 'Táxi', 'Outros'];
    }

    return [
      'Combustível',
      'Aluguel do veículo',
      'Alimentação',
      'Moradia',
      'Transporte',
      'Comunicação',
      'Financeiro',
      'Outros',
    ];
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
  // CAMPO VALOR
  // ============================================================

  Widget construirCampoValor() {
    return TextField(
      controller: controladorValor,
      keyboardType: TextInputType.number,
      inputFormatters: [FormatadorMoedaBrasileira()],
      decoration: const InputDecoration(
        labelText: 'Valor',
        border: OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // CAMPO DATA
  // ============================================================

  Widget construirCampoData() {
    DateFormat formatoData = DateFormat('dd/MM/yyyy', 'pt_BR');

    String dataFormatada = formatoData.format(dataSelecionada);

    return InkWell(
      onTap: selecionarData,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_month_outlined),
        ),
        child: Text(dataFormatada),
      ),
    );
  }

  // ============================================================
  // SELECIONAR DATA
  // ============================================================

  Future<void> selecionarData() async {
    DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
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
      dataSelecionada = novaData;
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

  void salvarAlteracoes() {
    double? valor = converterTextoParaValor(controladorValor.text);

    if (valor == null || valor <= 0) {
      mostrarMensagem('Informe um valor válido.');

      return;
    }

    LancamentoModel lancamentoAtualizado = LancamentoModel(
      id: widget.lancamento.id,
      tipoLancamento: widget.lancamento.tipoLancamento,
      categoria: categoriaSelecionada,
      valor: valor,
      data: dataSelecionada,
      observacao: controladorObservacao.text.trim(),
    );

    Navigator.pop(context, lancamentoAtualizado);
  }

  // ============================================================
  // CONVERTER TEXTO PARA VALOR
  // ============================================================

  double? converterTextoParaValor(String texto) {
    String valorPreparado = texto
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(valorPreparado);
  }

  // ============================================================
  // FORMATAR MOEDA
  // ============================================================

  String formatarMoeda(double valor) {
    NumberFormat formato = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return formato.format(valor);
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

// ============================================================
// FORMATADOR DE MOEDA BRASILEIRA
// ============================================================

class FormatadorMoedaBrasileira extends TextInputFormatter {
  final NumberFormat formatoMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue valorAnterior,
    TextEditingValue novoValor,
  ) {
    String somenteNumeros = novoValor.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (somenteNumeros.isEmpty) {
      return const TextEditingValue(text: '');
    }

    double valor = double.parse(somenteNumeros) / 100;

    String textoFormatado = formatoMoeda.format(valor);

    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}
