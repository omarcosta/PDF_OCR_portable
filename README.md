# Processador de PDFs com OCR (PDF OCR Processor)

Um script de automação para Windows que converte múltiplos arquivos PDF, incluindo os baseados em imagem, em PDFs totalmente pesquisáveis usando a tecnologia de Reconhecimento Óptico de Caracteres (OCR).

## Visão Geral

Muitas vezes, documentos digitalizados são salvos como "imagens" dentro de um arquivo PDF, tornando impossível buscar por texto, copiar ou colar conteúdo. Esta ferramenta resolve esse problema em lote, processando uma pasta inteira de PDFs e gerando versões pesquisáveis, otimizadas e com alta fidelidade em relação ao original.

O projeto é **totalmente portátil e encapsulado**, não exigindo a instalação de dependências como Tesseract ou Ghostscript no sistema do usuário.

## ✨ Principais Funcionalidades

  * **Processamento em Lote:** Converte todos os PDFs encontrados em uma pasta de uma só vez.
  * **OCR de Alta Qualidade:** Utiliza o motor Tesseract para extrair texto de imagens com precisão.
  * **🚀 Totalmente Portátil:** Todas as dependências (Tesseract, Ghostscript) estão incluídas no projeto. Não é necessário instalar nada globalmente.
  * **📦 Auto-Configurável:** Na primeira execução, o script descompacta automaticamente as dependências necessárias.
  * **📁 Organização Automática:** Os arquivos processados são salvos em uma pasta de saída dedicada, com o sufixo `_pesquisavel` para fácil identificação.
  * **📝 Logs Detalhados:** Para cada execução, um arquivo de log com data e hora é gerado, informando quais arquivos foram convertidos com sucesso e quais falharam.
  * **Forçar OCR:** Garante que todas as páginas de todos os documentos sejam processadas, independentemente de possuírem uma camada de texto antiga, garantindo máxima qualidade e consistência.

## Pré-requisitos

Para executar este projeto, você precisará ter:

1.  **Windows (10 ou superior)**
2.  **Python 3.x** instalado.
      * *Importante:* Durante a instalação do Python, marque a opção **"Add Python to PATH"**.

## 🚀 Como Usar

Siga estes passos para configurar e executar o processador pela primeira vez.

### 1\. Baixe o Projeto

  * Clone o repositório ou baixe o arquivo ZIP e extraia-o em uma pasta no seu computador.

### 2\. Configure o Ambiente (Apenas na primeira vez)

Para instalar as bibliotecas Python necessárias (`ocrmypdf`), foi criado um script de configuração.

  * Dê um duplo clique no arquivo `setup.bat`.
  * Ele criará o ambiente virtual (`env`) e instalará as dependências. Aguarde a conclusão do processo.

*(Se o arquivo `setup.bat` não existir, crie-o com o conteúdo abaixo):*

```batch
@echo off
TITLE Configuracao do Ambiente

echo.
echo Verificando se o Python esta instalado...
python --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERRO: Python nao encontrado. Por favor, instale o Python 3 e marque "Add to PATH".
    pause
    exit /b
)

echo.
echo Criando ambiente virtual na pasta 'env'...
python -m venv env

echo.
echo Ativando ambiente e instalando 'ocrmypdf'...
call .\env\Scripts\activate.bat
pip install ocrmypdf

echo.
echo =================================
echo    CONFIGURACAO CONCLUIDA!
echo =================================
echo.
echo Voce ja pode usar o 'EXECUTAR.bat'.
pause
```

### 3\. Adicione seus PDFs

  * Copie todos os arquivos PDF que você deseja converter para a pasta `01 - PDFs para convercao`.

### 4\. Execute o Processador

  * Dê um duplo clique no arquivo `EXECUTAR.bat`.
  * Na primeira vez, ele pode demorar um pouco mais, pois irá descompactar o Tesseract e o Ghostscript.
  * Uma janela do terminal mostrará o progresso do processo.

### 5\. Verifique os Resultados

  * Os PDFs convertidos e agora pesquisáveis estarão na pasta `02 - PDFs Pesquisaveis`.
  * Um relatório detalhado da execução estará na pasta `04 - Logs`.

## 📂 Estrutura do Projeto

```
/
|
|--- bin/                   # Contém as dependências portáteis (em formato ZIP)
|    |--- tesseract.zip
|    |--- ghostscript.zip
|
|--- 01 - PDFs para convercao/  # Pasta de ENTRADA: Coloque seus PDFs aqui
|--- 02 - PDFs Pesquisaveis/  # Pasta de SAÍDA: Os resultados aparecem aqui
|--- 04 - Logs/               # Contém os logs de cada execução
|
|--- env/                     # Pasta do ambiente virtual Python (criada pelo setup)
|
|--- EXECUTAR.bat             # Script principal para PROCESSAR os PDFs
|--- setup.bat                # Script para CONFIGURAR o ambiente na primeira vez
|--- README.md                # Este arquivo
```

## ⚙️ Como Funciona (Detalhes Técnicos)

O `EXECUTAR.bat` é o coração do projeto. Ele orquestra as seguintes ações:

1.  **Verifica e Descompacta:** Checa se as pastas `bin/tesseract` e `bin/ghostscript` existem. Se não, usa o PowerShell (`Expand-Archive`) para extraí-las a partir dos arquivos `.zip` correspondentes.
2.  **Configura o Ambiente:** Modifica a variável de ambiente `PATH` *temporariamente* (apenas para sua própria execução) para que o sistema possa encontrar os executáveis do Tesseract e Ghostscript nas pastas locais.
3.  **Ativa o Python:** Ativa o ambiente virtual (`env`) para ter acesso à biblioteca `ocrmypdf`.
4.  **Executa o Processo:** Itera sobre cada PDF na pasta de entrada e executa o comando `ocrmypdf` com os parâmetros definidos.
5.  **Gera Logs:** Registra o sucesso ou falha de cada operação em um arquivo de log único.

## Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.