@echo off
TITLE Processador de PDFs com OCR

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