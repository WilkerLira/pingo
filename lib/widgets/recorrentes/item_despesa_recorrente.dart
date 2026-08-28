import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:controle_gastos/models/despesa_mensal_model.dart';

class ItemDespesaRecorrente extends StatelessWidget {
  final DespesaMensalModel despesa;

  final VoidCallback aoPagar;
  final VoidCallback aoDesfazerPagamento;
  final VoidCallback? aoEditar;

  const ItemDespesaRecorrente({
    super.key,
    required this.despesa,
    required this.aoPagar,
    required this.aoDesfazerPagamento,
    this.aoEditar,
  });

  // ============================================================
  // CONSTRUÇÃO DO ITEM
  // ============================================================

  // ============================================================
  // CONSTRUÇÃO DO ITEM
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: obterCorDaBorda(), width: 1.5),
      ),
      child: Column(
        children: [
          construirLinhaPrincipal(),

          const SizedBox(height: 12),

          construirAreaStatus(),
        ],
      ),
    );
  }

  // ============================================================
  // LINHA PRINCIPAL
  // ============================================================

  Widget construirLinhaPrincipal() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: construirInformacoes()),

        const SizedBox(width: 12),

        construirValorEAcoes(),
      ],
    );
  }

  // ============================================================
  // INFORMAÇÕES DA DESPESA
  // ============================================================

  Widget construirInformacoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          despesa.nome,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 4),

        Text(
          despesa.categoria,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),

        const SizedBox(height: 4),

        Text(
          formatarVencimento(),
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  // ============================================================
  // VALOR E AÇÕES
  // ============================================================

  Widget construirValorEAcoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatarMoeda(despesa.valor),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A5F),
          ),
        ),

        if (!despesa.estaPaga && aoEditar != null) construirBotaoEditar(),
      ],
    );
  }

  // ============================================================
  // BOTÃO EDITAR
  // ============================================================

  Widget construirBotaoEditar() {
    return IconButton(
      onPressed: aoEditar,
      tooltip: 'Editar compromisso',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1E3A5F)),
    );
  }

  // ============================================================
  // ÁREA DE STATUS
  // ============================================================

  Widget construirAreaStatus() {
    if (despesa.estaPaga) {
      return construirStatusPago();
    }

    return construirBotaoPagar();
  }

  // ============================================================
  // BOTÃO PAGAR
  // ============================================================

  Widget construirBotaoPagar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        construirStatusPendente(),

        FilledButton.icon(
          onPressed: aoPagar,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Pagar'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS PENDENTE
  // ============================================================

  Widget construirStatusPendente() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD49A18).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Pendente',
        style: TextStyle(
          color: Color(0xFFD49A18),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS PAGO
  // ============================================================

  Widget construirStatusPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B57).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Pago',
                style: TextStyle(
                  color: Color(0xFF2E8B57),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Text(
              obterTextoDataPagamento(),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: aoDesfazerPagamento,
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Desfazer pagamento'),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COR DA BORDA
  // ============================================================

  Color obterCorDaBorda() {
    if (despesa.estaPaga) {
      return const Color(0xFF2E8B57);
    }

    return const Color(0xFFD49A18);
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
  // FORMATAR VENCIMENTO
  // ============================================================

  String formatarVencimento() {
    DateFormat formato = DateFormat('dd/MM/yyyy', 'pt_BR');

    String data = formato.format(despesa.dataVencimento);

    return 'Vence em $data';
  }

  // ============================================================
  // DATA DO PAGAMENTO
  // ============================================================

  String obterTextoDataPagamento() {
    if (despesa.dataPagamento == null) {
      return '';
    }

    DateFormat formato = DateFormat('dd/MM/yyyy', 'pt_BR');

    String data = formato.format(despesa.dataPagamento!);

    return 'Pago em $data';
  }
}
