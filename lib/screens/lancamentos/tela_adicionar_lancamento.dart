import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:controle_gastos/controller/home_controller.dart';
import 'package:controle_gastos/models/lancamento_model.dart';

class TelaAdicionarLancamento extends StatefulWidget {
  final String tipoLancamento;

  const TelaAdicionarLancamento({super.key, required this.tipoLancamento});

  @override
  State<TelaAdicionarLancamento> createState() {
    return _TelaAdicionarLancamentoState();
  }
}

class _TelaAdicionarLancamentoState extends State<TelaAdicionarLancamento> {
  late final TextEditingController controladorValor;
  late final TextEditingController controladorObservacao;

  late String categoriaSelecionada;
  late DateTime dataSelecionada;

  bool estaSalvando = false;

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void initState() {
    super.initState();

    prepararDadosIniciais();
  }

  void prepararDadosIniciais() {
    controladorValor = TextEditingController();

    controladorObservacao = TextEditingController();

    dataSelecionada = DateTime.now();

    List<String> categorias = obterCategorias();

    categoriaSelecionada = categorias.first;
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
      appBar: AppBar(title: Text(obterTituloTela())),
      body: construirFormulario(),
    );
  }

  // ============================================================
  // TÍTULO DA TELA
  // ============================================================

  String obterTituloTela() {
    if (widget.tipoLancamento == 'entrada') {
      return 'Nova entrada';
    }

    return 'Nova saída';
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

    if (widget.tipoLancamento == 'entrada') {
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
    if (widget.tipoLancamento == 'entrada') {
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
      onPressed: obterAcaoBotaoSalvar(),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A5F),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: construirConteudoBotaoSalvar(),
    );
  }

  VoidCallback? obterAcaoBotaoSalvar() {
    if (estaSalvando) {
      return null;
    }

    return salvarLancamento;
  }

  Widget construirConteudoBotaoSalvar() {
    if (estaSalvando) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return const Text(
      'Salvar lançamento',
      style: TextStyle(fontWeight: FontWeight.w700),
    );
  }

  // ============================================================
  // SALVAR LANÇAMENTO
  // ============================================================

  Future<void> salvarLancamento() async {
    double? valor = converterTextoParaValor(controladorValor.text);

    if (valor == null || valor <= 0) {
      mostrarMensagem('Informe um valor válido.');

      return;
    }

    LancamentoModel novoLancamento = LancamentoModel(
      id: '',
      tipoLancamento: widget.tipoLancamento,
      categoria: categoriaSelecionada,
      valor: valor,
      data: dataSelecionada,
      observacao: controladorObservacao.text.trim(),
    );

    setState(() {
      estaSalvando = true;
    });

    try {
      HomeController homeController = Provider.of<HomeController>(
        context,
        listen: false,
      );

      await homeController.adicionarLancamento(novoLancamento);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (erro) {
      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível salvar o lançamento.');
    } finally {
      if (mounted) {
        setState(() {
          estaSalvando = false;
        });
      }
    }
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
