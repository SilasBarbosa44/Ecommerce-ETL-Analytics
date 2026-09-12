-- 01. Faturamento por cliente
select
	c.nome as cliente,
    sum(i.quantidade * i.preco_unitario) as faturamento
from clientes c inner join pedidos p on(c.id_cliente = p.id_cliente)
inner join itens_pedido i on(i.id_pedido = p.id_pedido)
group by c.nome, c.id_cliente
order by faturamento desc;



-- 02. Top 10 produtos mais vendidos

select
	pr.nome_produto as produto,
    sum(i.quantidade) as total_vendidas
from produtos pr inner join itens_pedido i on(pr.id_produto = i.id_produto)
inner join pedidos p on(p.id_pedido = i.id_pedido)
group by pr.nome_produto, pr.id_produto
order by total_vendidas desc
limit 10;




-- 03. Faturamento por categoria

select
	ca.nome_categoria as categoria,
    sum(i.quantidade * i.preco_unitario) as faturamento
from categorias ca join produtos pr on(pr.id_categoria = ca.id_categoria)
join itens_pedido i on(i.id_produto = pr.id_produto)
group by ca.nome_categoria, ca.id_categoria
order by faturamento desc;



-- 04. Faturamento por vendedor

select
	ve.nome as vendedor,
    sum(i.quantidade * i.preco_unitario) as faturamento
from vendedores ve inner join pedidos p on(ve.id_vendedor = p.id_vendedor)
inner join itens_pedido i on(i.id_pedido = p.id_pedido)
group by ve.nome, ve.id_vendedor
order by faturamento desc;




-- 05. Ticket médio por cliente

select
	c.nome as cliente,
    sum(i.quantidade * i.preco_unitario) as faturamento,
    round(sum(i.quantidade * i.preco_unitario) / count(distinct p.id_pedido), 2) as ticket_medio
from clientes c inner join pedidos p on(c.id_cliente = p.id_cliente)
inner join itens_pedido i on(i.id_pedido = p.id_pedido)
group by c.nome, c.id_cliente
order by faturamento desc;



-- 06. Ranking de vendedores


select
	ve.nome as vendedor,
    sum(i.quantidade * i.preco_unitario) as faturamento,
    dense_rank() over(partition by ve.nome order by faturamento desc) as ranking
from vendedores ve inner join pedidos p on(ve.id_vendedor = p.id_vendedor)
inner join itens_pedido i on(i.id_pedido = p.id_pedido)
group by ve.nome, ve.id_vendedor
order by ranking;



-- 07. Faturamento mensal

select
	month(p.data_pedido) as mes,
    year(p.data_pedido) as ano,
    sum(i.quantidade * i.preco_unitario) as faturamento
from pedidos p inner join itens_pedido i on(p.id_pedido = i.id_pedido)
group by month(p.data_pedido),
year(p.data_pedido);

-- 08. Pagamentos por cliente


select
	c.nome as cliente,
    count(distinct p.id_pedido) as total_pedidos,
	count(distinct pa.id_pagamento) as total_pagamentos,
    sum(pa.valor_pago) as total_pago
from clientes c inner join pedidos p on(c.id_cliente = p.id_cliente)
inner join pagamentos pa on(pa.id_pedido = p.id_pedido)
group by c.nome, c.id_cliente
order by total_pago desc;


-- 09. Top 10 clientes por quantidade de pedidos

select
	c.nome as cliente,
    count(p.id_pedido) as total_pedidos
from clientes c inner join pedidos p on(c.id_cliente = p.id_cliente)
group by c.nome, c.id_cliente
order by total_pedidos desc
limit 10;



-- 10. Vendedores acima do faturamento médio

with vendedores as(select
	ve.nome as vendedor,
    sum(i.quantidade * i.preco_unitario) as faturamento
from vendedores ve inner join pedidos p on(ve.id_vendedor = p.id_vendedor)
inner join itens_pedido i on(i.id_pedido = p.id_pedido)
group by ve.nome, ve.id_vendedor)
select
* from vendedores
where faturamento > (select avg(faturamento) from vendedores); 



-- 11. Ranking de produtos por faturamento


select
	pr.nome_produto as produto,
    ca.nome_categoria as categoria,
    dense_rank() over(order by faturamento desc) as ranking,
    sum(i.quantidade * i.preco_unitario) as faturamento
from produtos pr inner join categorias ca on(pr.id_categoria = ca.id_categoria)
inner join itens_pedido i on(i.id_produto = pr.id_produto)
group by pr.nome_produto, pr.id_produto
order by ranking;

-- 12. Ranking de vendedores por cliente


with faturamento_vendedores as(select
	ve.nome as vendedor,
    c.nome as cliente,
    sum(i.quantidade * i.preco_unitario) as faturamento
from clientes c inner join pedidos p on(c.id_cliente = p.id_cliente)
inner join vendedores ve on(ve.id_vendedor = p.id_vendedor)
inner join itens_pedido i on(i.id_pedido = p.id_pedido)
group by ve.nome, ve.id_vendedor),
ranking as(select
*, dense_rank() over(partition by cliente order by faturamento desc) as ranking
from faturamento_vendedores)
select
* from ranking;



-- 13. Crescimento percentual do faturamento mensal

with faturamento_mensal as(select
	month(p.data_pedido) as mes,
    year(p.data_pedido) as ano,
    sum(i.quantidade * i.preco_unitario) as faturamento
from pedidos p inner join itens_pedido i on(p.id_pedido = i.id_pedido)
group by month(p.data_pedido),
year(p.data_pedido)),
faturamento_anterior as(select
*, lag(faturamento) over(order by faturamento) as faturamento_anterior
from faturamento_mensal),
crescimento_percentual as(select
*, round((faturamento - faturamento_anterior) / faturamento_anterior * 100, 2) as crescimento_percentual
from faturamento_anterior)
select *
from crescimento_percentual;


-- 14. Relatório completo de clientes

with relatorio_clientes as(select
	c.nome as cliente,
    month(p.data_pedido) as mes,
    year(p.data_pedido) as ano,
    count(distinct p.id_pedido) as total_pedidos,
    sum(i.quantidade * i.preco_unitario) as faturamento,
    datediff(curdate(), max(p.data_pedido)) as diferencas_dias
from clientes c inner join pedidos p on(c.id_cliente = p.id_cliente)
inner join itens_pedido i on(i.id_pedido = p.id_pedido)
group by c.nome, c.id_cliente, month(p.data_pedido), year(p.data_pedido)),
ranking as(select
*, dense_rank() over(partition by cliente order by ano, mes) as ranking
from relatorio_clientes),
clientes_inativos as(select
*, case
when diferencas_dias >= 90 then 'Cliente inativo'
when diferencas_dias >= 30 then 'Cliente ativo'
else 'Cliente novo'
end clientes_inativos
from ranking),
classificacao as(select
*, case
when faturamento >= 7000 then 'Valor alto'
when faturamento >= 5000 then 'Valor medio'
else 'Valor baixo'
end classificacao
from clientes_inativos),
percentual_participacao as(select
*, round(faturamento / sum(faturamento) over() * 100, 2) as percentual_participacao
from classificacao),
proximo_faturamento as(select
*, lead(faturamento) over(partition by cliente order by ano, mes) as proximo_faturamento
from percentual_participacao),
primeiro_faturamento as(select
*, first_value(faturamento) over(partition by cliente order by ano, mes) as primeiro_faturamento
from proximo_faturamento),
ultimo_faturamento as(select
*, last_value(faturamento) over(partition by cliente order by ano, mes ) as ultimo_faturamento
from primeiro_faturamento),
clientes_recorrentes as(select
*, case 
when total_pedidos >= 2 then 'Cliente recorrente'
else 'Cliente novo'
end as clientes_recorrentes
from ultimo_faturamento)
select
* from clientes_recorrentes
order by ano, mes;
    