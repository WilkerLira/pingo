import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumoRecorrentes extends StatelessWidget {
  final double totalPrevisto;
  final double totalPago;
  final double totalPendente;

  const ResumoRecorrentes({
    super.key,
    required this.totalPrevisto,
    required this.totalPago,
    required this.totalPendente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          construirLinhaResumo(titulo: 'Previsto', valor: totalPrevisto),

          const SizedBox(height: 12),

          construirLinhaResumo(titulo: 'Pago', valor: totalPago),

          const SizedBox(height: 12),

          construirLinhaResumo(titulo: 'Pendente', valor: totalPendente),
        ],
      ),
    );
  }

  Widget construirLinhaResumo({required String titulo, required double valor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        Text(
          formatarMoeda(valor),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String formatarMoeda(double valor) {
    NumberFormat formato = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return formato.format(valor);
  }
}
