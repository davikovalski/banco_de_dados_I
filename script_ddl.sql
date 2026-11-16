-- =====================================================================
-- Projeto Final - CIN 8003 Bancos de Dados e Aplicações
-- Cenário: Startup de valorização de resíduos industriais
-- Arquivo: script_ddl.sql  (SGBD alvo: SQLite 3)
-- Conteúdo: criação de tabelas com PK, FK, NOT NULL, UNIQUE, CHECK,
--           DEFAULT e ações referenciais, e uma view de apoio.
--           Sem triggers: regras que dependem de outras tabelas são
--           garantidas pela aplicação (ver docs/01_requisitos.md).
-- =====================================================================

PRAGMA foreign_keys = ON;

DROP VIEW    IF EXISTS vw_venda_resumo;
DROP TABLE   IF EXISTS item_venda;
DROP TABLE   IF EXISTS venda;
DROP TABLE   IF EXISTS empresa_parceira;
DROP TABLE   IF EXISTS rota_valorizacao;
DROP TABLE   IF EXISTS laudo;
DROP TABLE   IF EXISTS experimento;
DROP TABLE   IF EXISTS laboratorio_parceiro;
DROP TABLE   IF EXISTS projeto;
DROP TABLE   IF EXISTS amostra;
DROP TABLE   IF EXISTS residuo;
DROP TABLE   IF EXISTS empresa_gestora;
DROP TABLE   IF EXISTS industria_geradora;
DROP TABLE   IF EXISTS cliente;
DROP TABLE   IF EXISTS funcionario_administrativo;
DROP TABLE   IF EXISTS funcionario_tecnico;
DROP TABLE   IF EXISTS funcionario;

-- ---------------------------------------------------------------------
-- FUNCIONÁRIO (superclasse) e especializações (total e disjunta)
-- A coluna "tipo" + UNIQUE(id_funcionario, tipo) permite que as
-- subclasses referenciem a superclasse por FK composta, garantindo
-- que um técnico não possa ser cadastrado como administrativo (RN19).
-- ---------------------------------------------------------------------
CREATE TABLE funcionario (
    id_funcionario   INTEGER PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    cpf              CHAR(11)     NOT NULL UNIQUE CHECK (length(cpf) = 11),
    email            VARCHAR(100) NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'),
    telefone         VARCHAR(20),
    data_admissao    DATE         NOT NULL DEFAULT (date('now')),
    tipo             VARCHAR(15)  NOT NULL CHECK (tipo IN ('TECNICO','ADMINISTRATIVO')),
    ativo            INTEGER      NOT NULL DEFAULT 1 CHECK (ativo IN (0,1)),
    UNIQUE (id_funcionario, tipo)
);

CREATE TABLE funcionario_tecnico (
    id_funcionario    INTEGER PRIMARY KEY,
    tipo              VARCHAR(15)  NOT NULL DEFAULT 'TECNICO' CHECK (tipo = 'TECNICO'),
    formacao          VARCHAR(80)  NOT NULL,
    registro_conselho VARCHAR(30)  UNIQUE,              -- ex.: CRQ, CREA
    especialidade     VARCHAR(80),
    FOREIGN KEY (id_funcionario, tipo) REFERENCES funcionario (id_funcionario, tipo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE funcionario_administrativo (
    id_funcionario   INTEGER PRIMARY KEY,
    tipo             VARCHAR(15)  NOT NULL DEFAULT 'ADMINISTRATIVO' CHECK (tipo = 'ADMINISTRATIVO'),
    setor            VARCHAR(50)  NOT NULL CHECK (setor IN ('COMERCIAL','FINANCEIRO','RH','DIRETORIA')),
    cargo            VARCHAR(50)  NOT NULL,
    FOREIGN KEY (id_funcionario, tipo) REFERENCES funcionario (id_funcionario, tipo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- CLIENTE (superclasse) e especializações (total e disjunta)
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente       INTEGER PRIMARY KEY,
    razao_social     VARCHAR(120) NOT NULL,
    cnpj             CHAR(14)     NOT NULL UNIQUE CHECK (length(cnpj) = 14),
    email            VARCHAR(100) NOT NULL CHECK (email LIKE '%_@_%._%'),
    telefone         VARCHAR(20),
    cidade           VARCHAR(60)  NOT NULL,
    uf               CHAR(2)      NOT NULL CHECK (length(uf) = 2),
    data_cadastro    DATE         NOT NULL DEFAULT (date('now')),
    tipo             VARCHAR(10)  NOT NULL CHECK (tipo IN ('GERADORA','GESTORA')),
    UNIQUE (id_cliente, tipo)
);

CREATE TABLE industria_geradora (
    id_cliente        INTEGER PRIMARY KEY,
    tipo              VARCHAR(10)  NOT NULL DEFAULT 'GERADORA' CHECK (tipo = 'GERADORA'),
    setor_industrial  VARCHAR(60)  NOT NULL,
    porte             VARCHAR(10)  NOT NULL CHECK (porte IN ('PEQUENO','MEDIO','GRANDE')),
    FOREIGN KEY (id_cliente, tipo) REFERENCES cliente (id_cliente, tipo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE empresa_gestora (
    id_cliente         INTEGER PRIMARY KEY,
    tipo               VARCHAR(10)  NOT NULL DEFAULT 'GESTORA' CHECK (tipo = 'GESTORA'),
    licenca_ambiental  VARCHAR(30)  NOT NULL UNIQUE,
    validade_licenca   DATE         NOT NULL,
    FOREIGN KEY (id_cliente, tipo) REFERENCES cliente (id_cliente, tipo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- RESÍDUO e AMOSTRA
-- ---------------------------------------------------------------------
CREATE TABLE residuo (
    id_residuo        INTEGER PRIMARY KEY,
    id_industria      INTEGER      NOT NULL,      -- indústria geradora que envia o resíduo (RN05)
    id_gestora        INTEGER,                    -- empresa gestora responsável (opcional, RN28)
    nome              VARCHAR(100) NOT NULL,
    descricao         TEXT,
    classe_nbr10004   VARCHAR(5)   NOT NULL CHECK (classe_nbr10004 IN ('I','IIA','IIB')),
    estado_fisico     VARCHAR(10)  NOT NULL CHECK (estado_fisico IN ('SOLIDO','LIQUIDO','PASTOSO','GASOSO')),
    data_cadastro     DATE         NOT NULL DEFAULT (date('now')),
    FOREIGN KEY (id_industria) REFERENCES industria_geradora (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_gestora) REFERENCES empresa_gestora (id_cliente)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE amostra (
    id_amostra        INTEGER PRIMARY KEY,
    id_residuo        INTEGER      NOT NULL,
    codigo            VARCHAR(20)  NOT NULL UNIQUE,
    quantidade        DECIMAL(10,3) NOT NULL CHECK (quantidade > 0),
    unidade           VARCHAR(3)   NOT NULL DEFAULT 'kg' CHECK (unidade IN ('g','kg','mL','L')),
    data_recebimento  DATE         NOT NULL,
    observacao        TEXT,
    FOREIGN KEY (id_residuo) REFERENCES residuo (id_residuo)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- PROJETO
-- status: CARACTERIZACAO -> (laudo) -> DESENVOLVIMENTO -> CONCLUIDO
--                                   \-> ENCERRADO (caracterização rejeitada)
-- ---------------------------------------------------------------------
CREATE TABLE projeto (
    id_projeto        INTEGER PRIMARY KEY,
    id_residuo        INTEGER      NOT NULL UNIQUE, -- RN07: 1:1 com resíduo
    id_cliente        INTEGER      NOT NULL,      -- cliente contratante (geradora ou gestora)
    id_tecnico_resp   INTEGER      NOT NULL,      -- RN01: um único técnico responsável
    titulo            VARCHAR(120) NOT NULL,
    data_inicio       DATE         NOT NULL DEFAULT (date('now')),
    data_fim          DATE,
    status            VARCHAR(15)  NOT NULL DEFAULT 'CARACTERIZACAO'
                      CHECK (status IN ('CARACTERIZACAO','DESENVOLVIMENTO','CONCLUIDO','ENCERRADO')),
    valor_contrato    DECIMAL(12,2) CHECK (valor_contrato IS NULL OR valor_contrato >= 0),
    CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CHECK ((status IN ('CONCLUIDO','ENCERRADO')) = (data_fim IS NOT NULL)),
    FOREIGN KEY (id_residuo) REFERENCES residuo (id_residuo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_tecnico_resp) REFERENCES funcionario_tecnico (id_funcionario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- LABORATÓRIO PARCEIRO e EXPERIMENTO
-- ---------------------------------------------------------------------
CREATE TABLE laboratorio_parceiro (
    id_laboratorio    INTEGER PRIMARY KEY,
    nome              VARCHAR(100) NOT NULL,
    cnpj              CHAR(14)     NOT NULL UNIQUE CHECK (length(cnpj) = 14),
    cidade            VARCHAR(60)  NOT NULL,
    uf                CHAR(2)      NOT NULL CHECK (length(uf) = 2),
    acreditado_inmetro INTEGER     NOT NULL DEFAULT 0 CHECK (acreditado_inmetro IN (0,1))
);

CREATE TABLE experimento (
    id_experimento    INTEGER PRIMARY KEY,
    id_projeto        INTEGER      NOT NULL,
    id_amostra        INTEGER      NOT NULL,
    tipo_analise      VARCHAR(60)  NOT NULL,       -- ex.: FRX, DRX, lixiviação, poder calorífico
    local_execucao    VARCHAR(8)   NOT NULL CHECK (local_execucao IN ('INTERNO','EXTERNO')),
    id_laboratorio    INTEGER,                     -- obrigatório só se EXTERNO
    id_tecnico_exec   INTEGER,                     -- obrigatório só se INTERNO
    data_inicio       DATE         NOT NULL,
    data_conclusao    DATE,
    status            VARCHAR(12)  NOT NULL DEFAULT 'PLANEJADO'
                      CHECK (status IN ('PLANEJADO','EM_ANDAMENTO','CONCLUIDO','CANCELADO')),
    resultado         TEXT,
    custo             DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (custo >= 0),
    CHECK ( (local_execucao = 'INTERNO' AND id_laboratorio IS NULL AND id_tecnico_exec IS NOT NULL)
         OR (local_execucao = 'EXTERNO' AND id_laboratorio IS NOT NULL) ),
    CHECK ( (status = 'CONCLUIDO') = (data_conclusao IS NOT NULL) ),
    CHECK ( data_conclusao IS NULL OR data_conclusao >= data_inicio ),
    FOREIGN KEY (id_projeto) REFERENCES projeto (id_projeto)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_amostra) REFERENCES amostra (id_amostra)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_laboratorio) REFERENCES laboratorio_parceiro (id_laboratorio)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_tecnico_exec) REFERENCES funcionario_tecnico (id_funcionario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- LAUDO (1:1 com projeto) e ROTA DE VALORIZAÇÃO
-- ---------------------------------------------------------------------
CREATE TABLE laudo (
    id_laudo          INTEGER PRIMARY KEY,
    id_projeto        INTEGER      NOT NULL UNIQUE,
    numero            VARCHAR(20)  NOT NULL UNIQUE,
    data_emissao      DATE         NOT NULL DEFAULT (date('now')),
    parecer           VARCHAR(10)  NOT NULL CHECK (parecer IN ('APROVADO','REJEITADO')),
    conclusao         TEXT         NOT NULL,
    FOREIGN KEY (id_projeto) REFERENCES projeto (id_projeto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE rota_valorizacao (
    id_rota            INTEGER PRIMARY KEY,
    id_projeto         INTEGER      NOT NULL,
    descricao          TEXT         NOT NULL,
    aplicacao          VARCHAR(60)  NOT NULL,     -- ex.: coprocessamento, agregado, fertilizante
    data_proposta      DATE         NOT NULL DEFAULT (date('now')),
    representante_cliente VARCHAR(100) NOT NULL,  -- definida em conjunto com o cliente
    status             VARCHAR(10)  NOT NULL DEFAULT 'PROPOSTA'
                       CHECK (status IN ('PROPOSTA','ACORDADA','DESCARTADA')),
    FOREIGN KEY (id_projeto) REFERENCES projeto (id_projeto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- EMPRESA PARCEIRA (com os dados da parceria)
-- A parceria foi incorporada à empresa parceira: cada empresa tem uma
-- única parceria, com vigência, percentual de comissão e situação.
-- ---------------------------------------------------------------------
CREATE TABLE empresa_parceira (
    id_empresa            INTEGER PRIMARY KEY,
    razao_social          VARCHAR(120) NOT NULL,
    cnpj                  CHAR(14)     NOT NULL UNIQUE CHECK (length(cnpj) = 14),
    email                 VARCHAR(100) NOT NULL,
    ramo                  VARCHAR(12)  NOT NULL CHECK (ramo IN ('SERVICO','EQUIPAMENTO','AMBOS')),
    data_inicio_parceria  DATE         NOT NULL,
    data_fim_parceria     DATE,
    percentual_comissao   DECIMAL(5,2) NOT NULL CHECK (percentual_comissao > 0 AND percentual_comissao <= 50),
    status_parceria       VARCHAR(8)   NOT NULL DEFAULT 'ATIVA' CHECK (status_parceria IN ('ATIVA','INATIVA')),
    CHECK (data_fim_parceria IS NULL OR data_fim_parceria >= data_inicio_parceria)
);

-- ---------------------------------------------------------------------
-- VENDA e ITEM_VENDA
-- Cada venda tem exatamente UM item (relacionamento 1:1), que é um serviço
-- ou equipamento de UMA empresa parceira (ligação direta item_venda -> empresa_parceira). A comissão é calculada
-- por item, com o percentual da parceria copiado no momento da venda.
-- ---------------------------------------------------------------------
CREATE TABLE venda (
    id_venda             INTEGER PRIMARY KEY,
    id_cliente           INTEGER      NOT NULL,
    id_func_adm          INTEGER      NOT NULL,   -- só administrativos (FK p/ subclasse)
    data_venda           DATE         NOT NULL DEFAULT (date('now')),
    FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_func_adm) REFERENCES funcionario_administrativo (id_funcionario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE item_venda (
    id_item_venda        INTEGER PRIMARY KEY,
    id_venda             INTEGER      NOT NULL UNIQUE,  -- 1:1: cada venda tem um único item
    id_empresa           INTEGER      NOT NULL,   -- empresa parceira que fornece o item
    descricao            VARCHAR(100) NOT NULL,
    tipo                 VARCHAR(12)  NOT NULL CHECK (tipo IN ('SERVICO','EQUIPAMENTO')),
    quantidade           INTEGER      NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    preco_unitario       DECIMAL(12,2) NOT NULL CHECK (preco_unitario > 0),
    percentual_comissao  DECIMAL(5,2) NOT NULL CHECK (percentual_comissao > 0 AND percentual_comissao <= 50),
                                                  -- percentual da parceria no momento da venda
    FOREIGN KEY (id_venda) REFERENCES venda (id_venda)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_empresa) REFERENCES empresa_parceira (id_empresa)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- View de apoio: valor total e comissão de cada venda (somando os itens).
CREATE VIEW vw_venda_resumo AS
SELECT v.id_venda, v.data_venda, c.razao_social AS cliente,
       GROUP_CONCAT(DISTINCT ep.razao_social) AS parceiras,
       SUM(iv.quantidade * iv.preco_unitario) AS valor_total,
       ROUND(SUM(iv.quantidade * iv.preco_unitario * iv.percentual_comissao / 100.0), 2) AS valor_comissao
  FROM venda v
  JOIN cliente c           ON c.id_cliente  = v.id_cliente
  JOIN item_venda iv       ON iv.id_venda   = v.id_venda
  JOIN empresa_parceira ep ON ep.id_empresa = iv.id_empresa
 GROUP BY v.id_venda, v.data_venda, c.razao_social;
