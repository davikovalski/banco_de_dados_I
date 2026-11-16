--- Consulta 1: Custo dos experimentos por projeto e por local de execução
--- Objetivo: para cada projeto, mostrar quantos experimentos foram feitos
--- internamente e em laboratórios parceiros e quanto custaram, exibindo
--- apenas os grupos com custo acima de R$ 500.
--- Recursos: INNER JOIN (3 tabelas), COUNT, SUM, GROUP BY com 2 colunas,
---           HAVING, ORDER BY ascendente.
SELECT p.id_projeto,
       p.titulo,
       r.nome                  AS residuo,
       e.local_execucao,
       COUNT(e.id_experimento) AS qtd_experimentos,
       SUM(e.custo)            AS custo_total
  FROM projeto p
 INNER JOIN residuo r     ON r.id_residuo = p.id_residuo
 INNER JOIN experimento e ON e.id_projeto = p.id_projeto
 GROUP BY p.id_projeto, e.local_execucao
HAVING SUM(e.custo) > 500
 ORDER BY p.id_projeto ASC, e.local_execucao ASC;
