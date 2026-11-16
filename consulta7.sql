--- Consulta 7: Ranking de comissões por empresa parceira
--- Objetivo: calcular o total vendido e a comissão recebida pela startup
--- com os itens de cada empresa parceira, a participação percentual de
--- cada uma no total de comissões e o vendedor (funcionário administrativo)
--- que mais vendeu itens daquela parceira.
--- Recursos: CTE (WITH), INNER JOIN, SUM, COUNT, subconsulta escalar,
---           ORDER BY descendente.
WITH comissao_item AS (
    SELECT iv.id_venda,
           iv.id_empresa,
           v.id_func_adm,
           iv.quantidade * iv.preco_unitario                                   AS valor_item,
           iv.quantidade * iv.preco_unitario * iv.percentual_comissao / 100.0  AS comissao
      FROM item_venda iv
     INNER JOIN venda v ON v.id_venda = iv.id_venda
),
total_parceira AS (
    SELECT id_empresa,
           COUNT(DISTINCT id_venda) AS qtd_vendas,
           SUM(valor_item)          AS total_vendido,
           SUM(comissao)            AS total_comissao
      FROM comissao_item
     GROUP BY id_empresa
)
SELECT ep.razao_social                                   AS parceira,
       t.qtd_vendas,
       t.total_vendido,
       ROUND(t.total_comissao, 2)                        AS total_comissao,
       ROUND(100.0 * t.total_comissao /
             (SELECT SUM(comissao) FROM comissao_item), 1) AS participacao_pct,
       (SELECT f.nome
          FROM comissao_item ci JOIN funcionario f ON f.id_funcionario = ci.id_func_adm
         WHERE ci.id_empresa = t.id_empresa
         GROUP BY f.id_funcionario
         ORDER BY SUM(ci.valor_item) DESC
         LIMIT 1)                                        AS principal_vendedor
  FROM total_parceira t
 INNER JOIN empresa_parceira ep ON ep.id_empresa = t.id_empresa
 ORDER BY total_comissao DESC;
