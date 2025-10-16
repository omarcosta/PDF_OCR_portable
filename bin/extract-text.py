# -*- coding: utf-8 -*-

# Standard library imports
import os
import datetime
import re
from typing import List, TextIO

# Third-party imports
# Lembre-se de ter o PyPDF2 instalado no seu ambiente virtual (pip install PyPDF2)
import PyPDF2

# --- CONSTANTS ---
# Define a raiz do projeto de forma robusta, baseada na localização do script.
# Assume-se que o script está em uma pasta /bin ou similar, um nível abaixo da raiz.
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)

# Define os diretórios de origem e destino a partir da raiz do projeto.
SOURCE_PDF_DIR = os.path.join(PROJECT_ROOT, "02 - PDFs Pesquisaveis")
OUTPUT_DATA_DIR = os.path.join(PROJECT_ROOT, "03 - Dados")
OUTPUT_FILE_PREFIX = "DADOS_EXTRAIDOS_"
OUTPUT_FILE_EXTENSION = ".txt"

# Lista de textos repetitivos (cabeçalhos/rodapés) a serem removidos.
# Adicione outros padrões que você encontrar para limpar ainda mais o texto.
REPETITIVE_TEXTS_TO_REMOVE = [
    "PREFEITURA MUNICIPAL DE BOTUCATU",
    "Praça Prof. Pedro Torres, 100 Botucatu/SP",
    "O PRESENTE DOCUMENTO É PARTE INTEGRANTE DA CERTIDÃO DE ACERVO TÉCNICO EXPEDIDA PELO CREA-SP",
    "Conselho Regional de Engenharia e Agronomia do Estado de São Paulo"
]


def clean_and_enhance_text(text: str) -> str:
    """
    Limpa e melhora um bloco de texto extraído de um PDF.
    - Substitui caracteres especiais (m², m³).
    - Remove espaços múltiplos e quebras de linha no meio de frases.
    - Remove linhas em branco excessivas.
    - Remove textos repetitivos de cabeçalhos/rodapés.
    """
    if not text:
        return ""

    # 1. Substitui unidades e caracteres especiais por texto plano
    text = text.replace('²', '2').replace('³', '3')
    text = text.replace('–', '-')

    # 2. Remove cabeçalhos e rodapés repetitivos da lista de constantes
    for repetitive_pattern in REPETITIVE_TEXTS_TO_REMOVE:
        text = text.replace(repetitive_pattern, "")
        
    cleaned_lines = []
    for line in text.splitlines():
        # 3. Remove espaços extras no início/fim de cada linha
        stripped_line = line.strip()
        
        # 4. Substitui múltiplos espaços por um único espaço
        cleaned_line = re.sub(r'\s+', ' ', stripped_line)
        
        # 5. Adiciona a linha à lista apenas se ela não estiver vazia
        if cleaned_line:
            cleaned_lines.append(cleaned_line)

    # 6. Junta as linhas limpas com uma única quebra de linha, resultando em um texto mais coeso.
    return "\n".join(cleaned_lines)


def find_pdf_files(directory_path: str) -> List[str]:
    """
    (EFICIENTE) Recursivamente encontra todos os arquivos .pdf em um dado diretório.
    O filtro .pdf é aplicado aqui para otimização.
    """
    pdf_files_list = []
    if not os.path.isdir(directory_path):
        print(f"ERRO: O caminho '{directory_path}' não é um diretório válido.")
        return pdf_files_list

    print(f"Buscando por arquivos PDF em '{directory_path}'...")
    for root, dirs, files in os.walk(directory_path):
        for file in files:
            if file.lower().endswith('.pdf'):
                full_path = os.path.join(root, file)
                pdf_files_list.append(full_path)
    
    print(f"Encontrados {len(pdf_files_list)} arquivo(s) PDF.")
    return pdf_files_list


def process_and_write_files(file_paths: List[str], output_file_handle: TextIO):
    """
    (OTIMIZADO PARA MEMÓRIA) Extrai, limpa e escreve o texto de cada PDF diretamente
    no arquivo de saída aberto, utilizando um cabeçalho informativo.
    """
    total_files = len(file_paths)
    
    for index, file_path in enumerate(file_paths, start=1):
        try:
            filename = os.path.basename(file_path)
            print(f"Processando arquivo {index} de {total_files}: '{filename}'...")
            
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            # --- SEPARADOR INFORMATIVO E PROFISSIONAL ---
            header_line_1 = "//" + "=" * 113 + "\n"
            header_line_2 = f"//== ATESTADO {index} de {total_files} | ARQUIVO: {filename} | PROCESSADO EM: {timestamp}\n"
            
            output_file_handle.write(header_line_1)
            output_file_handle.write(header_line_2)
            output_file_handle.write(header_line_1)
            
            with open(file_path, 'rb') as pdf_file_stream:
                pdf_reader = PyPDF2.PdfReader(pdf_file_stream)
                
                for page_num, page in enumerate(pdf_reader.pages, start=1):
                    extracted_text = page.extract_text()
                    cleaned_text = clean_and_enhance_text(extracted_text)
                    
                    if cleaned_text:
                        output_file_handle.write(f"\n--- Página {page_num} ---\n")
                        output_file_handle.write(cleaned_text + '\n')
            
            output_file_handle.write(f"\n--- FIM DO ATESTADO: {filename} ---\n\n\n")

        except Exception as e:
            error_message = f"ERRO ao processar {os.path.basename(file_path)}: {e}\n"
            print(error_message)
            separator = "!" * 115 + "\n"
            output_file_handle.write(separator)
            output_file_handle.write(f"!!! ERRO AO PROCESSAR O ARQUIVO: {os.path.basename(file_path)} !!!\n")
            output_file_handle.write(error_message)
            output_file_handle.write(separator)


def ensure_directory_exists(directory_path: str):
    """Verifica se um diretório existe e, se não, o cria."""
    if not os.path.exists(directory_path):
        print(f"Diretório '{directory_path}' não encontrado. Criando...")
        os.makedirs(directory_path)

def generate_timestamped_filename(prefix: str, extension: str, directory: str) -> str:
    """Cria um nome de arquivo formatado com data e hora atuais."""
    if not extension.startswith('.'):
        extension = '.' + extension
    
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{prefix}{timestamp}{extension}"
    return os.path.join(directory, filename)


def main():
    """
    Função principal que orquestra o fluxo de trabalho de forma otimizada.
    """
    print("Iniciando o processo de extração de texto de PDFs...")
    
    # 1. Garante que o diretório de saída existe e gera o nome do arquivo final.
    ensure_directory_exists(OUTPUT_DATA_DIR)
    output_filename = generate_timestamped_filename(
        prefix=OUTPUT_FILE_PREFIX, 
        extension=OUTPUT_FILE_EXTENSION, 
        directory=OUTPUT_DATA_DIR
    )

    # 2. Encontra todos os arquivos PDF no diretório de origem.
    pdf_files = find_pdf_files(SOURCE_PDF_DIR)

    if not pdf_files:
        print("Nenhum arquivo PDF encontrado no diretório de origem. Encerrando.")
        return

    # 3. Abre o arquivo de saída UMA VEZ e processa todos os PDFs, escrevendo em tempo real.
    print(f"\nAbrindo arquivo de saída '{output_filename}' para escrita...")
    try:
        with open(output_filename, 'w', encoding='utf-8') as output_file:
            process_and_write_files(pdf_files, output_file)
        print(f"\nProcesso finalizado com sucesso. Todo o texto foi salvo em '{output_filename}'.")
    except Exception as e:
        print(f"\nOcorreu um erro fatal durante a escrita do arquivo: {e}")
    
    print("\nWorkflow concluído.")


if __name__ == '__main__':
    main()