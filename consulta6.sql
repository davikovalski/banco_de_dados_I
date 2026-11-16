--- Consulta 6: Laboratórios parceiros que contribuíram para laudos aprovados
--- Objetivo: listar os laboratórios que executaram experimentos em projetos
--- cuja caracterização foi APROVADA, com o número de experimentos e o
--- valor pago a cada um nesses projetos.
--- Recursos: subconsulta com IN, INNER JOIN, COUNT, SUM, ORDER BY desc.
SELECT lp.nome,
       lp.cidade || '/' || lp.uf     AS localidade,
       COUNT(e.id_experimento)       AS experimentos,
       SUM(e.custo)                  AS valor_pago
  FROM laboratorio_parceiro lp
 INNER JOIN experimento e ON e.id_laboratorio = lp.id_laboratorio
 WHERE e.id_projeto IN (SELECT id_projeto FROM laudo WHERE parecer = 'APROVADO')
 GROUP BY lp.id_laboratorio, lp.nome
 ORDER BY valor_pago DESC;
