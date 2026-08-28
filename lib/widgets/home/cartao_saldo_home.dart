import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartaoSaldoHome extends StatelessWidget {
  final double saldo;
  final double totalEntradas;
  final double totalDespesas;
  final bool estaCarregando;

  const CartaoSaldoHome({
    super.key,
    required this.saldo,
    required this.totalEntradas,
    required this.totalDespesas,
    required this.estaCarregando,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          construirTitulo(),

          const SizedBox(height: 10),

          construirSaldo(),

          const SizedBox(height: 24),

          construirResumoEntradasDespesas(),
        ],
      ),
    );
  }

  Widget construirTitulo() {
    return const Text(
      'Saldo do período',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget construirSaldo() {
    if (estaCarregando) {
      return const SizedBox(width: 120, child: LinearProgressIndicator());
    }

    return Text(
      formatarMoeda(saldo),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget construirResumoEntradasDespesas() {
    return Row(
      children: [
        Expanded(
          child: construirIndicador(
            titulo: 'Entradas',
            valor: totalEntradas,
            icone: Icons.arrow_upward_rounded,
            cor: const Color(0xFF74D3A4),
          ),
        ),

        Container(width: 1, height: 45, color: Colors.white24),

        Expanded(
          child: construirIndicador(
            titulo: 'Despesas',
            valor: totalDespesas,
            icone: Icons.arrow_downward_rounded,
            cor: const Color(0xFFFF8A80),
          ),
        ),
      ],
    );
  }

  Widget construirIndicador({
    required String titulo,
    required double valor,
    required IconData icone,
    required Color cor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: cor, size: 20),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 3),

              Text(
                formatarMoeda(valor),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String formatarMoeda(double valor) {
    NumberFormat formatoMoeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return formatoMoeda.format(valor);
  }
}
