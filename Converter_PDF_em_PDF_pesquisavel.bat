@echo off
TITLE Processador de PDFs com OCR - v2.0 (Portatil)

REM =================================================================
REM              DESCOMPACTACAO AUTOMATICA DAS DEPENDENCIAS
REM =================================================================
echo Verificando dependencias...

SET "TESS_ZIP=%CD%\bin\tesseract.zip"
SET "TESS_DIR=%CD%\bin\tesseract"
SET "GS_ZIP=%CD%\bin\ghostscript.zip"
SET "GS_DIR=%CD%\bin\ghostscript"

REM --- Verifica e extrai o Tesseract ---
if not exist "%TESS_DIR%\" (
    if not exist "%TESS_ZIP%" (
        echo ERRO: Arquivo '%TESS_ZIP%' nao encontrado!
        pause
        exit /b
    )
    echo Pasta 'tesseract' nao encontrada. Extraindo de %TESS_ZIP%...
    echo Por favor, aguarde, isso pode levar um momento.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%TESS_ZIP%' -DestinationPath '%TESS_DIR%' -Force"
)

REM --- Verifica e extrai o Ghostscript ---
if not exist "%GS_DIR%\" (
    if not exist "%GS_ZIP%" (
        echo ERRO: Arquivo '%GS_ZIP%' nao encontrado!
        pause
        exit /b
    )
    echo Pasta 'ghostscript' nao encontrada. Extraindo de %GS_ZIP%...
    echo Por favor, aguarde...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%GS_ZIP%' -DestinationPath '%GS_DIR%' -Force"
)

REM =================================================================
REM               CONFIGURACAO DE AMBIENTE PORTATIL
REM =================================================================

REM Adiciona os executaveis locais (agora extraidos) ao PATH desta sessao.
SET PATH=%CD%\bin\tesseract;%CD%\bin\ghostscript\bin;%PATH%

REM Verifica se os comandos agora sao encontrados
where tesseract >nul 2>nul || (
    echo ERRO: Nao foi possivel encontrar tesseract.exe. A extracao pode ter falhado.
    pause
    exit /b
)
where gswin64c >nul 2>nul || (
    echo ERRO: Nao foi possivel encontrar gswin64c.exe. A extracao pode ter falhado.
    pause
    exit /b
)

REM =================================================================
REM              CONFIGURACAO E VERIFICACAO INICIAL
REM =================================================================

SET "PASTA_ENTRADA=01 - PDFs para convercao"
SET "PASTA_SAIDA=02 - PDFs Pesquisaveis"
SET "PASTA_LOG=04 - Logs"
SET "VENV_PATH=.\env\Scripts\activate.bat"

if not exist "%PASTA_ENTRADA%" mkdir "%PASTA_ENTRADA%"
if not exist "%PASTA_SAIDA%" mkdir "%PASTA_SAIDA%"
if not exist "%PASTA_LOG%" mkdir "%PASTA_LOG%"

if not exist "%VENV_PATH%" (
    echo.
    echo ERRO: Ambiente virtual nao encontrado em '.\env\Scripts\'
    echo Por favor, certifique-se de que a pasta 'env' existe e esta no local correto.
    echo.
    pause
    exit /b
)

REM =================================================================
REM               PREPARACAO DO ARQUIVO DE LOG (ROBUST)
REM =================================================================

REM Cria um nome de arquivo de log usando um numero aleatorio para garantir que seja unico
set logfile=log-%RANDOM%.txt
set logfilepath="%PASTA_LOG%\%logfile%"


REM =================================================================
REM                  MENSAGEM INICIAL PARA O USUARIO
REM =================================================================

echo.
echo ==========================================================
echo           INICIANDO PROCESSAMENTO DE PDFS
echo ==========================================================
echo.
echo Este programa ira ler todos os arquivos da pasta:
echo "%PASTA_ENTRADA%"
echo.
echo Os resultados serao salvos em:
echo "%PASTA_SAIDA%"
echo.
echo Um log detalhado sera gerado em:
echo %logfilepath%
echo.
echo Pressione qualquer tecla para comecar...
pause > nul


REM =================================================================
REM               ATIVACAO DO VENV E PROCESSAMENTO
REM =================================================================

CALL %VENV_PATH%

echo.
echo Ambiente virtual ativado. Iniciando a conversao...
echo Processando... Por favor, aguarde.
echo.

REM Escreve o cabecalho no arquivo de log (usa aspas no caminho do arquivo)
echo Log de Processamento de PDFs - %Year%/%Month%/%Day% %Hour%:%Minute%:%Second% > %logfilepath%
echo. >> %logfilepath%

FOR %%f IN ("%PASTA_ENTRADA%\*.pdf") DO (
    echo Processando o arquivo: "%%~nf.pdf"
    
    # IMPORTANT! Chama o ocrmypdf para converter o PDF em um PDF pesquisavel
    ocrmypdf --force-ocr -l por "%%f" "%PASTA_SAIDA%\%%~nf_pesquisavel.pdf"
    
    IF %ERRORLEVEL% EQU 0 (
        echo   [SUCESSO] - "%%~nf.pdf" convertido com exito.
        echo SUCESSO: O arquivo "%%~f" foi convertido. >> %logfilepath%
    ) ELSE (
        echo   [FALHA]   - Ocorreu um erro ao converter "%%~nf.pdf". Verifique o log.
        echo FALHA:   Ocorreu um erro ao processar "%%~f". >> %logfilepath%
    )
)

REM =================================================================
REM                   FINALIZACAO
REM =================================================================

echo. >> %logfilepath%
echo Processo finalizado. >> %logfilepath%

echo.
echo ==========================================================
echo             PROCESSAMENTO CONCLUIDO!
echo ==========================================================
echo.
echo Pressione qualquer tecla para fechar esta janela.
pause > nul