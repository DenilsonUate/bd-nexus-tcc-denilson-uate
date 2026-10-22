-- Nexus TCC | Teste de integridade referencial (MySQL 8.0+)
-- Execute este ficheiro APÓS 01_criacao_e_insercao.sql, separadamente.
-- Resultado esperado: erro 1452 (Cannot add or update a child row: a foreign key constraint fails).
-- A proposta 9999 não existe, logo o documento não pode referenciá-la.
USE nexus_tcc;

INSERT INTO documento_proposta
(proposta_id, numero_documento, nome_ficheiro, tipo_ficheiro, caminho_armazenamento, data_envio, descricao)
VALUES
(9999, 1, 'ficheiro_invalido.pdf', 'pdf', '/uploads/ficheiro_invalido.pdf', NOW(), 'Teste de FK inexistente');
