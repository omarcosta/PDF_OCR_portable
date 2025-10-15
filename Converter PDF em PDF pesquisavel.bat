@echo off
TITLE Processador de PDFs com OCR e Log

REM =================================================================
REM              CONFIGURACAO E VERIFICACAO INICIAL
REM =================================================================

REM Define os nomes das pastas para facilitar a manutencao
SET "PASTA_ENTRADA=01 - PDFs para convercao"
SET "PASTA_SAIDA=02 - PDFs Pesquisaveis"
SET "PASTA_LOG=04 - Logs"
SET "VENV_PATH=.\env\Scripts\activate.bat"

REM Cria as pastas, caso elas nao existam
if not exist "%PASTA_ENTRADA%" mkdir "%PASTA_ENTRADA%"
if not exist "%PASTA_SAIDA%" mkdir "%PASTA_SAIDA%"
if not exist "%PASTA_LOG%" mkdir "%PASTA_LOG%"

REM Verifica se o ambiente virtual (venv) existe
if not exist "%VENV_PATH%" (
    echo.
    echo ERRO: Ambiente virtual nao encontrado em '.\env\Scripts\'
    echo Por favor, certifique-se de que a pasta 'env' existe e esta no local correto.
    echo.
    pause
    exit /b
)


REM =================================================================
REM               PREPARACAO DO ARQUIVO DE LOG
REM =================================================================

REM Formata a data e hora para um nome de arquivo valido
REM Formato: YYYY.MM.DD-HH.MM.SS
set today=%date:~6,4%.%date:~3,2%.%date:~0,2%
set mytime=%time:~0,2%.%time:~3,2%.%time:~6,2%
set logfile=%today%-%mytime%.txt
set logfilepath=%PASTA_LOG%\%logfile%


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
echo "%logfilepath%"
echo.
echo Pressione qualquer tecla para comecar...
pause > nul


REM =================================================================
REM               ATIVACAO DO VENV E PROCESSAMENTO
REM =================================================================

REM Ativa o ambiente virtual. O 'CALL' eh essencial para que o controle retorne a este script.
CALL %VENV_PATH%

echo.
echo Ambiente virtual ativado. Iniciando a conversao...
echo Processando... Por favor, aguarde.
echo.

REM Escreve o cabecalho no arquivo de log
echo Log de Processamento de PDFs - %date% %time% > %logfilepath%
echo. >> %logfilepath%

REM Loop que processa cada arquivo PDF
FOR %%f IN ("%PASTA_ENTRADA%\*.pdf") DO (
    echo Processando o arquivo: "%%~nf.pdf"
    
    REM Executa o comando e verifica o resultado
    ocrmypdf -l por "%%f" "%PASTA_SAIDA%\%%~nf.pdf"
    
    REM %ERRORLEVEL% eh 0 para sucesso, e diferente de 0 para falha.
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