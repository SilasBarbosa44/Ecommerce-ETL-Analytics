# 📦 Ecommerce ETL - De Excel para SQL

Projeto de ETL onde extraí 7 planilhas de Excel, tratei com Python (Pandas) e carreguei para um banco SQL relacional para análises.

O foco do projeto é a engenharia dos dados: extração, transformação, tratamento e carga com logging.



### 📁 Estrutura do Projeto

ecommerce_etl_analytics/
│
├── Python/
│   ├── ecommerce_etl_analytics.py
│   ├── clientes.xlsx
│   ├── pedidos.xlsx
│   ├── itens_pedido.xlsx
│   ├── produtos.xlsx
│   ├── categorias.xlsx
│   ├── pagamentos.xlsx
│   └── vendedores.xlsx
│
├── SQL/
│   ├── database.sql
│   └── queries.sql
│
├── Power BI/
│   ├── Ecommerce Analytics.pbix
│   ├── Visão Geral de Vendas.png
│   └── Analise de Produtos e Vendas.png
│
└── README.md

### 📂 Fonte dos Dados
7 planilhas `.xlsx` brutas:
`clientes.xlsx | pedidos.xlsx | itens_pedido.xlsx | produtos.xlsx | categorias.xlsx | pagamentos.xlsx | vendedores.xlsx`



### 🔧 Fluxo do ETL (Como o sistema funciona hoje)

**1. Extract - `extrair_dados()`**
Leitura das 7 planilhas com `pd.read_excel()` + log de total de registros e tratamento de exceção com `logger.exception`.

**2. Transform - 7 funções de limpeza**
- `transformar_clientes()`, `transformar_categorias()`, `transformar_vendedores()` etc.
- `drop_duplicates()`
- Padronização de texto: `str.strip().str.lower() / .title() / .upper()`
- Conversão de moeda brasileira: `R$ 1.200,50 -> 1200.50` com `replace()`
- Conversão de tipos: `pd.to_numeric(errors="coerce")` e `pd.to_datetime(dayfirst=True)`
- Remoção de nulos com `dropna()` e filtro de valores negativos `df[df["valor"] >= 0]`

**3. Load - `carregar_dados()`**
Conexão com MySQL via `SQLAlchemy` (`mysql+mysqlconnector`) e carga com `to_sql(if_exists="append")` respeitando a ordem das FKs:
`categorias -> clientes -> vendedores -> produtos -> pedidos -> itens_pedido -> pagamentos`

**4. Orquestração - `main()`**
Mede tempo de execução com `datetime.now()` e orquestra Extract -> Transform -> Load.

### 📊 14 Análises em SQL (queries.sql)

01. Faturamento por cliente
02. Top 10 produtos mais vendidos
03. Faturamento por categoria
04. Faturamento por vendedor
05. Ticket Médio por cliente
06. Ranking de vendedores com DENSE_RANK()
07. Faturamento mensal
08. Pagamentos por cliente
09. Top 10 clientes por Qtd de pedidos
10. Vendedores acima da média (CTE)
11. Ranking de produtos por faturamento
12. Ranking de vendedores por cliente
13. Crescimento percentual mensal com LAG()
14. Relatório completo de clientes com recorrência e inatividade

### 🛠️ Tecnologias
- Python (Pandas, SQLAlchemy, Logging)
- SQL (MySQL) - JOIN, GROUP BY, CTE, WINDOW FUNCTIONS
- Excel - Fonte dos dados

### 🚀 Como Rodar
```bash
pip install pandas openpyxl sqlalchemy mysql-connector-python
python Python/ecommerce_etl_analytics.py
### 📊 14 Análises em SQL que respondi depois da carga

**Faturamento:**
01. Faturamento por cliente
02. Top 10 produtos mais vendidos
03. Faturamento por categoria
04. Faturamento por vendedor
05. Ticket Médio por cliente

**Rankings e Filtros:**
06. Ranking de vendedores
07. Faturamento mensal
08. Pagamentos por cliente
09. Top 10 clientes por Qtd de pedidos
10. Vendedores acima da média (CTE + AVG)

**Análises Avançadas com Window Functions:**
11. Ranking de produtos por faturamento
12. Ranking de vendedores por cliente
13. Crescimento percentual mensal com LAG()
14. Relatório completo de clientes com recorrência, inatividade, classificação e LEAD()

### 🛠️ Tecnologias
- Python (Pandas) - ETL
- SQL (MySQL) - JOIN, GROUP BY, CTE, WINDOW FUNCTIONS
- Excel - Validação

### 🚀 Como Rodar
1. pip install pandas openpyxl
2. python ecommerce_etl_analytics.py
3. Executar o database.sql no MySQL
4. Rodar as queries do queries.sql

---
---
### 👨‍💻 Autor

Feito por **Silas Barbosa da Silva**

[![GitHub](https://img.shields.io/badge/GitHub-SilasBarbosa44-181717?style=for-the-badge&logo=github)](https://github.com/SilasBarbosa44)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Silas%20Barbosa-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/silas-barbosa-1885ab3a0/)
