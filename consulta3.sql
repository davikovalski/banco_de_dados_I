--- Consulta 3: Duração da caracterização por técnico responsável
--- Objetivo: medir, para cada técnico com projetos que já têm laudo, o
--- tempo médio, mínimo e máximo (em dias) entre o início do projeto e a
--- emissão do laudo; mostra só técnicos com média superior a 30 dias.
--- Recursos: INNER JOIN (4 tabelas), AVG, MIN, MAX, COUNT, HAVING,
---           ORDER BY descendente.
SELECT f.nome                                                       AS tecnico,
       COUNT(l.id_laudo)                                            AS laudos_emitidos,
       ROUND(AVG(julianday(l.data_emissao) - julianday(p.data_inicio)), 1) AS media_dias,
       MIN(julianday(l.data_emissao) - julianday(p.data_inicio))    AS menor_prazo,
       MAX(julianday(l.data_emissao) - julianday(p.data_inicio))    AS maior_prazo
  FROM funcionario f
 INNER JOIN funcionario_tecnico ft ON ft.id_funcionario = f.id_funcionario
 INNER JOIN projeto p              ON p.id_tecnico_resp = ft.id_funcionario
 INNER JOIN laudo l                ON l.id_projeto      = p.id_projeto
 GROUP BY f.id_funcionario, f.nome
HAVING AVG(julianday(l.data_emissao) - julianday(p.data_inicio)) > 30
 ORDER BY media_dias DESC;
