import 'package:flutter/material.dart';

class AcoesRapidasHome extends StatelessWidget {
  final VoidCallback aoAdicionarEntrada;
  final VoidCallback aoAdicionarDespesa;

  const AcoesRapidasHome({
    super.key,
    required this.aoAdicionarEntrada,
    required this.aoAdicionarDespesa,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        construirTitulo(),
        const SizedBox(height: 12),
        construirBotoes(),
      ],
    );
  }

  Widget construirTitulo() {
    return const Text(
      'Ações rápidas',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E3A5F),
      ),
    );
  }

  Widget construirBotoes() {
    return Row(
      children: [
        Expanded(child: construirBotaoEntrada()),
        const SizedBox(width: 12),
        Expanded(child: construirBotaoDespesa()),
      ],
    );
  }

  Widget construirBotaoEntrada() {
    return FilledButton(
      onPressed: aoAdicionarEntrada,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2E8B57),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_rounded),
          SizedBox(width: 8),
          Text('Entrada', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget construirBotaoDespesa() {
    return FilledButton(
      onPressed: aoAdicionarDespesa,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFE76F51),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_rounded),
          SizedBox(width: 8),
          Text('Despesa', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
