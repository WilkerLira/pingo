import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/models/despesa_recorrente_model.dart';
import 'package:flutter/services.dart';

class TelaInformarValorMensal extends StatefulWidget {
  final DespesaRecorrenteModel despesaRecorrente;
  final DateTime mesSelecionado;

  const TelaInformarValorMensal({
    super.key,
    required this.despesaRecorrente,
    required this.mesSelecionado,
  });

  @override
  State<TelaInformarValorMensal> createState() {
    return _TelaInformarValorMensalState();
  }
}

class _TelaInformarValorMensalState extends State<TelaInformarValorMensal> {
  final TextEditingController controladorValor = TextEditingController();

  final DateFormat formatoMes = DateFormat('MMMM yyyy', 'pt_BR');

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
      appBar: AppBar(title: const Text('Informar valor')),
      body: construirConteudo(),
    );
  }

  // ============================================================
  // CONTEÚDO PRINCIPAL
  // ============================================================

  Widget construirConteudo() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        construirInformacoesDespesa(),

        const SizedBox(height: 24),

        construirCampoValor(),

        const SizedBox(height: 28),

        construirBotaoConfirmar(),
      ],
    );
  }

  // ============================================================
  // INFORMAÇÕES DA DESPESA
  // ============================================================

  Widget construirInformacoesDespesa() {
    String mesFormatado = formatoMes.format(widget.mesSelecionado);

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
            widget.despesaRecorrente.nome,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A5F),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.despesaRecorrente.categoria,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 4),

          Text(
            'Vencimento: dia ${widget.despesaRecorrente.diaVencimento}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 4),

          Text(
            'Referência: $mesFormatado',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
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
        hintText: 'R\$ 0,00',
        border: OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // BOTÃO CONFIRMAR
  // ============================================================

  Widget construirBotaoConfirmar() {
    return FilledButton(
      onPressed: confirmarValor,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A5F),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: const Text(
        'Confirmar valor',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  // ============================================================
  // CONFIRMAR VALOR
  // ============================================================

  void confirmarValor() {
    String textoValor = controladorValor.text.trim();

    if (textoValor.isEmpty) {
      mostrarMensagem('Informe o valor da despesa.');

      return;
    }

    String valorPreparado = textoValor
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    double? valor = double.tryParse(valorPreparado);

    if (valor == null || valor <= 0) {
      mostrarMensagem('Informe um valor válido.');

      return;
    }

    Navigator.pop(context, valor);
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
