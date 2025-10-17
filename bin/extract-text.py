import os
import datetime
import re
from typing import List, TextIO
import PyPDF2

# --- CONFIGURACOES ---
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)

SOURCE_PDF_DIR = os.path.join(PROJECT_ROOT, "02 - PDFs Pesquisaveis")
OUTPUT_DATA_DIR = os.path.join(PROJECT_ROOT, "03 - Dados")
OUTPUT_FILE_PREFIX = "DADOS_EXTRAIDOS_"
OUTPUT_FILE_EXTENSION = ".txt"

# Padrões de texto repetitivo a serem removidos do conteúdo extraído.
REPETITIVE_TEXTS_TO_REMOVE = [
    "PREFEITURA MUNICIPAL DE BOTUCATU",
    "Praça Prof. Pedro Torres, 100 Botucatu/SP",
    "O PRESENTE DOCUMENTO É PARTE INTEGRANTE DA CERTIDÃO DE ACERVO TÉCNICO EXPEDIDA PELO CREA-SP",
    "Conselho Regional de Engenharia e Agronomia do Estado de São Paulo"
]


def clean_text(text: str) -> str:
    """Aplica uma série de limpezas no texto extraído de uma página."""
    if not text:
        return ""

    text = text.replace('²', '2').replace('³', '3').replace('–', '-')
    for pattern in REPETITIVE_TEXTS_TO_REMOVE:
        text = text.replace(pattern, "")
    
    # Processa as linhas: remove espaços extras e linhas em branco.
    cleaned_lines = [re.sub(r'\s+', ' ', line.strip()) for line in text.splitlines() if line.strip()]
    
    return "\n".join(cleaned_lines)


def find_pdf_files(directory_path: str) -> List[str]:
    """Busca recursivamente por arquivos .pdf em um diretório."""
    pdf_paths = []
    if not os.path.isdir(directory_path):
        print(f"ERRO: O caminho '{directory_path}' não é um diretório válido.")
        return pdf_paths

    print(f"Buscando por arquivos PDF em '{directory_path}'...")
    for root, _, files in os.walk(directory_path):
        for file in files:
            if file.lower().endswith('.pdf'):
                pdf_paths.append(os.path.join(root, file))
    
    print(f"Encontrados {len(pdf_paths)} arquivo(s) PDF.")
    return pdf_paths


def process_pdf_batch(pdf_paths: List[str], output_stream: TextIO):
    """Extrai, limpa e escreve o texto de cada PDF diretamente no arquivo de saída."""
    total_files = len(pdf_paths)
    
    for index, file_path in enumerate(pdf_paths, start=1):
        filename = os.path.basename(file_path)
        print(f"Processando arquivo {index} de {total_files}: '{filename}'...")
        
        try:
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            header = (
                f"//{'=' * 113}\n"
                f"//== ATESTADO {index} de {total_files} | ARQUIVO: {filename} | PROCESSADO EM: {timestamp}\n"
                f"//{'=' * 113}\n"
            )
            output_stream.write(header)
            
            with open(file_path, 'rb') as pdf_stream:
                pdf_reader = PyPDF2.PdfReader(pdf_stream)
                
                for page_num, page in enumerate(pdf_reader.pages, start=1):
                    raw_text = page.extract_text()
                    processed_text = clean_text(raw_text)
                    
                    if processed_text:
                        output_stream.write(f"\n--- Página {page_num} ---\n")
                        output_stream.write(processed_text + '\n')
            
            output_stream.write(f"\n--- FIM DO ATESTADO: {filename} ---\n\n\n")

        except Exception as e:
            error_message = f"ERRO ao processar {filename}: {e}\n"
            print(error_message)
            error_header = (
                f"{'!' * 115}\n"
                f"!!! ERRO AO PROCESSAR O ARQUIVO: {filename} !!!\n"
                f"{error_message}"
                f"{'!' * 115}\n"
            )
            output_stream.write(error_header)


def ensure_directory_exists(directory_path: str):
    if not os.path.exists(directory_path):
        print(f"Diretório '{directory_path}' não encontrado. Criando...")
        os.makedirs(directory_path)

def generate_timestamped_filename(prefix: str, extension: str, directory: str) -> str:
    if not extension.startswith('.'):
        extension = '.' + extension
    
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{prefix}{timestamp}{extension}"
    return os.path.join(directory, filename)


def main():
    print("Iniciando o processo de extração de texto de PDFs...")
    
    ensure_directory_exists(OUTPUT_DATA_DIR)
    
    output_filename = generate_timestamped_filename(
        prefix=OUTPUT_FILE_PREFIX, 
        extension=OUTPUT_FILE_EXTENSION, 
        directory=OUTPUT_DATA_DIR
    )

    pdf_files = find_pdf_files(SOURCE_PDF_DIR)

    if not pdf_files:
        print("Nenhum arquivo PDF encontrado no diretório de origem. Encerrando.")
        return

    print(f"\nAbrindo arquivo de saída '{output_filename}' para escrita...")
    try:
        with open(output_filename, 'w', encoding='utf-8') as output_file:
            process_pdf_batch(pdf_files, output_file)
        print(f"\nProcesso finalizado com sucesso. Todo o texto foi salvo em '{output_filename}'.")
    except Exception as e:
        print(f"\nOcorreu um erro fatal durante a escrita do arquivo: {e}")
    
    print("\nWorkflow concluído.")


if __name__ == '__main__':
    main()