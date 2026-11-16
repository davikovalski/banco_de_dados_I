--- Consulta 5: Oportunidades comerciais
--- Objetivo: listar clientes que JÁ podem comprar itens de parceiros
--- (contrataram ao menos um projeto, RN18) mas que ainda NÃO realizaram nenhuma compra.
--- Recursos: subconsultas com EXISTS e NOT EXISTS, ORDER BY ascendente.
SELECT c.id_cliente,
       c.razao_social,
       c.tipo,
       c.cidade || '/' || c.uf AS localidade
  FROM cliente c
 WHERE EXISTS (SELECT 1
                 FROM projeto p
                WHERE p.id_cliente = c.id_cliente)
   AND NOT EXISTS (SELECT 1 FROM venda v WHERE v.id_cliente = c.id_cliente)
 ORDER BY c.razao_social ASC;
