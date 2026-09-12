-- ============================================================
-- BANCO DE DADOS
-- ============================================================

DROP DATABASE IF EXISTS ecommerce_analytics;

CREATE DATABASE ecommerce_analytics
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;


use ecommerce_analytics;

-- ============================================================
-- TABELA: CATEGORIAS
-- ============================================================

CREATE TABLE categorias (
    id_categoria INT NOT NULL,
    nome_categoria VARCHAR(100) NOT NULL,

    PRIMARY KEY (id_categoria)
);



-- ============================================================
-- TABELA: CLIENTES
-- ============================================================

CREATE TABLE clientes (
    id_cliente INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,
    data_cadastro DATE NOT NULL,

    PRIMARY KEY (id_cliente),

    UNIQUE KEY uk_clientes_email (email)
);


-- ============================================================
-- TABELA: VENDEDORES
-- ============================================================

CREATE TABLE vendedores (
    id_vendedor INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    equipe VARCHAR(100) NOT NULL,
    data_admissao DATE NOT NULL,

    PRIMARY KEY (id_vendedor)
);


-- ============================================================
-- TABELA: PRODUTOS
-- ============================================================

CREATE TABLE produtos (
    id_produto INT NOT NULL,
    nome_produto VARCHAR(150) NOT NULL,
    id_categoria INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL,

    PRIMARY KEY (id_produto),

    CONSTRAINT fk_produtos_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
);


-- ============================================================
-- TABELA: PEDIDOS
-- ============================================================

CREATE TABLE pedidos (
    id_pedido INT NOT NULL,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    data_pedido DATE NOT NULL,
    status VARCHAR(30) NOT NULL,

    PRIMARY KEY (id_pedido),

    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    CONSTRAINT fk_pedidos_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedores(id_vendedor)
);


-- ============================================================
-- TABELA: ITENS_PEDIDO
-- ============================================================

CREATE TABLE itens_pedido (
    id_item INT NOT NULL,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (id_item),

    CONSTRAINT fk_itens_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedidos(id_pedido),

    CONSTRAINT fk_itens_produto
        FOREIGN KEY (id_produto)
        REFERENCES produtos(id_produto)
);


-- ============================================================
-- TABELA: PAGAMENTOS
-- ============================================================

CREATE TABLE pagamentos (
    id_pagamento INT NOT NULL,
    id_pedido INT NOT NULL,
    data_pagamento DATE NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(50) NOT NULL,
    status_pagamento VARCHAR(30) NOT NULL,

    PRIMARY KEY (id_pagamento),

    CONSTRAINT fk_pagamentos_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedidos(id_pedido)
);


