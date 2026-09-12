import pandas as pd
import logging
from datetime import datetime
from sqlalchemy import create_engine

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s - %(message)s - %(levelname)s")


logger = logging.getLogger(__name__)


def extrair_dados():
    try:
        df_clientes = pd.read_excel("clientes.xlsx")
        
        logger.info("Dados da planilha clientes carregado com sucesso !")
        
        logger.info("Total de registros: %s", len(df_clientes))
        
        df_vendedores = pd.read_excel("vendedores.xlsx")
        
        logger.info("Dados da planilha vendedores carregado com sucesso !")
        
        logger.info("Total de registros: %s", len(df_vendedores))
        
        df_produtos = pd.read_excel("produtos.xlsx")
        
        logger.info("Dados da planilha produtos carregado com sucesso !")
        
        logger.info("Total de registros: %s", len(df_produtos))
        
        df_pedidos = pd.read_excel("pedidos.xlsx")
        
        logger.info("Dados da planilha pedidos carregado com sucesso !")
        
        logger.info("Total de registros: %s", len(df_pedidos))
        
        df_categorias = pd.read_excel("categorias.xlsx")
        
        logger.info("Dados da planilha categorias carregado com sucesso !")
        
        logger.info("Total de registros: %s", len(df_categorias))
        
        df_itens_pedido = pd.read_excel("itens_pedido.xlsx")
        
        logger.info("Dados da planilha itens pedido carregado com sucesso !")
        
        logger.info("Total de registros: %s", len(df_itens_pedido))
        
        df_pagamentos = pd.read_excel("pagamentos.xlsx")
        logger.info("Dados da planilha pagamentos carregado com sucesso !")
        logger.info("Total de registros: %s", len(df_pagamentos))
        
        return (
        df_categorias,
        df_clientes,
        df_vendedores,
        df_produtos,
        df_pedidos,
        df_itens_pedido,
        df_pagamentos)

    
    except Exception as e:
        logger.exception("Erro ao carregar planilhas: %s", e)
        return None
    
def transformar_clientes(df):
    df = df.drop_duplicates()
    df["nome"] = df["nome"].str.strip().str.lower()
    df["email"] = df["email"].str.strip().str.lower()
    df["cidade"] = df["cidade"].str.strip().str.title()
    df["uf"] = df["uf"].str.strip().str.upper()
    
    
    df["id_cliente"] = pd.to_numeric(df["id_cliente"], errors="coerce")
    
    df["data_cadastro"] = pd.to_datetime(df["data_cadastro"], errors="coerce", dayfirst=True)
    
    df = df.dropna(subset=["id_cliente", "nome", "cidade", "uf", "data_cadastro", "email"])
    
    return df

def transformar_categorias(df):
    df = df.drop_duplicates()
    df["id_categoria"] = pd.to_numeric(df["id_categoria"], errors="coerce")
    df["nome_categoria"] = df["nome_categoria"].str.strip().str.title()
    
    df = df.dropna(subset=["id_categoria", "nome_categoria"])
    
    return df

def transformar_vendedores(df):
    df = df.drop_duplicates()
    
    df["id_vendedor"] = pd.to_numeric(df["id_vendedor"], errors="coerce")
    df["nome"] = df["nome"].str.strip().str.lower()
    df["equipe"] = df["equipe"].str.strip().str.lower()
    
    df["data_admissao"] = pd.to_datetime(df["data_admissao"], errors="coerce", dayfirst=True)
    
    df = df.dropna(subset=["id_vendedor", "nome","equipe", "data_admissao"])
    
    return df

def transformar_produtos(df):
    df = df.drop_duplicates()
    df["nome_produto"] = df["nome_produto"].str.strip().str.lower()
    df["id_produto"] = pd.to_numeric(df["id_produto"], errors="coerce")
    df["id_categoria"] = pd.to_numeric(df["id_categoria"], errors="coerce")
    
    df["preco_unitario"] = (df["preco_unitario"].astype("string")
                                                .str.replace("R$", "", regex=False)
                                                .str.replace(".", "", regex=False)
                                                .str.replace(",", ".", regex=False)
                                                .str.strip())
    
    df["preco_unitario"] = pd.to_numeric(df["preco_unitario"], errors="coerce")
    df["estoque"] = pd.to_numeric(df["estoque"], errors="coerce")
    
    df = df[df["preco_unitario"] >= 0]
    
    df = df[df["estoque"] >= 0]
    
    df = df.dropna(subset=["nome_produto", "id_produto", "id_categoria", "preco_unitario", "estoque"])
    
    return df

def transformar_pedidos(df):
    df = df.drop_duplicates()
    df["status"] = df["status"].str.strip().str.lower()
    df["id_pedido"] = pd.to_numeric(df["id_pedido"], errors="coerce")
    
    df["id_cliente"] = pd.to_numeric(df["id_cliente"], errors="coerce")
    
    df["id_vendedor"] = pd.to_numeric(df["id_vendedor"], errors="coerce")
    
    df["data_pedido"] = pd.to_datetime(df["data_pedido"], errors="coerce", dayfirst=True)
    
    df = df.dropna(subset=["status", "id_pedido", "id_cliente", "id_vendedor", "data_pedido"])
    
    return df

def transformar_itens_pedido(df):
    df = df.drop_duplicates()
    
    df["id_item"] = pd.to_numeric(df["id_item"], errors="coerce")
    df["id_pedido"] = pd.to_numeric(df["id_pedido"], errors="coerce")
    df["id_produto"] = pd.to_numeric(df["id_produto"], errors="coerce")
    df["quantidade"] = pd.to_numeric(df["quantidade"], errors="coerce")
    
    df = df[df["quantidade"] >= 0]
    
    df["preco_unitario"] = (df["preco_unitario"].astype("string")
                                            .str.replace("R$", "", regex=False)
                                            .str.replace(".", "", regex=False)
                                            .str.replace(",", ".", regex=False)
                                            .str.strip())
    
    df["preco_unitario"] = pd.to_numeric(df["preco_unitario"], errors="coerce")
    
    df = df[df["preco_unitario"] >= 0]
    
    df = df.dropna(subset=["id_item", "id_pedido", "id_produto", "quantidade", "preco_unitario"])
    
    return df

def transformar_pagamentos(df):
    df = df.drop_duplicates()
    
    df["id_pagamento"] = pd.to_numeric(df["id_pagamento"], errors="coerce")
    df["id_pedido"] = pd.to_numeric(df["id_pedido"], errors="coerce")
    df["forma_pagamento"] = df["forma_pagamento"].str.strip().str.title()
    df["status_pagamento"] = df["status_pagamento"].str.strip().str.title()
    
    df["data_pagamento"] = pd.to_datetime(df["data_pagamento"], errors="coerce", dayfirst=True)
    
    
    df["valor_pago"] = (df["valor_pago"].astype("string")
                        .str.replace("R$", "", regex=False)
                        .str.replace(".", "", regex=False)
                        .str.replace(",", ".", regex=False)
                        .str.strip())
    
    df["valor_pago"] = pd.to_numeric(df["valor_pago"], errors="coerce")
    
    df = df[df["valor_pago"] >= 0]
    
    df = df.dropna(subset=["id_pagamento", "id_pedido", 
                           "forma_pagamento", "status_pagamento", "data_pagamento", "valor_pago"])
    
    return df


def carregar_dados(df_categorias,
        df_clientes,
        df_vendedores,
        df_produtos,
        df_pedidos,
        df_itens_pedido,
        df_pagamentos):
    try:
        engine = create_engine("mysql+mysqlconnector://root:@localhost:3306/ecommerce_analytics")
        
        df_categorias.to_sql("categorias",
                             con=engine,
                             if_exists="append",
                             index=False)
        
        logger.info("Dados da planilha categorias carregado com sucesso no banco de dados !")
        logger.info("Total de registros: %s", len(df_categorias))
        
        df_clientes.to_sql("clientes",
                           con=engine,
                           if_exists="append",
                           index=False)
        
        logger.info("Dados da planilha clientes carregado com sucesso no banco de dados !")
        logger.info("Total de registros: %s", len(df_clientes))
        
        df_vendedores.to_sql("vendedores",
                             con=engine,
                             if_exists="append",
                             index=False)
        
        logger.info("Dados da planilha vendedores carregado no banco de dados com sucesso !")
        logger.info("Total de registros: %s", len(df_vendedores))
        
        df_produtos.to_sql("produtos",
                           con=engine,
                           if_exists="append",
                           index=False)
        
        logger.info("Dados da planilha produtos carregado com sucesso no banco de dados !")
        logger.info("Total de registros: %s", len(df_produtos))
        
        df_pedidos.to_sql("pedidos",
                          con=engine,
                          if_exists="append",
                          index=False)
        
        logger.info("Dados da planilha pedidos carregado com sucesso no banco de dados !")
        logger.info("Total de registros: %s", len(df_pedidos))
        
        df_itens_pedido.to_sql("itens_pedido",
                               con=engine,
                               if_exists="append",
                               index=False)
        
        logger.info("Dados da planilha itens pedido carregado com sucesso no banco de dados !")
        logger.info("Total de registros: %s", len(df_itens_pedido))
        
        df_pagamentos.to_sql("pagamentos",
                             con=engine,
                             if_exists="append",
                             index=False)
        
        logger.info("Dados da planilha pagamentos carregado com sucesso no banco de dados !")
        logger.info("Total de registros: %s", len(df_pagamentos))
        return True
    
    except Exception as e:
        logger.exception("Erro ao carregar dados: %s", e)
        return False
    
    
def main():
    inicio = datetime.now()
    dados = extrair_dados()
    if dados is not None:
        (df_categorias,
        df_clientes,
        df_vendedores,
        df_produtos,
        df_pedidos,
        df_itens_pedido,
        df_pagamentos) = dados
        df_categorias = transformar_categorias(df_categorias)
        if df_categorias is not None:
            df_clientes = transformar_clientes(df_clientes)
            if df_clientes is not None:
                df_vendedores = transformar_vendedores(df_vendedores)
                if df_vendedores is not None:
                    df_produtos = transformar_produtos(df_produtos)
                    if df_produtos is not None:
                        df_pedidos = transformar_pedidos(df_pedidos)
                        if df_pedidos is not None:
                            df_itens_pedido = transformar_itens_pedido(df_itens_pedido)
                            if df_itens_pedido is not None:
                                df_pagamentos = transformar_pagamentos(df_pagamentos)
                                if df_pagamentos is not None:
                                    carregar_dados(df_categorias,
                                                   df_clientes,
                                                   df_vendedores,
                                                   df_produtos,
                                                   df_pedidos,
                                                   df_itens_pedido,
                                                   df_pagamentos)
    fim = datetime.now()
    logger.info("ETL finalizado em: %s", fim.strftime("%Y/%m/%d"))
    tempo_duracao = fim - inicio
    
    logger.info("Tempo duração: %s", tempo_duracao)
                                    
if __name__ == "__main__":
    main()
        
        

        
        