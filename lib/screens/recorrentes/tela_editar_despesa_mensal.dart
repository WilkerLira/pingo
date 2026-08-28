import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/models/despesa_mensal_model.dart';

class TelaEditarDespesaMensal extends StatefulWidget {
  final DespesaMensalModel despesa;

  const TelaEditarDespesaMensal({super.key, required this.despesa});

  @override
  State<TelaEditarDespesaMensal> createState() {
    return _TelaEditarDespesaMensalState();
  }
}

class _TelaEditarDespesaMensalState extends State<TelaEditarDespesaMensal> {
  late final TextEditingController controladorValor;

  late DateTime dataVencimento;

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();

    prepararDadosIniciais();
  }

  void prepararDadosIniciais() {
    controladorValor = TextEditingController(
      text: formatarMoeda(widget.despesa.valor),
    );

    dataVencimento = widget.despesa.dataVencimento;
  }

  // ============================================================
  // ENCERRAMENTO
  // ============================================================

  @override
  void dispose() {
    controladorValor.dispose();

    super.dispose();
  }

  // ============================================================
  // CONSTRUÇÃO DA TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Editar compromisso')),
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
        construirInformacoes(),

        const SizedBox(height: 24),

        construirCampoValor(),

        const SizedBox(height: 18),

        construirCampoVencimento(),

        const SizedBox(height: 28),

        construirBotaoSalvar(),
      ],
    );
  }

  // ============================================================
  // INFORMAÇÕES DA DESPESA
  // ============================================================

  Widget construirInformacoes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.despesa.nome,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A5F),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            widget.despesa.categoria,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
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
        labelText: 'Valor deste mês',
        border: OutlineInputBorder(),
      ),
    );
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
    double? novoValor = converterTextoParaValor(controladorValor.text);

    if (novoValor == null || novoValor <= 0) {
      mostrarMensagem('Informe um valor válido.');

      return;
    }

    DespesaMensalModel despesaAtualizada = DespesaMensalModel(
      id: widget.despesa.id,
      idDespesaRecorrente: widget.despesa.idDespesaRecorrente,
      nome: widget.despesa.nome,
      categoria: widget.despesa.categoria,
      valor: novoValor,
      dataVencimento: dataVencimento,
      estaPaga: widget.despesa.estaPaga,
      dataPagamento: widget.despesa.dataPagamento,
      idLancamento: widget.despesa.idLancamento,
      observacao: widget.despesa.observacao,
    );

    Navigator.pop(context, despesaAtualizada);
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
