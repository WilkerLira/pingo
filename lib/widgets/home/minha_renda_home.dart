import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MinhaRendaHome extends StatelessWidget {
  final double valorUber;
  final double valor99;
  final double valorTaxi;

  const MinhaRendaHome({
    super.key,
    required this.valorUber,
    required this.valor99,
    required this.valorTaxi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        construirTitulo(),

        const SizedBox(height: 12),

        construirCards(),
      ],
    );
  }

  Widget construirTitulo() {
    return const Text(
      'Minha renda',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E3A5F),
      ),
    );
  }

  Widget construirCards() {
    return Row(
      children: [
        Expanded(
          child: construirCardFonte(
            titulo: 'Uber',
            valor: valorUber,
            icone: Icons.directions_car_outlined,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: construirCardFonte(
            titulo: '99',
            valor: valor99,
            icone: Icons.directions_car_filled_outlined,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: construirCardFonte(
            titulo: 'Táxi',
            valor: valorTaxi,
            icone: Icons.local_taxi_outlined,
          ),
        ),
      ],
    );
  }

  Widget construirCardFonte({
    required String titulo,
    required double valor,
    required IconData icone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: const Color(0xFF1E3A5F), size: 21),
          ),

          const SizedBox(height: 10),

          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            formatarMoeda(valor),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E8B57),
            ),
          ),
        ],
      ),
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
