import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/models/despesa_mensal_model.dart';

class ProximosVencimentosHome extends StatelessWidget {
  final List<DespesaMensalModel> vencimentos;

  const ProximosVencimentosHome({super.key, required this.vencimentos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        construirCabecalho(),

        const SizedBox(height: 12),

        construirConteudo(),
      ],
    );
  }

  Widget construirCabecalho() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Próximos vencimentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A5F),
          ),
        ),

        Icon(Icons.calendar_month_outlined, color: Color(0xFF1E3A5F), size: 21),
      ],
    );
  }

  Widget construirConteudo() {
    if (vencimentos.isEmpty) {
      return construirEstadoVazio();
    }

    List<Widget> itens = [];

    for (DespesaMensalModel despesa in vencimentos) {
      Widget card = construirCardVencimento(despesa);

      itens.add(card);

      itens.add(const SizedBox(height: 10));
    }

    return Column(children: itens);
  }

  Widget construirEstadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            color: Color(0xFF8A8A8A),
            size: 30,
          ),

          SizedBox(height: 8),

          Text(
            'Nenhum vencimento próximo.',
            style: TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget construirCardVencimento(DespesaMensalModel despesa) {
    Color corStatus = obterCorStatus(despesa);

    String textoStatus = obterTextoStatus(despesa);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          construirIcone(),

          const SizedBox(width: 12),

          Expanded(child: construirInformacoes(despesa)),

          construirStatus(textoStatus, corStatus),
        ],
      ),
    );
  }

  Widget construirIcone() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F3F7),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF1E3A5F)),
    );
  }

  Widget construirInformacoes(DespesaMensalModel despesa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          despesa.nome,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF303030),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          formatarMoeda(despesa.valor),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A5F),
          ),
        ),

        const SizedBox(height: 3),

        Text(
          formatarVencimento(despesa.dataVencimento),
          style: const TextStyle(color: Color(0xFF808080), fontSize: 12),
        ),
      ],
    );
  }

  Widget construirStatus(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color obterCorStatus(DespesaMensalModel despesa) {
    if (despesa.estaPaga) {
      return const Color(0xFF2E8B57);
    }

    return const Color(0xFFD49A18);
  }

  String obterTextoStatus(DespesaMensalModel despesa) {
    if (despesa.estaPaga) {
      return 'Pago';
    }

    return 'Pendente';
  }

  String formatarMoeda(double valor) {
    NumberFormat formato = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return formato.format(valor);
  }

  String formatarVencimento(DateTime data) {
    DateFormat formato = DateFormat('dd/MM/yyyy', 'pt_BR');

    String dataFormatada = formato.format(data);

    return 'Vence em $dataFormatada';
  }
}
