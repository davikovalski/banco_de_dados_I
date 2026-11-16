--- Consulta 8: Amostras recebidas que ainda não foram usadas em experimentos
--- Objetivo: apontar amostras "paradas" no estoque, há quantos dias foram
--- recebidas e se o resíduo já tem projeto aberto (tratando nulos).
--- Recursos: LEFT JOIN (4 tabelas), tratamento de nulos (IS NULL e
---           COALESCE), ORDER BY descendente.
SELECT a.codigo,
       r.nome                                              AS residuo,
       c.razao_social                                      AS industria_geradora,
       a.quantidade || ' ' || a.unidade                    AS quantidade,
       a.data_recebimento,
       CAST(julianday('2026-11-10') - julianday(a.data_recebimento) AS INTEGER) AS dias_em_estoque,
       COALESCE(p.titulo, '*** resíduo sem projeto aberto ***') AS projeto,
       COALESCE(a.observacao, '-')                         AS observacao
  FROM amostra a
  JOIN residuo r          ON r.id_residuo = a.id_residuo
  JOIN cliente c          ON c.id_cliente = r.id_industria
  LEFT JOIN projeto p     ON p.id_residuo = a.id_residuo
  LEFT JOIN experimento e ON e.id_amostra = a.id_amostra
 WHERE e.id_experimento IS NULL
 ORDER BY dias_em_estoque DESC;
