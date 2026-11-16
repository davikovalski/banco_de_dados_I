--- Consulta 2: Carteira de clientes e seus projetos
--- Objetivo: listar TODOS os clientes (inclusive os que ainda não
--- contrataram projeto), com o tipo, a quantidade de projetos contratados,
--- os resíduos tratados nesses projetos e o valor contratado (nulos = 0).
--- Clientes sem projeto não podem comprar itens de parceiros (RN18).
--- Recursos: LEFT JOIN (3 tabelas), COUNT, SUM, tratamento de nulos
---           (COALESCE / CASE ... IS NULL), ORDER BY descendente.
SELECT c.razao_social,
       c.tipo,
       COUNT(p.id_projeto)                     AS qtd_projetos,
       COALESCE(GROUP_CONCAT(r.nome, '; '), '-') AS residuos_em_projeto,
       COALESCE(SUM(p.valor_contrato), 0)      AS valor_contratado,
       CASE WHEN MAX(p.id_projeto) IS NULL
            THEN 'Sem projeto (não pode comprar de parceiros)'
            ELSE 'Com projeto' END             AS situacao
  FROM cliente c
  LEFT JOIN projeto p ON p.id_cliente = c.id_cliente
  LEFT JOIN residuo r ON r.id_residuo = p.id_residuo
 GROUP BY c.id_cliente, c.razao_social, c.tipo
 ORDER BY valor_contratado DESC, c.razao_social ASC;
