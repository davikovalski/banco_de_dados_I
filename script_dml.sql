-- =====================================================================
-- Projeto Final - CIN 8003 Bancos de Dados e Aplicações
-- Cenário: Startup de valorização de resíduos industriais
-- Arquivo: script_dml.sql  (SGBD alvo: SQLite 3)
-- Conteúdo: inserts com dados válidos para TODAS as tabelas.
-- A ordem respeita as FKs e as regras de negócio (ex.: laudo só depois
-- dos experimentos concluídos; rota só depois do laudo aprovado).
-- =====================================================================

PRAGMA foreign_keys = ON;

-- ---------------- FUNCIONÁRIOS ----------------
INSERT INTO funcionario (id_funcionario, nome, cpf, email, telefone, data_admissao, tipo) VALUES
 (1, 'Ana Beatriz Souza',     '11122233344', 'ana.souza@revalora.com.br',    '48999010001', '2023-02-01', 'TECNICO'),
 (2, 'Bruno Henrique Lima',   '22233344455', 'bruno.lima@revalora.com.br',   '48999010002', '2023-05-15', 'TECNICO'),
 (3, 'Carla Mendes Rocha',    '33344455566', 'carla.rocha@revalora.com.br',  '48999010003', '2024-03-10', 'TECNICO'),
 (4, 'Diego Fernandes Alves', '44455566677', 'diego.alves@revalora.com.br',  '48999010004', '2025-01-20', 'TECNICO'),
 (5, 'Eduarda Martins Costa', '55566677788', 'eduarda.costa@revalora.com.br','48999010005', '2023-02-01', 'ADMINISTRATIVO'),
 (6, 'Felipe Araujo Nunes',   '66677788899', 'felipe.nunes@revalora.com.br', '48999010006', '2024-07-01', 'ADMINISTRATIVO'),
 (7, 'Gabriela Teixeira',     '77788899900', 'gabriela.t@revalora.com.br',   NULL,          '2025-04-14', 'ADMINISTRATIVO');

INSERT INTO funcionario_tecnico (id_funcionario, formacao, registro_conselho, especialidade) VALUES
 (1, 'Engenharia Química',    'CRQ-13-0101', 'Caracterização mineralógica'),
 (2, 'Química Industrial',    'CRQ-13-0202', 'Análises físico-químicas'),
 (3, 'Engenharia de Materiais','CREA-SC-3030', 'Materiais cimentícios'),
 (4, 'Engenharia Ambiental',  NULL,          NULL);

INSERT INTO funcionario_administrativo (id_funcionario, setor, cargo) VALUES
 (5, 'COMERCIAL',  'Gerente Comercial'),
 (6, 'COMERCIAL',  'Executivo de Vendas'),
 (7, 'FINANCEIRO', 'Analista Financeiro');

-- ---------------- CLIENTES ----------------
INSERT INTO cliente (id_cliente, razao_social, cnpj, email, telefone, cidade, uf, data_cadastro, tipo) VALUES
 (1, 'Aço Sul Siderurgia S.A.',        '10000000000101', 'meioambiente@acosul.com.br',  '4733330001', 'Joinville',     'SC', '2024-01-10', 'GERADORA'),
 (2, 'Têxtil Vale do Itajaí Ltda.',    '20000000000102', 'ambiental@textilvale.com.br', '4733330002', 'Blumenau',      'SC', '2024-03-22', 'GERADORA'),
 (3, 'Arrozeira Planalto Ltda.',       '30000000000103', 'contato@arrozplanalto.com.br', NULL,        'Turvo',         'SC', '2024-06-05', 'GERADORA'),
 (4, 'Celulose Serra Catarinense S.A.','40000000000104', 'sga@celuloseserra.com.br',    '4933330004', 'Lages',         'SC', '2025-09-01', 'GERADORA'),
 (5, 'EcoGestão Resíduos Ltda.',       '50000000000105', 'projetos@ecogestao.com.br',   '4833330005', 'Florianópolis', 'SC', '2024-02-18', 'GESTORA'),
 (6, 'Recicla Mais Gerenciamento',     '60000000000106', 'contato@reciclamais.com.br',  '4133330006', 'Curitiba',      'PR', '2024-11-30', 'GESTORA'),
 (7, 'Verde Destino Ambiental Ltda.',  '70000000000107', 'comercial@verdedestino.com.br','5133330007','Porto Alegre',  'RS', '2026-05-12', 'GESTORA'),
 (8, 'Fundição Joinvillense Ltda.',    '80000000000108', 'ambiental@fundjoinville.com.br','4733330008','Joinville',   'SC', '2026-02-10', 'GERADORA'),
 (9, 'Gesso Forte Drywall S.A.',       '90000000000109', 'sga@gessoforte.com.br',       '4133330009', 'Ponta Grossa',  'PR', '2026-06-01', 'GERADORA');

INSERT INTO industria_geradora (id_cliente, setor_industrial, porte) VALUES
 (1, 'Siderurgia',   'GRANDE'),
 (2, 'Têxtil',       'MEDIO'),
 (3, 'Alimentício',  'PEQUENO'),
 (4, 'Papel e celulose', 'GRANDE'),
 (8, 'Metalurgia (fundição)', 'MEDIO'),
 (9, 'Construção civil (drywall)', 'GRANDE');

INSERT INTO empresa_gestora (id_cliente, licenca_ambiental, validade_licenca) VALUES
 (5, 'LAO-IMA-2023-0451', '2027-12-31'),
 (6, 'LO-IAT-2024-1188',  '2028-06-30'),
 (7, 'LO-FEPAM-2025-777', '2029-03-15');

-- ---------------- RESÍDUOS ----------------
INSERT INTO residuo (id_residuo, id_industria, id_gestora, nome, descricao, classe_nbr10004, estado_fisico, data_cadastro) VALUES
 (1, 1, NULL, 'Escória de aciaria',         'Escória LD do processo de refino do aço',        'IIA', 'SOLIDO',  '2025-01-15'),
 (2, 2, NULL, 'Lodo de ETE têxtil',         'Lodo biológico da estação de tratamento',        'I',   'PASTOSO', '2025-03-03'),
 (3, 3, NULL, 'Cinza de casca de arroz',    'Cinza da queima de casca em caldeira',           'IIB', 'SOLIDO',  '2025-05-20'),
 (4, 8, 5,    'Areia de fundição',          'Areia verde descartada; projeto contratado pela gestora EcoGestão','IIA','SOLIDO','2026-02-10'),
 (5, 9, 6,    'Resíduo de gesso',           'Aparas e placas de gesso fora de especificação; projeto contratado pela gestora Recicla Mais','IIB','SOLIDO','2026-06-01'),
 (6, 1, NULL, 'Pó de despoeiramento',       'Pó coletado nos filtros de manga',               'I',   'SOLIDO',  '2025-08-11'),
 (7, 4, 5,    'Lama de cal',                'Lama de cal do ciclo de recuperação química; gerenciada pela EcoGestão',    'IIA', 'PASTOSO', '2026-09-15');

-- ---------------- AMOSTRAS ----------------
INSERT INTO amostra (id_amostra, id_residuo, codigo, quantidade, unidade, data_recebimento, observacao) VALUES
 (1,  1, 'AM-2025-001', 25.000, 'kg', '2025-01-20', NULL),
 (2,  1, 'AM-2025-002', 10.000, 'kg', '2025-02-05', 'Segundo lote, granulometria fina'),
 (3,  2, 'AM-2025-003',  8.500, 'kg', '2025-03-10', 'Refrigerada'),
 (4,  2, 'AM-2025-004',  5.000, 'L',  '2025-03-10', 'Fração líquida'),
 (5,  3, 'AM-2025-005', 15.000, 'kg', '2025-05-25', NULL),
 (6,  6, 'AM-2025-006',  3.200, 'kg', '2025-08-18', NULL),
 (7,  6, 'AM-2025-007',  4.800, 'kg', '2025-09-02', NULL),
 (8,  4, 'AM-2026-001', 30.000, 'kg', '2026-02-15', NULL),
 (9,  4, 'AM-2026-002', 12.000, 'kg', '2026-03-01', 'Amostra de outro forno'),
 (10, 5, 'AM-2026-003', 20.000, 'kg', '2026-06-08', NULL),
 (11, 7, 'AM-2026-004',  6.000, 'kg', '2026-09-20', 'Aguardando abertura de projeto');

-- ---------------- PROJETOS (todos começam em CARACTERIZACAO - RN08) ----------------
-- id_cliente = contratante. Projetos 4 e 5 são contratados por gestoras (clientes 5 e 6)
-- para resíduos de indústrias geradoras (8 e 9). O técnico 3 tem dois projetos em
-- andamento ao mesmo tempo (3 e 4), como permite a RN02.
INSERT INTO projeto (id_projeto, id_residuo, id_cliente, id_tecnico_resp, titulo, data_inicio, valor_contrato) VALUES
 (1, 1, 1, 1, 'Escória de aciaria como agregado para pavimentação', '2025-01-25', 48000.00),
 (2, 2, 2, 2, 'Valorização energética de lodo têxtil',              '2025-03-15', 32000.00),
 (3, 3, 3, 3, 'Cinza de casca de arroz como pozolana',              '2025-06-01', 27500.00),
 (4, 4, 5, 3, 'Reuso de areia de fundição em artefatos de concreto','2026-02-20', 39000.00),
 (5, 5, 6, 4, 'Reciclagem de gesso para a indústria cimenteira',    '2026-06-15', NULL),
 (6, 6, 1, 2, 'Recuperação de zinco do pó de despoeiramento',       '2025-08-25', 55000.00);

-- ---------------- LABORATÓRIOS PARCEIROS ----------------
INSERT INTO laboratorio_parceiro (id_laboratorio, nome, cnpj, cidade, uf, acreditado_inmetro) VALUES
 (1, 'LabMin Análises Minerais',     '81000000000181', 'Criciúma',      'SC', 1),
 (2, 'Instituto Tecnológico Ambiental','82000000000182','São Paulo',    'SP', 1),
 (3, 'QuimLab Serviços Analíticos',  '83000000000183', 'Florianópolis', 'SC', 0);

-- ---------------- EXPERIMENTOS ----------------
INSERT INTO experimento (id_experimento, id_projeto, id_amostra, tipo_analise, local_execucao, id_laboratorio, id_tecnico_exec, data_inicio, data_conclusao, status, resultado, custo) VALUES
 -- Projeto 1 (escória) - todos concluídos
 (1,  1, 1, 'Fluorescência de raios X (FRX)', 'EXTERNO', 1, NULL, '2025-02-01', '2025-02-12', 'CONCLUIDO', 'CaO 42%, Fe2O3 25%, SiO2 13%', 1800.00),
 (2,  1, 1, 'Granulometria',                  'INTERNO', NULL, 1, '2025-02-03', '2025-02-05', 'CONCLUIDO', 'D50 = 4,8 mm', 150.00),
 (3,  1, 2, 'Expansibilidade (PTM-130)',      'INTERNO', NULL, 3, '2025-02-10', '2025-03-10', 'CONCLUIDO', 'Expansão 1,2% < limite 3%', 600.00),
 -- Projeto 2 (lodo têxtil) - concluídos, caracterização será rejeitada
 (4,  2, 3, 'Lixiviação NBR 10005',           'EXTERNO', 2, NULL, '2025-03-20', '2025-04-15', 'CONCLUIDO', 'Cromo acima do limite', 2400.00),
 (5,  2, 4, 'Poder calorífico',               'EXTERNO', 3, 2,    '2025-03-22', '2025-04-02', 'CONCLUIDO', 'PCI 1.150 kcal/kg (baixo)', 900.00),
 (6,  2, 3, 'Umidade e sólidos voláteis',     'INTERNO', NULL, 2, '2025-03-18', '2025-03-19', 'CONCLUIDO', 'Umidade 78%', 120.00),
 -- Projeto 3 (cinza) - concluídos
 (7,  3, 5, 'Difração de raios X (DRX)',      'EXTERNO', 1, NULL, '2025-06-05', '2025-06-20', 'CONCLUIDO', 'Sílica amorfa predominante', 1500.00),
 (8,  3, 5, 'Índice de atividade pozolânica', 'INTERNO', NULL, 3, '2025-06-10', '2025-07-08', 'CONCLUIDO', 'IAP 92%', 700.00),
 -- Projeto 6 (pó de despoeiramento) - concluídos + 1 cancelado
 (9,  6, 6, 'Fluorescência de raios X (FRX)', 'EXTERNO', 1, NULL, '2025-08-28', '2025-09-10', 'CONCLUIDO', 'ZnO 28%', 1800.00),
 (10, 6, 7, 'Lixiviação NBR 10005',           'EXTERNO', 2, NULL, '2025-09-05', '2025-10-01', 'CONCLUIDO', 'Pb e Cd acima do limite (Classe I)', 2400.00),
 (11, 6, 7, 'Ensaio de pelotização',          'INTERNO', NULL, 4, '2025-09-10', NULL,         'CANCELADO', NULL, 0),
 -- Projeto 4 (areia de fundição) - caracterização em andamento
 (12, 4, 8, 'Granulometria',                  'INTERNO', NULL, 3, '2026-02-25', '2026-02-26', 'CONCLUIDO', 'Módulo de finura 1,9', 150.00),
 (13, 4, 8, 'Teor de argila e finos',         'INTERNO', NULL, 4, '2026-03-02', NULL,         'EM_ANDAMENTO', NULL, 200.00),
 (14, 4, 9, 'Lixiviação NBR 10005',           'EXTERNO', 2, NULL, '2026-03-05', NULL,         'PLANEJADO', NULL, 2400.00);

-- ---------------- LAUDOS ----------------
INSERT INTO laudo (id_laudo, id_projeto, numero, data_emissao, parecer, conclusao) VALUES
 (1, 1, 'LD-2025-001', '2025-03-15', 'APROVADO',  'Escória estável, apta para uso como agregado.'),
 (2, 2, 'LD-2025-002', '2025-04-20', 'REJEITADO', 'Teor de cromo inviabiliza as rotas avaliadas.'),
 (3, 3, 'LD-2025-003', '2025-07-15', 'APROVADO',  'Alta reatividade pozolânica.'),
 (4, 6, 'LD-2025-004', '2025-10-10', 'APROVADO',  'Teor de zinco viabiliza recuperação metalúrgica.');

-- Parecer do laudo define o destino do projeto (RN09/RN10)
UPDATE projeto SET status = 'DESENVOLVIMENTO'                       WHERE id_projeto IN (1, 3, 6);
UPDATE projeto SET status = 'ENCERRADO', data_fim = '2025-04-20'    WHERE id_projeto = 2;

-- ---------------- ROTAS DE VALORIZAÇÃO (só projetos em DESENVOLVIMENTO) ----------------
INSERT INTO rota_valorizacao (id_rota, id_projeto, descricao, aplicacao, data_proposta, representante_cliente, status) VALUES
 (1, 1, 'Uso como agregado em base e sub-base de pavimentos', 'Agregado para pavimentação', '2025-04-01', 'Marcos Pereira (Aço Sul)',  'ACORDADA'),
 (2, 1, 'Uso em lastro ferroviário',                          'Lastro ferroviário',         '2025-04-01', 'Marcos Pereira (Aço Sul)',  'DESCARTADA'),
 (3, 3, 'Substituição parcial de cimento em concreto',        'Pozolana',                   '2025-08-01', 'Joana Fritzen (Arrozeira)', 'PROPOSTA'),
 (4, 3, 'Produção de sílica para borracha',                   'Sílica precipitada',         '2025-08-20', 'Joana Fritzen (Arrozeira)', 'PROPOSTA'),
 (5, 6, 'Envio a recuperadora de zinco via processo Waelz',   'Recuperação metalúrgica',    '2025-11-05', 'Marcos Pereira (Aço Sul)',  'ACORDADA');

-- Projeto 1 concluído (tem rota acordada)
UPDATE projeto SET status = 'CONCLUIDO', data_fim = '2025-09-30' WHERE id_projeto = 1;

-- ---------------- EMPRESAS PARCEIRAS (com dados da parceria) ----------------
INSERT INTO empresa_parceira (id_empresa, razao_social, cnpj, email, ramo,
                              data_inicio_parceria, data_fim_parceria, percentual_comissao, status_parceria) VALUES
 (1, 'Moinhos Industriais Brasil Ltda.', '91000000000191', 'vendas@moinhosbr.com.br',   'EQUIPAMENTO', '2024-06-01', NULL,          8.00, 'ATIVA'),
 (2, 'TransAmbiental Logística',         '92000000000192', 'comercial@transamb.com.br', 'SERVICO',     '2024-09-01', NULL,          5.00, 'ATIVA'),
 (3, 'Secadores Térmicos do Sul',        '93000000000193', 'contato@secasul.com.br',    'EQUIPAMENTO', '2024-01-01', '2025-06-30', 10.00, 'INATIVA'),
 (4, 'Consultoria Licencia Verde',       '94000000000194', 'ola@licenciaverde.com.br',  'AMBOS',       '2025-03-01', '2027-02-28', 12.50, 'ATIVA');

-- ---------------- VENDAS (só clientes com projeto - RN18) ----------------
INSERT INTO venda (id_venda, id_cliente, id_func_adm, data_venda) VALUES
 (1, 1, 5, '2025-10-15'),
 (2, 1, 5, '2025-10-15'),
 (3, 1, 6, '2025-11-20'),
 (4, 3, 5, '2025-09-02'),
 (5, 3, 5, '2025-09-02'),
 (6, 5, 6, '2026-04-10'),
 (7, 5, 5, '2026-05-22'),
 (8, 5, 5, '2026-05-22'),
 (9, 6, 6, '2026-08-05');

-- ---------------- ITENS DA VENDA (1:1 com a venda; ligados direto à empresa parceira) ----------------
-- percentual_comissao = percentual da parceria na data da venda (RN17).
INSERT INTO item_venda (id_item_venda, id_venda, id_empresa, descricao, tipo, quantidade, preco_unitario, percentual_comissao) VALUES
 (1, 1, 1, 'Moinho de bolas MB-500',                'EQUIPAMENTO',   1, 180000.00, 8.00),
 (2, 2, 1, 'Peneira vibratória PV-2',               'EQUIPAMENTO',   2,  41000.00, 8.00),
 (3, 3, 2, 'Transporte de resíduo Classe I (t)',    'SERVICO',     120,    400.00, 5.00),
 (4, 4, 4, 'Licenciamento de unidade de reciclagem','SERVICO',       1,  35000.00, 12.50),
 (5, 5, 4, 'Kit de monitoramento de emissões',      'EQUIPAMENTO',   1,  17500.00, 12.50),
 (6, 6, 2, 'Transporte de resíduo Classe II (t)',   'SERVICO',     300,    175.00, 5.00),
 (7, 7, 1, 'Peneira vibratória PV-2',               'EQUIPAMENTO',   1,  42000.00, 8.00),
 (8, 8, 2, 'Frete do equipamento',                  'SERVICO',       1,   2500.00, 5.00),
 (9, 9, 4, 'Licenciamento de unidade de reciclagem','SERVICO',       1,  34000.00, 12.50);
