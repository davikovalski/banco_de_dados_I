--- Consulta 10: Encerramento da caracterização do projeto 4 com transação
--- Objetivo: concluir os experimentos pendentes do projeto 4 (areia de
--- fundição), emitir o laudo APROVADO, mover o projeto para a etapa de
--- DESENVOLVIMENTO e registrar a rota de valorização. Uma rota cadastrada
--- por engano é desfeita com ROLLBACK TO SAVEPOINT antes do COMMIT.
--- Recursos: BEGIN, SAVEPOINT (2), ROLLBACK TO, COMMIT.
--- ATENÇÃO: altera o banco. Para restaurar, rode novamente criar_banco.py.
BEGIN TRANSACTION;

UPDATE experimento
   SET status = 'CONCLUIDO', data_conclusao = '2026-03-20', resultado = 'Teor de finos 8%'
 WHERE id_experimento = 13;
UPDATE experimento
   SET status = 'CONCLUIDO', data_conclusao = '2026-04-02', resultado = 'Classe IIA - não perigoso'
 WHERE id_experimento = 14;

SAVEPOINT sp_laudo;

INSERT INTO laudo (id_laudo, id_projeto, numero, data_emissao, parecer, conclusao)
VALUES (5, 4, 'LD-2026-001', '2026-04-10', 'APROVADO',
        'Areia apta para uso em blocos de concreto sem função estrutural.');

-- Laudo aprovado: o projeto segue para a etapa de desenvolvimento (RN10).
UPDATE projeto SET status = 'DESENVOLVIMENTO' WHERE id_projeto = 4;

SAVEPOINT sp_rotas;

INSERT INTO rota_valorizacao (id_projeto, descricao, aplicacao, data_proposta, representante_cliente, status)
VALUES (4, 'Uso em blocos de concreto para vedação', 'Artefatos de concreto', '2026-04-20',
        'Paulo Reis (EcoGestão)', 'PROPOSTA');

INSERT INTO rota_valorizacao (id_projeto, descricao, aplicacao, data_proposta, representante_cliente, status)
VALUES (4, 'Rota duplicada cadastrada por engano', 'Artefatos de concreto', '2026-04-20',
        'Paulo Reis (EcoGestão)', 'PROPOSTA');

-- Desfaz as rotas (a duplicada foi um erro) e cadastra só a correta.
ROLLBACK TO SAVEPOINT sp_rotas;

INSERT INTO rota_valorizacao (id_projeto, descricao, aplicacao, data_proposta, representante_cliente, status)
VALUES (4, 'Uso em blocos de concreto para vedação', 'Artefatos de concreto', '2026-04-20',
        'Paulo Reis (EcoGestão)', 'PROPOSTA');

COMMIT;

SELECT p.id_projeto, p.status, l.numero, l.parecer, COUNT(r.id_rota) AS rotas
  FROM projeto p
  JOIN laudo l ON l.id_projeto = p.id_projeto
  LEFT JOIN rota_valorizacao r ON r.id_projeto = p.id_projeto
 WHERE p.id_projeto = 4
 GROUP BY p.id_projeto, p.status, l.numero, l.parecer;
