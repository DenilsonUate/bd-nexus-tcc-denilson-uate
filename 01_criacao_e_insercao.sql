-- Nexus TCC | MySQL 8.0+
-- Script principal: criação de tabelas e dados fictícios (pelo menos 20 registos por tabela).
-- Atenção: DROP DATABASE apaga a base nexus_tcc existente.

DROP DATABASE IF EXISTS nexus_tcc;
CREATE DATABASE nexus_tcc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nexus_tcc;

CREATE TABLE utilizador (
    id_utilizador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    papel ENUM('admin','responsavel','docente','estudante') NOT NULL,
    estado_conta ENUM('ativo','pendente','inativo') NOT NULL DEFAULT 'ativo',
    curso VARCHAR(100),
    area_supervisao VARCHAR(100),
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE proposta_tcc (
    id_proposta INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(180) NOT NULL,
    resumo TEXT NOT NULL,
    area VARCHAR(100) NOT NULL,
    estado ENUM('pendente','aceite','recusado','em_desenvolvimento','defendido') NOT NULL DEFAULT 'pendente',
    fase_atual ENUM('proposta','analise','desenvolvimento','revisao','defesa','concluido') NOT NULL DEFAULT 'proposta',
    data_submissao DATE NOT NULL,
    data_atualizacao DATETIME NOT NULL,
    estudante_id INT NOT NULL,
    docente_id INT NOT NULL,
    CONSTRAINT fk_proposta_estudante FOREIGN KEY (estudante_id)
        REFERENCES utilizador(id_utilizador) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_proposta_docente FOREIGN KEY (docente_id)
        REFERENCES utilizador(id_utilizador) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE documento_proposta (
    proposta_id INT NOT NULL,
    numero_documento SMALLINT NOT NULL,
    nome_ficheiro VARCHAR(180) NOT NULL,
    tipo_ficheiro ENUM('pdf','docx','xlsx','imagem','outro') NOT NULL,
    caminho_armazenamento VARCHAR(255) NOT NULL,
    data_envio DATETIME NOT NULL,
    descricao VARCHAR(255),
    PRIMARY KEY (proposta_id, numero_documento),
    CONSTRAINT fk_documento_proposta FOREIGN KEY (proposta_id)
        REFERENCES proposta_tcc(id_proposta) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE mensagem (
    id_mensagem INT AUTO_INCREMENT PRIMARY KEY,
    proposta_id INT NOT NULL,
    remetente_id INT NOT NULL,
    conteudo TEXT NOT NULL,
    data_envio DATETIME NOT NULL,
    lida BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_mensagem_proposta FOREIGN KEY (proposta_id)
        REFERENCES proposta_tcc(id_proposta) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_mensagem_remetente FOREIGN KEY (remetente_id)
        REFERENCES utilizador(id_utilizador) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE reuniao (
    id_reuniao INT AUTO_INCREMENT PRIMARY KEY,
    proposta_id INT NOT NULL,
    estudante_id INT NOT NULL,
    docente_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    local_ou_link VARCHAR(255),
    notas TEXT,
    estado ENUM('agendada','realizada','cancelada','adiada') NOT NULL DEFAULT 'agendada',
    CONSTRAINT fk_reuniao_proposta FOREIGN KEY (proposta_id)
        REFERENCES proposta_tcc(id_proposta) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reuniao_estudante FOREIGN KEY (estudante_id)
        REFERENCES utilizador(id_utilizador) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reuniao_docente FOREIGN KEY (docente_id)
        REFERENCES utilizador(id_utilizador) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE notificacao (
    id_notificacao INT AUTO_INCREMENT PRIMARY KEY,
    destinatario_id INT NOT NULL,
    titulo VARCHAR(140) NOT NULL,
    mensagem VARCHAR(500) NOT NULL,
    data_criacao DATETIME NOT NULL,
    lida BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_notificacao_destinatario FOREIGN KEY (destinatario_id)
        REFERENCES utilizador(id_utilizador) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE historico_fase (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    proposta_id INT NOT NULL,
    fase_anterior ENUM('proposta','analise','desenvolvimento','revisao','defesa','concluido'),
    fase_nova ENUM('proposta','analise','desenvolvimento','revisao','defesa','concluido') NOT NULL,
    alterado_por INT NOT NULL,
    data_alteracao DATETIME NOT NULL,
    observacao VARCHAR(500),
    CONSTRAINT fk_historico_proposta FOREIGN KEY (proposta_id)
        REFERENCES proposta_tcc(id_proposta) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_historico_utilizador FOREIGN KEY (alterado_por)
        REFERENCES utilizador(id_utilizador) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE defesa_tcc (
    id_defesa INT AUTO_INCREMENT PRIMARY KEY,
    proposta_id INT NOT NULL UNIQUE,
    data_hora DATETIME,
    local VARCHAR(180),
    resultado ENUM('aprovado','aprovado_com_correcoes','reprovado'),
    estado ENUM('por_agendar','agendada','realizada','cancelada') NOT NULL DEFAULT 'por_agendar',
    observacoes VARCHAR(500),
    CONSTRAINT fk_defesa_proposta FOREIGN KEY (proposta_id)
        REFERENCES proposta_tcc(id_proposta) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 20 utilizadores fictícios: IDs 1-3 administração/responsáveis, 4-9 docentes, 10-20 estudantes.
INSERT INTO utilizador
(id_utilizador,nome,email,telefone,papel,estado_conta,curso,area_supervisao,data_criacao) VALUES
(1,'Amélia Macuácua','amelia.macuacua@unilicungo.ac.mz','258840000001','admin','ativo',NULL,NULL,'2026-01-05 08:00:00'),
(2,'Tomás Nhantumbo','tomas.nhantumbo@unilicungo.ac.mz','258840000002','responsavel','ativo',NULL,NULL,'2026-01-06 08:00:00'),
(3,'Celina Mussa','celina.mussa@unilicungo.ac.mz','258840000003','responsavel','ativo',NULL,NULL,'2026-01-07 08:00:00'),
(4,'Ernesto Cossa','ernesto.cossa@unilicungo.ac.mz','258840000004','docente','ativo',NULL,'Engenharia de Software','2026-01-08 08:00:00'),
(5,'Lídia Sitoe','lidia.sitoe@unilicungo.ac.mz','258840000005','docente','ativo',NULL,'Bases de Dados','2026-01-09 08:00:00'),
(6,'Mateus Bila','mateus.bila@unilicungo.ac.mz','258840000006','docente','ativo',NULL,'Redes e Sistemas','2026-01-10 08:00:00'),
(7,'Rosa Mucavele','rosa.mucavele@unilicungo.ac.mz','258840000007','docente','ativo',NULL,'Sistemas de Informação','2026-01-11 08:00:00'),
(8,'Paulo Chongo','paulo.chongo@unilicungo.ac.mz','258840000008','docente','ativo',NULL,'Inteligência Artificial','2026-01-12 08:00:00'),
(9,'Sara Macamo','sara.macamo@unilicungo.ac.mz','258840000009','docente','ativo',NULL,'Segurança Informática','2026-01-13 08:00:00'),
(10,'Alberto Alface','alberto.alface@unilicungo.ac.mz','258840000010','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-01 09:00:00'),
(11,'Marta Jamal','marta.jamal@unilicungo.ac.mz','258840000011','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-02 09:00:00'),
(12,'Carlos Mucavele','carlos.mucavele@unilicungo.ac.mz','258840000012','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-03 09:00:00'),
(13,'Ivone Bila','ivone.bila@unilicungo.ac.mz','258840000013','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-04 09:00:00'),
(14,'Nelson Matusse','nelson.matusse@unilicungo.ac.mz','258840000014','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-05 09:00:00'),
(15,'Helena Cossa','helena.cossa@unilicungo.ac.mz','258840000015','estudante','pendente','Licenciatura em Informática',NULL,'2026-02-06 09:00:00'),
(16,'Dário Sitoe','dario.sitoe@unilicungo.ac.mz','258840000016','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-07 09:00:00'),
(17,'Filomena Nhantumbo','filomena.nhantumbo@unilicungo.ac.mz','258840000017','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-08 09:00:00'),
(18,'Júlio Macuácua','julio.macuacua@unilicungo.ac.mz','258840000018','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-09 09:00:00'),
(19,'Berta Mussa','berta.mussa@unilicungo.ac.mz','258840000019','estudante','inativo','Licenciatura em Informática',NULL,'2026-02-10 09:00:00'),
(20,'Samuel Chongo','samuel.chongo@unilicungo.ac.mz','258840000020','estudante','ativo','Licenciatura em Informática',NULL,'2026-02-11 09:00:00');

INSERT INTO proposta_tcc
(id_proposta,titulo,resumo,area,estado,fase_atual,data_submissao,data_atualizacao,estudante_id,docente_id) VALUES
(1,'Gestão digital de clínicas comunitárias','Sistema para organizar marcações e histórico administrativo de consultas.','Sistemas de Informação','em_desenvolvimento','desenvolvimento','2026-03-01','2026-04-01 10:00:00',10,7),
(2,'Monitoria de consumo de água','Aplicação para registo e análise de consumo doméstico.','Engenharia de Software','aceite','revisao','2026-03-02','2026-04-02 10:00:00',11,4),
(3,'Plataforma de apoio a pequenos agricultores','Portal para aproximar produtores e compradores agrícolas.','Sistemas de Informação','em_desenvolvimento','desenvolvimento','2026-03-03','2026-04-03 10:00:00',12,7),
(4,'Deteção de mensagens fraudulentas','Classificação de mensagens suspeitas para educação digital.','Inteligência Artificial','aceite','analise','2026-03-04','2026-04-04 10:00:00',13,8),
(5,'Gestão de oficinas automóveis','Registo de clientes, viaturas, serviços e manutenção.','Bases de Dados','pendente','proposta','2026-03-05','2026-04-05 10:00:00',14,5),
(6,'Agenda de transporte escolar','Gestão de rotas, horários e contactos de encarregados.','Sistemas de Informação','em_desenvolvimento','desenvolvimento','2026-03-06','2026-04-06 10:00:00',15,7),
(7,'Inventário de equipamentos informáticos','Controlo de equipamentos, empréstimos e manutenção.','Bases de Dados','aceite','revisao','2026-03-07','2026-04-07 10:00:00',16,5),
(8,'Portal de estágios profissionais','Registo de oportunidades e candidaturas de estudantes.','Engenharia de Software','em_desenvolvimento','desenvolvimento','2026-03-08','2026-04-08 10:00:00',17,4),
(9,'Gestão de resíduos sólidos urbanos','Planeamento de recolha e registo de pontos críticos.','Sistemas de Informação','aceite','analise','2026-03-09','2026-04-09 10:00:00',18,7),
(10,'Arquivo digital de documentos','Organização e pesquisa de documentos institucionais.','Segurança Informática','recusado','proposta','2026-03-10','2026-04-10 10:00:00',19,9),
(11,'Aplicação de literacia financeira','Conteúdos e exercícios de educação financeira.','Engenharia de Software','em_desenvolvimento','desenvolvimento','2026-03-11','2026-04-11 10:00:00',20,4),
(12,'Monitoria de energia solar','Registo de produção e consumo em pequenos sistemas solares.','Redes e Sistemas','aceite','revisao','2026-03-12','2026-04-12 10:00:00',10,6),
(13,'Sistema de marcação de campos desportivos','Reservas e calendário de utilização de espaços desportivos.','Sistemas de Informação','pendente','proposta','2026-03-13','2026-04-13 10:00:00',11,7),
(14,'Gestão de medicamentos em farmácias','Controlo de lotes, validade e níveis de stock.','Bases de Dados','em_desenvolvimento','desenvolvimento','2026-03-14','2026-04-14 10:00:00',12,5),
(15,'Mapa de acessibilidade urbana','Registo colaborativo de barreiras de acessibilidade.','Engenharia de Software','aceite','analise','2026-03-15','2026-04-15 10:00:00',13,4),
(16,'Monitoria de segurança de redes','Painel para registo de incidentes e medidas preventivas.','Segurança Informática','em_desenvolvimento','revisao','2026-03-16','2026-04-16 10:00:00',14,9),
(17,'Sistema de apoio a bibliotecas escolares','Gestão de empréstimos para escolas comunitárias.','Bases de Dados','defendido','concluido','2026-03-17','2026-04-17 10:00:00',16,5),
(18,'Assistente de estudo de programação','Plano de aprendizagem e acompanhamento de exercícios.','Inteligência Artificial','defendido','concluido','2026-03-18','2026-04-18 10:00:00',17,8),
(19,'Gestão de reservas de alojamento local','Calendário de disponibilidade e registo de reservas.','Engenharia de Software','defendido','concluido','2026-03-19','2026-04-19 10:00:00',18,4),
(20,'Painel de dados meteorológicos agrícolas','Consulta de dados meteorológicos para planeamento agrícola.','Redes e Sistemas','defendido','concluido','2026-03-20','2026-04-20 10:00:00',20,6);

INSERT INTO documento_proposta
(proposta_id,numero_documento,nome_ficheiro,tipo_ficheiro,caminho_armazenamento,data_envio,descricao) VALUES
(1,1,'proposta_clinicas.pdf','pdf','/uploads/propostas/1/proposta_clinicas.pdf','2026-03-01 11:00:00','Proposta inicial'),
(2,1,'consumo_agua.docx','docx','/uploads/propostas/2/consumo_agua.docx','2026-03-02 11:00:00','Documento de proposta'),
(3,1,'machamba_digital.pdf','pdf','/uploads/propostas/3/machamba_digital.pdf','2026-03-03 11:00:00','Proposta inicial'),
(4,1,'mensagens_fraudulentas.pdf','pdf','/uploads/propostas/4/mensagens_fraudulentas.pdf','2026-03-04 11:00:00','Proposta inicial'),
(5,1,'oficinas_automoveis.docx','docx','/uploads/propostas/5/oficinas_automoveis.docx','2026-03-05 11:00:00','Proposta submetida'),
(6,1,'transporte_escolar.pdf','pdf','/uploads/propostas/6/transporte_escolar.pdf','2026-03-06 11:00:00','Proposta inicial'),
(7,1,'inventario_ti.xlsx','xlsx','/uploads/propostas/7/inventario_ti.xlsx','2026-03-07 11:00:00','Lista de requisitos'),
(8,1,'portal_estagios.pdf','pdf','/uploads/propostas/8/portal_estagios.pdf','2026-03-08 11:00:00','Proposta inicial'),
(9,1,'residuos_urbanos.pdf','pdf','/uploads/propostas/9/residuos_urbanos.pdf','2026-03-09 11:00:00','Proposta inicial'),
(10,1,'arquivo_digital.pdf','pdf','/uploads/propostas/10/arquivo_digital.pdf','2026-03-10 11:00:00','Proposta submetida'),
(11,1,'literacia_financeira.docx','docx','/uploads/propostas/11/literacia_financeira.docx','2026-03-11 11:00:00','Proposta inicial'),
(12,1,'energia_solar.pdf','pdf','/uploads/propostas/12/energia_solar.pdf','2026-03-12 11:00:00','Proposta inicial'),
(13,1,'campos_desportivos.pdf','pdf','/uploads/propostas/13/campos_desportivos.pdf','2026-03-13 11:00:00','Proposta inicial'),
(14,1,'medicamentos_farmacia.pdf','pdf','/uploads/propostas/14/medicamentos_farmacia.pdf','2026-03-14 11:00:00','Proposta inicial'),
(15,1,'acessibilidade_urbana.pdf','pdf','/uploads/propostas/15/acessibilidade_urbana.pdf','2026-03-15 11:00:00','Proposta inicial'),
(16,1,'seguranca_redes.pdf','pdf','/uploads/propostas/16/seguranca_redes.pdf','2026-03-16 11:00:00','Proposta inicial'),
(17,1,'bibliotecas_escolares.pdf','pdf','/uploads/propostas/17/bibliotecas_escolares.pdf','2026-03-17 11:00:00','Versão final'),
(18,1,'assistente_programacao.pdf','pdf','/uploads/propostas/18/assistente_programacao.pdf','2026-03-18 11:00:00','Versão final'),
(19,1,'alojamento_local.pdf','pdf','/uploads/propostas/19/alojamento_local.pdf','2026-03-19 11:00:00','Versão final'),
(20,1,'dados_meteorologicos.pdf','pdf','/uploads/propostas/20/dados_meteorologicos.pdf','2026-03-20 11:00:00','Versão final');

INSERT INTO mensagem (id_mensagem,proposta_id,remetente_id,conteudo,data_envio,lida) VALUES
(1,1,10,'Submeti a proposta para apreciação.','2026-03-02 08:30:00',TRUE),
(2,2,4,'A estrutura está boa; reveja os objetivos específicos.','2026-03-03 09:15:00',TRUE),
(3,3,12,'Posso incluir filtros por distrito e tipo de produto?','2026-03-04 10:20:00',TRUE),
(4,4,8,'Envie também exemplos de mensagens para os testes.','2026-03-05 11:00:00',FALSE),
(5,5,14,'A proposta está pendente de análise.','2026-03-06 12:10:00',FALSE),
(6,6,7,'Vamos rever os requisitos na próxima reunião.','2026-03-07 13:00:00',TRUE),
(7,7,16,'Anexei uma lista inicial de equipamentos.','2026-03-08 14:25:00',TRUE),
(8,8,4,'Adicione os critérios de seleção de candidatos.','2026-03-09 15:30:00',TRUE),
(9,9,18,'O mapa terá pontos de recolha por bairro.','2026-03-10 08:45:00',FALSE),
(10,10,19,'Gostaria de clarificar o âmbito do arquivo.','2026-03-11 09:40:00',TRUE),
(11,11,20,'Preparei exercícios para três níveis de dificuldade.','2026-03-12 10:35:00',TRUE),
(12,12,6,'Inclua unidade de medida e intervalo de recolha.','2026-03-13 11:20:00',TRUE),
(13,13,11,'Como devo representar reservas recorrentes?','2026-03-14 12:00:00',FALSE),
(14,14,5,'Inclua alertas para medicamentos perto da validade.','2026-03-15 13:15:00',TRUE),
(15,15,13,'A aplicação permitirá anexar fotografias das barreiras.','2026-03-16 14:10:00',TRUE),
(16,16,9,'Registe data, severidade e estado de cada incidente.','2026-03-17 15:05:00',FALSE),
(17,17,16,'A versão final foi entregue para avaliação.','2026-03-18 08:25:00',TRUE),
(18,18,8,'Concluí os testes do módulo de exercícios.','2026-03-19 09:10:00',TRUE),
(19,19,18,'A defesa foi realizada e o resultado registado.','2026-03-20 10:00:00',TRUE),
(20,20,20,'Partilho a documentação final do painel.','2026-03-21 10:45:00',TRUE);

INSERT INTO reuniao (id_reuniao,proposta_id,estudante_id,docente_id,data_hora,local_ou_link,notas,estado) VALUES
(1,1,10,7,'2026-04-02 09:00:00','Sala FCT 2','Definir módulos iniciais.','realizada'),
(2,2,11,4,'2026-04-03 10:00:00','https://meet.example.org/tcc2','Rever objetivos.','realizada'),
(3,3,12,7,'2026-04-04 11:00:00','Sala FCT 1','Analisar categorias de produtos.','realizada'),
(4,4,13,8,'2026-04-05 09:30:00','https://meet.example.org/tcc4','Escolher métricas de classificação.','realizada'),
(5,5,14,5,'2026-04-06 14:00:00','Gabinete 5','Clarificar entidades.','agendada'),
(6,6,15,7,'2026-04-07 10:30:00','Sala FCT 3','Rever rotas e horários.','adiada'),
(7,7,16,5,'2026-04-08 11:30:00','Gabinete 5','Validar inventário.','realizada'),
(8,8,17,4,'2026-04-09 08:30:00','https://meet.example.org/tcc8','Rever formulário de candidatura.','realizada'),
(9,9,18,7,'2026-04-10 09:00:00','Sala FCT 1','Definir atributos geográficos.','agendada'),
(10,10,19,9,'2026-04-11 15:00:00','Gabinete 9','Reformular o âmbito.','cancelada'),
(11,11,20,4,'2026-04-12 10:00:00','https://meet.example.org/tcc11','Testar exercícios.','realizada'),
(12,12,10,6,'2026-04-13 11:00:00','Sala FCT 4','Definir sensores.','realizada'),
(13,13,11,7,'2026-04-14 12:00:00','Sala FCT 1','Desenhar calendário.','agendada'),
(14,14,12,5,'2026-04-15 13:00:00','Gabinete 5','Validar alertas.','realizada'),
(15,15,13,4,'2026-04-16 14:00:00','https://meet.example.org/tcc15','Rever mapa e acessibilidade.','realizada'),
(16,16,14,9,'2026-04-17 15:00:00','Gabinete 9','Rever modelo de incidentes.','agendada'),
(17,17,16,5,'2026-04-18 09:00:00','Auditório FCT','Preparação de defesa.','realizada'),
(18,18,17,8,'2026-04-19 10:00:00','Auditório FCT','Preparação de defesa.','realizada'),
(19,19,18,4,'2026-04-20 11:00:00','Auditório FCT','Sessão final.','realizada'),
(20,20,20,6,'2026-04-21 12:00:00','Auditório FCT','Sessão final.','realizada');

INSERT INTO notificacao (id_notificacao,destinatario_id,titulo,mensagem,data_criacao,lida) VALUES
(1,10,'Proposta submetida','A sua proposta foi registada.','2026-03-02 08:00:00',TRUE),
(2,11,'Comentário do orientador','Há novos comentários na sua proposta.','2026-03-03 08:00:00',TRUE),
(3,12,'Reunião realizada','A reunião foi marcada como realizada.','2026-03-04 08:00:00',TRUE),
(4,13,'Documento recebido','O ficheiro foi anexado à proposta.','2026-03-05 08:00:00',FALSE),
(5,14,'Análise pendente','A proposta aguarda apreciação.','2026-03-06 08:00:00',FALSE),
(6,15,'Reunião adiada','A reunião foi adiada pelo orientador.','2026-03-07 08:00:00',TRUE),
(7,16,'Nova versão','Foi registada uma atualização do documento.','2026-03-08 08:00:00',TRUE),
(8,17,'Prazo de revisão','Consulte as recomendações do orientador.','2026-03-09 08:00:00',TRUE),
(9,18,'Reunião agendada','Foi criada uma reunião de orientação.','2026-03-10 08:00:00',FALSE),
(10,19,'Proposta recusada','Consulte as observações associadas.','2026-03-11 08:00:00',TRUE),
(11,20,'Mensagem recebida','Tem uma nova mensagem.','2026-03-12 08:00:00',TRUE),
(12,10,'Fase atualizada','A fase do seu TCC foi alterada.','2026-03-13 08:00:00',TRUE),
(13,11,'Defesa por agendar','Prepare a documentação necessária.','2026-03-14 08:00:00',FALSE),
(14,12,'Documento validado','O documento foi recebido com sucesso.','2026-03-15 08:00:00',TRUE),
(15,13,'Reunião confirmada','A reunião está confirmada.','2026-03-16 08:00:00',TRUE),
(16,14,'Revisão de segurança','Consulte as observações do orientador.','2026-03-17 08:00:00',FALSE),
(17,16,'Defesa realizada','O resultado da defesa foi registado.','2026-03-18 08:00:00',TRUE),
(18,17,'Defesa realizada','O resultado da defesa foi registado.','2026-03-19 08:00:00',TRUE),
(19,18,'TCC concluído','O processo foi marcado como concluído.','2026-03-20 08:00:00',TRUE),
(20,20,'TCC concluído','O processo foi marcado como concluído.','2026-03-21 08:00:00',TRUE),
(21,2,'Lembrete administrativo','Reveja as propostas pendentes de validação.','2026-03-22 08:00:00',FALSE);

INSERT INTO historico_fase (id_historico,proposta_id,fase_anterior,fase_nova,alterado_por,data_alteracao,observacao) VALUES
(1,1,'proposta','desenvolvimento',7,'2026-04-01 10:00:00','Início do desenvolvimento.'),
(2,2,'desenvolvimento','revisao',4,'2026-04-02 10:00:00','Versão enviada para revisão.'),
(3,3,'analise','desenvolvimento',7,'2026-04-03 10:00:00','Proposta aceite.'),
(4,4,'proposta','analise',8,'2026-04-04 10:00:00','Análise iniciada.'),
(5,5,NULL,'proposta',2,'2026-04-05 10:00:00','Registo inicial da proposta.'),
(6,6,'analise','desenvolvimento',7,'2026-04-06 10:00:00','Proposta aceite.'),
(7,7,'desenvolvimento','revisao',5,'2026-04-07 10:00:00','Documento revisto.'),
(8,8,'analise','desenvolvimento',4,'2026-04-08 10:00:00','Proposta aceite.'),
(9,9,'proposta','analise',2,'2026-04-09 10:00:00','Aguardando validação.'),
(10,10,NULL,'proposta',2,'2026-04-10 10:00:00','Registo inicial da proposta.'),
(11,11,'analise','desenvolvimento',4,'2026-04-11 10:00:00','Proposta aceite.'),
(12,12,'desenvolvimento','revisao',6,'2026-04-12 10:00:00','Resultados preliminares.'),
(13,13,NULL,'proposta',2,'2026-04-13 10:00:00','Registo inicial da proposta.'),
(14,14,'analise','desenvolvimento',5,'2026-04-14 10:00:00','Proposta aceite.'),
(15,15,'proposta','analise',4,'2026-04-15 10:00:00','Análise iniciada.'),
(16,16,'desenvolvimento','revisao',9,'2026-04-16 10:00:00','Revisão de segurança.'),
(17,17,'defesa','concluido',5,'2026-04-17 10:00:00','TCC concluído.'),
(18,18,'defesa','concluido',8,'2026-04-18 10:00:00','TCC concluído.'),
(19,19,'defesa','concluido',4,'2026-04-19 10:00:00','TCC concluído.'),
(20,20,'defesa','concluido',6,'2026-04-20 10:00:00','TCC concluído.');

INSERT INTO defesa_tcc (id_defesa,proposta_id,data_hora,local,resultado,estado,observacoes) VALUES
(1,1,'2026-11-15 09:00:00','Auditório FCT',NULL,'agendada','Previsão de defesa; confirmar requisitos.'),
(2,2,'2026-11-16 09:00:00','Sala de Conferências',NULL,'agendada','Agendamento provisório.'),
(3,3,'2026-11-17 10:00:00','Auditório FCT',NULL,'por_agendar','A aguardar conclusão do desenvolvimento.'),
(4,4,'2026-11-18 10:00:00','Sala de Conferências',NULL,'por_agendar','A aguardar validação da proposta.'),
(5,5,NULL,NULL,NULL,'por_agendar','Ainda não agendada.'),
(6,6,'2026-11-20 09:00:00','Auditório FCT',NULL,'agendada','Agendamento provisório.'),
(7,7,'2026-11-21 10:00:00','Sala de Conferências',NULL,'agendada','A aguardar revisão final.'),
(8,8,'2026-11-22 09:00:00','Auditório FCT',NULL,'por_agendar','A aguardar conclusão.'),
(9,9,'2026-11-23 09:00:00','Sala de Conferências',NULL,'por_agendar','A aguardar validação.'),
(10,10,NULL,NULL,NULL,'cancelada','Proposta recusada; registo mantido para demonstração.'),
(11,11,'2026-11-25 10:00:00','Auditório FCT',NULL,'por_agendar','A aguardar conclusão.'),
(12,12,'2026-11-26 09:00:00','Sala de Conferências',NULL,'agendada','Agendamento provisório.'),
(13,13,NULL,NULL,NULL,'por_agendar','Ainda não agendada.'),
(14,14,'2026-11-28 09:00:00','Auditório FCT',NULL,'por_agendar','A aguardar conclusão.'),
(15,15,'2026-11-29 10:00:00','Sala de Conferências',NULL,'agendada','Agendamento provisório.'),
(16,16,'2026-11-30 09:00:00','Auditório FCT',NULL,'agendada','Agendamento provisório.'),
(17,17,'2026-04-25 09:00:00','Auditório FCT','aprovado','realizada','Defesa concluída com aprovação.'),
(18,18,'2026-04-26 09:00:00','Auditório FCT','aprovado_com_correcoes','realizada','Aprovado com correções menores.'),
(19,19,'2026-04-27 10:00:00','Sala de Conferências','aprovado','realizada','Defesa concluída com aprovação.'),
(20,20,'2026-04-28 10:00:00','Auditório FCT','aprovado','realizada','Defesa concluída com aprovação.');

-- Verificação opcional de contagem: todas as tabelas devem ter pelo menos 20 linhas.
SELECT 'utilizador' AS tabela, COUNT(*) AS total FROM utilizador
UNION ALL SELECT 'proposta_tcc', COUNT(*) FROM proposta_tcc
UNION ALL SELECT 'documento_proposta', COUNT(*) FROM documento_proposta
UNION ALL SELECT 'mensagem', COUNT(*) FROM mensagem
UNION ALL SELECT 'reuniao', COUNT(*) FROM reuniao
UNION ALL SELECT 'notificacao', COUNT(*) FROM notificacao
UNION ALL SELECT 'historico_fase', COUNT(*) FROM historico_fase
UNION ALL SELECT 'defesa_tcc', COUNT(*) FROM defesa_tcc;
