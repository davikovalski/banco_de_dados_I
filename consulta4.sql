--- Consulta 4: Projetos com custo de experimentos acima da média
--- Objetivo: identificar os projetos cujo custo total de experimentos é
--- maior que o custo médio por projeto da startup.
--- Recursos: subconsulta ESCALAR (média geral), subconsulta na cláusula
---           FROM, SUM, AVG, ORDER BY descendente.
SELECT p.id_projeto,
       p.titulo,
       p.status,
       SUM(e.custo) AS custo_experimentos,
       (SELECT ROUND(AVG(t.total), 2)
          FROM (SELECT SUM(custo) AS total FROM experimento GROUP BY id_projeto) t
       ) AS media_por_projeto
  FROM projeto p
  JOIN experimento e ON e.id_projeto = p.id_projeto
 GROUP BY p.id_projeto, p.titulo, p.status
HAVING SUM(e.custo) > (SELECT AVG(t.total)
                         FROM (SELECT SUM(custo) AS total FROM experimento GROUP BY id_projeto) t)
 ORDER BY custo_experimentos DESC;
