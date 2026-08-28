import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CabecalhoHome extends StatelessWidget {
  final DateTime dataSelecionada;
  final VoidCallback aoSelecionarData;

  const CabecalhoHome({
    super.key,
    required this.dataSelecionada,
    required this.aoSelecionarData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: construirSaudacao()),
        const SizedBox(width: 12),
        construirBotaoData(),
      ],
    );
  }

  Widget construirSaudacao() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, Wilker',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A5F),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Seu resumo financeiro',
          style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
        ),
      ],
    );
  }

  Widget construirBotaoData() {
    String dataFormatada = DateFormat(
      'MMM yyyy',
      'pt_BR',
    ).format(dataSelecionada);

    return OutlinedButton.icon(
      onPressed: aoSelecionarData,
      icon: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(dataFormatada),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1E3A5F),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
