# ⚙️ PDF OCR Portable Suite v1.0

### *A solução completa para transformar seu acervo de PDFs em uma base de conhecimento pesquisável.*

-----

## 🎯 O Problema

No ambiente corporativo, lidamos com centenas de documentos essenciais — atestados técnicos, relatórios, certidões — que são frequentemente digitalizados e salvos como PDFs. O problema é que a maioria desses arquivos são "imagens" estáticas, tornando impossível realizar uma simples busca por texto (`Ctrl+F`), copiar um parágrafo ou analisar dados em lote. Encontrar uma informação específica se torna um trabalho manual, lento e propenso a erros.

-----

## ✨ A Solução

A **PDF OCR Portable Suite** é uma aplicação de automação para Windows projetada para resolver exatamente esse desafio. Ela utiliza a tecnologia de Reconhecimento Óptico de Caracteres (OCR) para "ler" o conteúdo de seus PDFs baseados em imagem e transformá-los em documentos inteligentes e totalmente pesquisáveis.

> **O grande diferencial?** É uma solução **100% portátil e encapsulada**. Não há necessidade de instalar programas complexos ou configurar variáveis de ambiente no sistema. Basta descompactar a pasta e usar.

-----

## 🚀 Principais Recursos

  * **✅ Zero Instalação, Zero Complicação:** Totalmente portátil. Sem necessidade de privilégios de administrador ou configurações complexas de variáveis de ambiente.
  * **🧠 Inteligência "Out-of-the-Box":** Na primeira execução, o script descompacta e configura automaticamente suas próprias dependências. É só executar.
  * **🎛️ Painel de Controle Intuitivo:** Um menu claro guia o usuário através do fluxo de trabalho, tornando a ferramenta acessível para qualquer nível de conhecimento técnico.
  * **🌪️ Eficiência em Lote:** Projetado para processar diretórios inteiros de uma só vez, transformando dias de trabalho manual em minutos de processamento automático.
  * **🧹 Limpeza e Estruturação de Dados:** O texto extraído é automaticamente limpo de cabeçalhos repetitivos e formatado para máxima legibilidade, gerando um resultado coeso e profissional.
  * **↔️ Fluxo de Trabalho Completo:** Desde a conversão de PDFs brutos até a criação de uma base de conhecimento centralizada, a suíte cobre todo o ciclo de vida do seu acervo documental.

-----

## 🎬 Demonstração

A ferramenta é controlada por um painel de controle simples e intuitivo no terminal.

```bash
> Programa.bat

Verificando dependencias...
Pasta 'tesseract' nao encontrada. Extraindo de S:\...\bin\tesseract.zip...
Pasta 'ghostscript' nao encontrada. Extraindo de S:\...\bin\ghostscript.zip...
Ambiente virtual ativado.

====================================================================
                 PAINEL DE CONTROLE DE DOCUMENTOS
====================================================================

Escolha uma das opcoes abaixo:

  [1] Converter PDFs para formato PESQUISAVEL
      (Le da pasta '01 - PDFs para convercao' e salva em '02 - PDFs Pesquisaveis')

  [2] EXTRAIR Texto dos PDFs Pesquisaveis para um unico arquivo .txt
      (Le da pasta '02 - PDFs Pesquisaveis' e salva em '03 - Dados')

  [3] Executar TUDO (Converte e depois Extrai - Processo completo)

  [4] Sair

====================================================================

Digite o numero da sua escolha: 3
```

-----

## workflow Fluxo de Trabalho Visual

O processo é dividido em etapas claras, utilizando as pastas numeradas do projeto:

| Pasta de Origem            | Ação no `Programa.bat`  | Pasta de Destino               |
| :------------------------- | :---------------------- | :----------------------------- |
| `01 - PDFs para convercao` | **Opção [1]** Converter | `02 - PDFs Pesquisaveis`       |
| `02 - PDFs Pesquisaveis`   | **Opção [2]** Extrair   | `03 - Dados` (arquivo `.txt`)  |

-----

## ⚡ Guia de Início Rápido

Tenha a ferramenta funcionando em 4 passos simples.

### 1\. **Download**

  - Clone este repositório ou baixe o arquivo `.zip` e extraia-o em uma pasta no seu computador.

### 2\. **Setup do Ambiente** (Apenas na primeira vez)

  - Execute o arquivo `setup.bat` com um duplo clique.
  - Ele criará um ambiente Python isolado (`env/`) e instalará as bibliotecas necessárias. Aguarde a conclusão.

### 3\. **Adicionar Documentos**

  - Copie todos os PDFs que você deseja processar para a pasta:
  - `📁 01 - PDFs para convercao`

### 4\. **Executar**

  - Inicie o painel de controle executando `Programa.bat`.
  - Escolha a opção desejada no menu e deixe a mágica acontecer.

-----

## 📂 Estrutura do Projeto

```
/
├── 📁 01 - PDFs para convercao/   # ENTRADA: Coloque seus PDFs originais aqui
├── 📁 02 - PDFs Pesquisaveis/   # SAÍDA 1: PDFs convertidos
├── 📁 03 - Dados/                # SAÍDA 2: Arquivo .txt com o texto extraído
├── 📁 bin/                      # Contém as dependências e scripts
│   ├── 📁 extra-tools/         # Otimizadores de imagem (pngquant)
│   ├── 📦 ghostscript.zip      # Dependência encapsulada
│   ├── 📦 tesseract.zip        # Dependência encapsulada
│   └── 📜 extract-text.py      # Script Python para extração de texto
├── 📁 env/                      # Ambiente virtual Python (criado pelo setup)
├── 📜 .gitignore                # Configuração do Git
├── 🚀 Programa.bat              # PAINEL DE CONTROLE (Script principal)
├── 📝 README.md                 # Esta documentação
└── 🛠️ setup.bat                 # INSTALADOR (Script de configuração inicial)
```

-----

## 🔧 Solução de Problemas Comuns (Troubleshooting)

  * **ERRO: Python não encontrado...**

      * **Causa:** O Python não foi instalado ou a opção "Add Python to PATH" não foi marcada durante a instalação.
      * **Solução:** Reinstale o Python a partir do [site oficial](https://www.python.org/downloads/), garantindo que a opção "Add Python to PATH" esteja marcada.

  * **O script `Programa.bat` fecha imediatamente ao ser executado.**

      * **Causa:** O arquivo `.bat` pode ter sido salvo com a codificação errada (ex: UTF-8). O terminal do Windows requer a codificação **ANSI**.
      * **Solução:** Abra o `Programa.bat` no Bloco de Notas, vá em `Arquivo > Salvar Como...`, e na caixa "Codificação", selecione `ANSI` e salve, substituindo o arquivo original.

-----

## 🛠️ Tecnologias Envolvidas

Esta solução integra um conjunto de ferramentas robustas e consolidadas para entregar um resultado de alta qualidade.

| Tecnologia                                                              | Propósito                                                                   |
| :---------------------------------------------------------------------- | :-------------------------------------------------------------------------- |
| **Batch Script** | Orquestração do fluxo, menu interativo e gerenciamento do ambiente.         |
| [**Python 3**](https://www.python.org/)                                 | Linguagem principal para a lógica de extração e limpeza de texto.           |
| [**ocrmypdf**](https://ocrmypdf.readthedocs.io/en/latest/)              | Biblioteca central para adicionar a camada de texto OCR aos PDFs.           |
| [**PyPDF2**](https://www.google.com/search?q=https://pypdf2.readthedocs.io/en/latest/)                  | Extração de texto otimizada para memória de PDFs já pesquisáveis.           |
| [**Tesseract OCR**](https://github.com/tesseract-ocr/tesseract)         | Motor de OCR de alta precisão desenvolvido pela Google.                     |
| [**Ghostscript**](https://ghostscript.com/)                             | Interpretador de PDF essencial para a manipulação e otimização dos arquivos.|

-----

## 📜 Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.