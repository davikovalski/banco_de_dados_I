--- Consulta 9: Registro de uma venda com controle transacional
--- Objetivo: registrar uma nova venda para a EcoGestão (cliente 5) feita
--- pelo funcionário administrativo 6, com um serviço da empresa parceira 4
--- (cada venda tem um único item). Um desconto não autorizado aplicado ao
--- item é desfeito com ROLLBACK TO SAVEPOINT, e a venda com o preço correto
--- é confirmada com COMMIT. Ao final, consulta o resumo da venda.
--- Recursos: BEGIN, SAVEPOINT, ROLLBACK TO, RELEASE, COMMIT.
--- ATENÇÃO: altera o banco. Para restaurar, rode novamente criar_banco.py.
BEGIN TRANSACTION;

INSERT INTO venda (id_venda, id_cliente, id_func_adm, data_venda)
VALUES (10, 5, 6, '2026-11-10');

INSERT INTO item_venda (id_venda, id_empresa, descricao, tipo, quantidade, preco_unitario, percentual_comissao)
VALUES (10, 4, 'Licenciamento de unidade de reciclagem', 'SERVICO', 1, 35000.00, 12.50);

SAVEPOINT sp_desconto;

UPDATE item_venda SET preco_unitario = 17500.00     -- 50% de desconto: não autorizado
 WHERE id_venda = 10;

-- O desconto não foi aprovado pela gerência: volta ao preço original.
ROLLBACK TO SAVEPOINT sp_desconto;
RELEASE SAVEPOINT sp_desconto;

COMMIT;

SELECT * FROM vw_venda_resumo WHERE id_venda = 10;
