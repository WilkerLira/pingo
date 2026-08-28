# 🐧 Pingo

**Pingo** é um aplicativo de controle financeiro pessoal desenvolvido em **Flutter**, criado para tornar o acompanhamento da vida financeira mais simples, organizado e visual.

O aplicativo permite controlar entradas, despesas, contas recorrentes, compromissos pendentes e acompanhar a situação financeira através de relatórios semanais e mensais.

O projeto também representa uma experiência de **desenvolvimento colaborativo entre uma pessoa e Inteligência Artificial**, sendo construído por **Wilker Lira** com a participação do **Doc — ChatGPT (OpenAI)** durante o processo de planejamento, desenvolvimento, análise e evolução do aplicativo.

---

## 📱 Sobre o Pingo

A proposta do Pingo é responder de forma simples algumas perguntas importantes:

- Quanto dinheiro entrou?
- Quanto foi gasto?
- Para onde o dinheiro foi?
- Quais contas ainda precisam ser pagas?
- Quanto tenho disponível atualmente?
- Quanto deverá sobrar depois dos compromissos pendentes?
- Quanto da renda veio do trabalho?
- Quanto custa exercer essa atividade?

Para isso, o aplicativo organiza os lançamentos financeiros e transforma os dados registrados em informações fáceis de acompanhar.

---

## ✨ Principais funcionalidades

### 🏠 Dashboard

A tela inicial apresenta uma visão rápida da situação financeira do dia.

Entre as informações disponíveis estão:

- Saldo do dia
- Total de entradas
- Total de despesas
- Lançamentos recentes
- Resumo de ganhos
- Acesso rápido às principais funcionalidades

---

## 💰 Entradas

O Pingo permite registrar diferentes fontes de renda.

Entre as categorias disponíveis estão:

- Uber
- 99
- Táxi
- Outros

Cada lançamento pode armazenar informações como:

- Categoria
- Valor
- Data
- Horário de cadastro
- Observação

---

## 💸 Despesas

As despesas podem ser registradas e organizadas por categoria.

Entre as categorias utilizadas atualmente estão:

- Aluguel do veículo
- Combustível
- Alimentação
- Moradia
- Transporte
- Comunicação
- Financeiro
- Outros

Os lançamentos ficam armazenados no banco de dados e podem ser consultados e editados pelo aplicativo.

---

## 🔄 Despesas recorrentes

O Pingo possui um módulo específico para despesas que se repetem ao longo dos meses.

É possível:

- Cadastrar uma despesa recorrente
- Definir o dia de vencimento
- Informar o valor correspondente ao mês
- Acompanhar compromissos mensais
- Identificar contas pendentes
- Registrar o pagamento
- Desfazer um pagamento
- Navegar entre diferentes meses

O aplicativo diferencia a **regra recorrente** da **conta específica de determinado mês**.

Isso permite acompanhar corretamente despesas que existem todos os meses, mas que podem possuir valores diferentes.

---

## ✅ Controle de pagamentos

Uma despesa mensal pode permanecer como compromisso pendente até que seu pagamento seja registrado.

Quando o pagamento é realizado, o Pingo registra a movimentação correspondente entre os gastos.

Dessa forma, o aplicativo consegue diferenciar:

**Compromisso pendente**

Uma conta que ainda precisa ser paga.

**Despesa paga**

Um valor que já foi efetivamente registrado como saída financeira.

Essa separação é importante para evitar que uma mesma despesa seja contabilizada duas vezes.

---

## 📋 Lançamentos

A tela de lançamentos permite consultar as movimentações financeiras de uma determinada data.

Cada lançamento pode apresentar:

- Categoria
- Valor
- Data
- Horário
- Observação
- Tipo de movimentação

A tela também permite editar os lançamentos existentes.

---

## 📊 Relatórios

O Pingo possui uma área de relatórios que consolida os dados financeiros armazenados no Firestore.

Os relatórios podem ser visualizados por:

- Semana
- Mês

É possível navegar entre diferentes períodos para consultar o histórico financeiro.

---

## 💵 Resumo do período

O relatório apresenta:

- Entradas
- Despesas pagas
- Saldo atual
- Compromissos pendentes
- Saldo projetado

### Saldo atual

Representa o resultado considerando aquilo que efetivamente entrou e saiu:

```text
Saldo atual = Entradas - Despesas pagas
```

### Saldo projetado

Considera também os compromissos que ainda precisam ser pagos:

```text
Saldo projetado = Saldo atual - Compromissos pendentes
```

Isso permite visualizar não apenas a situação financeira atual, mas também uma projeção considerando as contas que ainda estão por vencer ou pagar.

---

## 📊 Para onde foi o dinheiro?

O relatório agrupa as despesas por categoria.

Cada categoria apresenta:

- Valor gasto
- Participação percentual nas despesas
- Barra horizontal de representação

Entre as categorias analisadas estão:

```text
Aluguel do veículo
Combustível
Alimentação
Moradia
Transporte
Comunicação
Financeiro
Outros
```

Essa visualização facilita a identificação dos principais destinos do dinheiro durante determinado período.

---

## 🚕 Custos do trabalho

O Pingo também separa despesas diretamente relacionadas à atividade profissional.

Atualmente são considerados:

```text
Aluguel do veículo
+
Combustível
=
Custos do trabalho
```

Isso permite visualizar quanto da renda obtida através do trabalho é consumida pelos principais custos necessários para exercer a atividade.

---

## 🚗 Renda do trabalho

As entradas provenientes de:

- Uber
- 99
- Táxi

são agrupadas para formar a renda relacionada ao trabalho.

O relatório apresenta:

```text
Uber
99
Táxi
──────────────
Renda bruta

Custos do trabalho
──────────────
Resultado do trabalho
```

O resultado é calculado através de:

```text
Resultado do trabalho =
Renda bruta - Custos do trabalho
```

O termo **Resultado do trabalho** é utilizado porque o cálculo representa uma análise prática da atividade e não uma apuração contábil formal de lucro líquido.

---

## 🧠 Regras financeiras

Uma parte importante do desenvolvimento do Pingo foi separar corretamente diferentes situações financeiras.

### Entrada

Dinheiro efetivamente recebido.

### Despesa paga

Dinheiro que efetivamente saiu.

### Compromisso pendente

Conta conhecida, mas que ainda não foi paga.

### Saldo atual

```text
Entradas - Despesas pagas
```

### Saldo projetado

```text
Saldo atual - Compromissos pendentes
```

Essa estrutura permite que o aplicativo apresente tanto a situação atual quanto uma visão mais realista dos compromissos futuros.

---

## 🛠️ Tecnologias utilizadas

O Pingo utiliza:

- **Flutter**
- **Dart**
- **Firebase**
- **Cloud Firestore**
- **Provider**
- **Intl**
- **Material Design 3**

---

## 🏗️ Arquitetura

O projeto foi progressivamente organizado para separar as diferentes responsabilidades do aplicativo.

Estrutura simplificada:

```text
lib/
│
├── controller/
│   ├── home_controller.dart
│   ├── despesas_recorrentes_controller.dart
│   └── relatorios_controller.dart
│
├── models/
│
├── screens/
│   ├── home/
│   ├── lancamentos/
│   ├── recorrentes/
│   └── relatorios/
│
├── services/
│   └── servico_lancamentos.dart
│
├── widgets/
│
├── firebase_options.dart
│
└── main.dart
```

De forma geral:

**Controllers**

Gerenciam estados e regras necessárias para as telas.

**Models**

Representam os dados utilizados pelo aplicativo.

**Services**

Concentram operações relacionadas ao acesso e persistência dos dados.

**Screens**

Representam as diferentes telas do Pingo.

**Widgets**

Permitem separar e reutilizar componentes da interface.

---

## ☁️ Banco de dados

O Pingo utiliza **Firebase Cloud Firestore** para persistência dos dados.

Entre as coleções utilizadas pelo aplicativo estão:

```text
ganhos
gastos
despesas_recorrentes
despesas_mensais
```

A separação entre essas coleções permite diferenciar lançamentos realizados, regras recorrentes e compromissos específicos de cada mês.

---

## 🧪 Qualidade do código

Durante o desenvolvimento, o projeto utiliza as ferramentas de análise do Flutter para identificar problemas no código:

```bash
flutter analyze
```

O desenvolvimento também é realizado de maneira incremental, testando as funcionalidades após alterações importantes.

---

## 📱 Identidade

**Nome:** Pingo

**Mascote:** Pinguim 🐧

**Categoria:** Controle financeiro pessoal

O nome interno do projeto Flutter permanece:

```text
controle_gastos
```

Enquanto o nome apresentado ao usuário no aplicativo é:

```text
Pingo
```

---

## 🤖 Desenvolvimento com Inteligência Artificial

O **Pingo foi desenvolvido com participação de Inteligência Artificial durante o projeto**.

O desenvolvimento foi realizado através da colaboração entre:

### 👨‍💻 Wilker Lira

Responsável pela idealização do Pingo, definição das necessidades, funcionalidades, regras de funcionamento, decisões de interface, testes e direção do projeto.

### 🤖 Doc — ChatGPT (OpenAI)

Participou como assistente de Inteligência Artificial durante o desenvolvimento do projeto, auxiliando na análise das ideias, planejamento técnico, desenvolvimento e revisão do código, identificação de problemas, depuração e evolução da arquitetura e das funcionalidades.

A participação da IA esteve presente em diferentes etapas do desenvolvimento, incluindo:

- Discussão e transformação das ideias em funcionalidades
- Planejamento das implementações
- Estruturação do projeto Flutter
- Organização da arquitetura
- Desenvolvimento e revisão de código Dart
- Criação e evolução dos Controllers
- Organização de Models, Services, Screens e Widgets
- Integração com Firebase/Firestore
- Desenvolvimento das regras de negócio
- Implementação do controle de despesas recorrentes
- Implementação dos compromissos mensais
- Desenvolvimento dos relatórios financeiros
- Identificação e correção de erros
- Análise de problemas de interface e layout
- Discussão sobre experiência de uso
- Refatoração e melhoria da organização do código
- Apoio no processo de aprendizado durante o desenvolvimento

O processo aconteceu de forma iterativa:

```text
Ideia
  ↓
Discussão
  ↓
Planejamento
  ↓
Implementação
  ↓
Teste
  ↓
Correção
  ↓
Nova evolução
```

**Wilker conduziu o produto e suas decisões, enquanto Doc participou como IA assistente no processo técnico de transformar essas ideias em funcionalidades implementadas no Pingo.**

A utilização de IA, portanto, não foi apenas uma ferramenta pontual para geração de código, mas fez parte do processo de desenvolvimento e aprendizado utilizado na construção do projeto.

---

## 🎯 Objetivo do projeto

O Pingo nasceu como uma ferramenta para resolver uma necessidade prática de controle financeiro.

Durante seu desenvolvimento, também se tornou um projeto de aprendizado, permitindo trabalhar conceitos como:

- Programação orientada a objetos
- Flutter e Dart
- Gerenciamento de estado
- Arquitetura de aplicações
- Separação de responsabilidades
- Componentização
- Persistência de dados
- Firebase/Firestore
- Regras de negócio
- Interfaces responsivas
- Depuração
- Refatoração
- Desenvolvimento assistido por Inteligência Artificial

---

## 🚧 Status

O **Pingo está em desenvolvimento**.

A versão atual já possui as principais funcionalidades planejadas para sua primeira versão:

```text
Dashboard
✓

Entradas e despesas
✓

Lançamentos
✓

Despesas recorrentes
✓

Compromissos mensais
✓

Controle de pagamentos
✓

Relatórios semanais
✓

Relatórios mensais
✓

Saldo projetado
✓

Análise de despesas
✓

Análise da renda do trabalho
✓
```

O projeto continuará podendo receber melhorias e novas funcionalidades em versões futuras.

---

## 👨‍💻🤖 Autoria e colaboração

**Pingo**

Idealização, desenvolvimento e direção do projeto:

**Wilker Lira**

Desenvolvimento assistido por Inteligência Artificial:

**Doc — ChatGPT (OpenAI)**

O Pingo representa também uma experiência prática de desenvolvimento em que **ideias humanas, decisões sobre o produto e aprendizado foram combinados com assistência de Inteligência Artificial durante a construção do software**.

---

## 📄 Licença

Este projeto é destinado atualmente a **uso pessoal e educacional**.