@echo off
TITLE Painel de Controle - Processador de Documentos v3.0

REM =================================================================
REM              ETAPA 1: VERIFICACAO DAS DEPENDENCIAS
REM =================================================================
echo Verificando dependencias...

SET "TESS_ZIP=%CD%\bin\tesseract.zip"
SET "TESS_DIR=%CD%\bin\tesseract"
SET "GS_ZIP=%CD%\bin\ghostscript.zip"
SET "GS_DIR=%CD%\bin\ghostscript"
SET "PYTHON_SCRIPT_PATH=%CD%\bin\extract-text.py"

REM --- Verifica e extrai o Tesseract ---
if not exist "%TESS_DIR%\" (
    if not exist "%TESS_ZIP%" (echo ERRO: Arquivo '%TESS_ZIP%' nao encontrado! && pause && exit /b)
    echo Pasta 'tesseract' nao encontrada. Extraindo de %TESS_ZIP%...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%TESS_ZIP%' -DestinationPath '%TESS_DIR%' -Force"
)

REM --- Verifica e extrai o Ghostscript ---
if not exist "%GS_DIR%\" (
    if not exist "%GS_ZIP%" (echo ERRO: Arquivo '%GS_ZIP%' nao encontrado! && pause && exit /b)
    echo Pasta 'ghostscript' nao encontrada. Extraindo de %GS_ZIP%...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%GS_ZIP%' -DestinationPath '%GS_DIR%' -Force"
)

REM =================================================================
REM              ETAPA 2: CONFIGURACAO DO AMBIENTE
REM =================================================================

REM Adiciona os executaveis locais ao PATH desta sessao.
# SET PATH=%CD%\bin\tesseract;%CD%\bin\ghostscript\bin;%PATH%
SET PATH=%CD%\bin\extra-tools;%CD%\bin\tesseract;%CD%\bin\ghostscript\bin;%PATH%

REM Verifica se os comandos agora sao encontrados
where tesseract >nul 2>nul || (echo ERRO: Nao foi possivel encontrar tesseract.exe. && pause && exit /b)
where gswin64c >nul 2>nul || (echo ERRO: Nao foi possivel encontrar gswin64c.exe. && pause && exit /b)

REM Define as pastas de trabalho
SET "PASTA_ENTRADA=01 - PDFs para convercao"
SET "PASTA_SAIDA=02 - PDFs Pesquisaveis"
SET "VENV_PATH=.\env\Scripts\activate.bat"

REM Garante que as pastas e o venv existem
if not exist "%PASTA_ENTRADA%" mkdir "%PASTA_ENTRADA%"
if not exist "%PASTA_SAIDA%" mkdir "%PASTA_SAIDA%"
REM --- Verifica, cria e ativa o Ambiente Virtual (VENV) ---
if not exist "%VENV_PATH%" (
    echo.
    echo Ambiente virtual 'env' nao encontrado.
    echo Tentando criar e configurar automaticamente...
    echo.
    
    REM 2.1 - Verifica se o Python "global" esta disponivel para criar o venv
    where python >nul 2>nul
    IF %ERRORLEVEL% NEQ 0 (
        echo ERRO: Python nao encontrado no PATH do sistema. 
        echo Nao e possivel criar o ambiente virtual.
        echo Por favor, instale o Python (3.7+) e adicione-o ao PATH.
        pause
        exit /b
    )
    
    REM 2.2 - Cria o ambiente virtual
    echo Criando ambiente virtual em '.\env\'...
    python -m venv env
    
    REM 2.3 - Verifica se a criacao falhou
    if not exist "%VENV_PATH%" (
        echo ERRO: Falha critica ao criar o ambiente virtual.
        pause
        exit /b
    )
    
    echo Ambiente virtual criado com sucesso.
    echo.
    
    REM 2.4 - Ativa o novo VENV para instalar pacotes
    CALL "%VENV_PATH%"
    
    REM 2.5 - Instala as dependencias (PyPDF2 e ocrmypdf)
    echo Instalando dependencias (PyPDF2, ocrmypdf)...
    echo Isto pode demorar alguns minutos.
    
    REM O script usa ocrmypdf (para conversao) e PyPDF2 (provavelmente em extract-text.py)
    pip install PyPDF2 ocrmypdf
    
    IF %ERRORLEVEL% NEQ 0 (
        echo ERRO: Falha ao instalar as dependencias com o pip.
        pause
        exit /b
    )
    
    echo Dependencias instaladas com sucesso.
    echo.
    
) ELSE (
    REM Ambiente ja existe, apenas ativa
    echo Ativando ambiente virtual existente...
    CALL %VENV_PATH%
)
REM =================================================================
REM                   ETAPA 3: MENU PRINCIPAL
REM =================================================================
:MENU
cls
echo.
echo ====================================================================
echo                 PAINEL DE CONTROLE DE DOCUMENTOS
echo ====================================================================
echo.
echo Escolha uma das opcoes abaixo:
echo.
echo   [1] Converter PDFs para formato PESQUISAVEL
echo       (Le da pasta '01 - PDFs para convercao' e salva em '02 - PDFs Pesquisaveis')
echo.
echo   [2] EXTRAIR Texto dos PDFs Pesquisaveis para um unico arquivo .txt
echo       (Le da pasta '02 - PDFs Pesquisaveis' e salva em '03 - Dados')
echo.
echo   [3] Executar TUDO (Converte e depois Extrai - Processo completo)
echo.
echo   [4] Sair
echo.
echo ====================================================================
echo.

CHOICE /C 1234 /N /M "Digite o numero da sua escolha: "

IF ERRORLEVEL 4 GOTO :QUIT
IF ERRORLEVEL 3 GOTO :DO_ALL
IF ERRORLEVEL 2 GOTO :EXTRACT_TEXT
IF ERRORLEVEL 1 GOTO :CONVERT_PDFS

REM =================================================================
REM              BLOCO DE EXECUCAO - CONVERSAO
REM =================================================================
:CONVERT_PDFS
cls
echo.
echo ====================================================================
echo             INICIANDO A CONVERSAO PARA PDF PESQUISAVEL
echo ====================================================================
echo.
FOR %%f IN ("%PASTA_ENTRADA%\*.pdf") DO (
    echo Processando o arquivo: "%%~nf.pdf"
    ocrmypdf --force-ocr -l por "%%f" "%PASTA_SAIDA%\%%~nf_pesquisavel.pdf"
    IF %ERRORLEVEL% EQU 0 (
        echo   [SUCESSO] - "%%~nf.pdf" convertido com exito.
    ) ELSE (
        echo   [FALHA]   - Ocorreu um erro ao converter "%%~nf.pdf".
    )
)
GOTO :FINAL_MESSAGE

REM =================================================================
REM              BLOCO DE EXECUCAO - EXTRACAO DE TEXTO
REM =================================================================
:EXTRACT_TEXT
cls
echo.
echo ====================================================================
echo                INICIANDO A EXTRACAO DE TEXTO
echo ====================================================================
echo.
echo Chamando o script Python 'extract-text.py'... Por favor, aguarde.
echo.

python "%PYTHON_SCRIPT_PATH%"

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo   [SUCESSO] - Script Python executado com exito.
) ELSE (
    echo.
    echo   [FALHA]   - Ocorreu um erro durante a execucao do script Python.
)
GOTO :FINAL_MESSAGE

REM =================================================================
REM              BLOCO DE EXECUCAO - COMPLETO
REM =================================================================
:DO_ALL
cls
echo.
echo ====================================================================
echo               INICIANDO PROCESSO COMPLETO
echo            Parte 1: Convertendo para PDF Pesquisavel
echo ====================================================================
echo.
FOR %%f IN ("%PASTA_ENTRADA%\*.pdf") DO (
    echo Processando o arquivo: "%%~nf.pdf"
    ocrmypdf --force-ocr -l por "%%f" "%PASTA_SAIDA%\%%~nf_pesquisavel.pdf"
    IF %ERRORLEVEL% EQU 0 (
        echo   [SUCESSO] - "%%~nf.pdf" convertido com exito.
    ) ELSE (
        echo   [FALHA]   - Ocorreu um erro ao converter "%%~nf.pdf".
    )
)

echo.
echo ====================================================================
echo               Parte 2: Extraindo texto dos arquivos
echo ====================================================================
echo.
echo Chamando o script Python 'extract-text.py'... Por favor, aguarde.
echo.
python "%PYTHON_SCRIPT_PATH%"
IF %ERRORLEVEL% EQU 0 (
    echo.
    echo   [SUCESSO] - Script Python executado com exito.
) ELSE (
    echo.
    echo   [FALHA]   - Ocorreu um erro durante a execucao do script Python.
)
GOTO :FINAL_MESSAGE

REM =================================================================
REM                   MENSAGEM FINAL E SAIDA
REM =================================================================
:FINAL_MESSAGE
echo.
echo ====================================================================
echo                   PROCESSO CONCLUIDO!
echo ====================================================================
echo.
echo Pressione qualquer tecla para voltar ao menu principal...
timeout /t -1 > nul
GOTO :MENU

:QUIT
cls
echo Saindo...
exit /b