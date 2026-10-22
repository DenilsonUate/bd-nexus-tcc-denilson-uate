-- Nexus TCC | Etapa 3: consultas e manipulação (MySQL 8.0+)
USE nexus_tcc;

-- SELECT simples 1: propostas em desenvolvimento, por data de submissão.
-- Esperado: listar apenas propostas com estado em_desenvolvimento, da mais antiga para a mais recente.
SELECT id_proposta, titulo, area, estado, data_submissao
FROM proposta_tcc
WHERE estado = 'em_desenvolvimento'
ORDER BY data_submissao ASC;

-- SELECT simples 2: contas de estudantes ativas, por nome.
-- Esperado: mostrar estudantes com conta ativa em ordem alfabética.
SELECT id_utilizador, nome, email, curso
FROM utilizador
WHERE papel = 'estudante' AND estado_conta = 'ativo'
ORDER BY nome ASC;

-- SELECT simples 3: reuniões futuras ou agendadas, da data mais próxima.
-- Esperado: mostrar reuniões com estado agendada e ordenar cronologicamente.
SELECT id_reuniao, proposta_id, data_hora, local_ou_link, estado
FROM reuniao
WHERE estado = 'agendada'
ORDER BY data_hora ASC;

-- JOIN 1: propostas com o nome do estudante e do docente orientador.
-- Esperado: cada linha apresenta a proposta e os dois intervenientes.
SELECT p.id_proposta, p.titulo, e.nome AS estudante, d.nome AS docente, p.estado
FROM proposta_tcc AS p
JOIN utilizador AS e ON e.id_utilizador = p.estudante_id
JOIN utilizador AS d ON d.id_utilizador = p.docente_id
ORDER BY p.id_proposta;

-- JOIN 2: documentos submetidos e título da proposta a que pertencem.
-- Esperado: mostrar cada documento junto do TCC correspondente.
SELECT dp.proposta_id, p.titulo, dp.numero_documento, dp.nome_ficheiro, dp.tipo_ficheiro, dp.data_envio
FROM documento_proposta AS dp
JOIN proposta_tcc AS p ON p.id_proposta = dp.proposta_id
ORDER BY dp.proposta_id, dp.numero_documento;

-- UPDATE 1: atualizar o estado da proposta 5 após uma decisão administrativa.
-- Esperado: proposta 5 passa de pendente para aceite; verificar com SELECT depois do UPDATE.
UPDATE proposta_tcc
SET estado = 'aceite', fase_atual = 'analise', data_atualizacao = '2026-05-01 09:00:00'
WHERE id_proposta = 5;

-- UPDATE 2: marcar a notificação 4 como lida.
-- Esperado: lida passa de FALSE para TRUE.
UPDATE notificacao
SET lida = TRUE
WHERE id_notificacao = 4;

-- Verificação dos UPDATEs.
SELECT id_proposta, titulo, estado, fase_atual FROM proposta_tcc WHERE id_proposta = 5;
SELECT id_notificacao, titulo, lida FROM notificacao WHERE id_notificacao = 4;

-- DELETE 1: apagar uma notificação de demonstração sem registos dependentes.
-- A tabela começa com 21 notificações; ao remover a 21, mantém pelo menos 20 registos.
-- Esperado: a notificação 21 deixa de existir; não quebra relações porque nenhuma tabela aponta para notificacao.
DELETE FROM notificacao
WHERE id_notificacao = 21;

-- Verificação do DELETE.
SELECT id_notificacao, titulo FROM notificacao WHERE id_notificacao = 21;

-- TESTE DE INTEGRIDADE REFERENCIAL (intencionalmente comentado).
-- Para a demonstração, execute separadamente o comando do ficheiro 03_teste_integridade.sql.
-- A instrução tenta usar proposta_id = 9999, que não existe em proposta_tcc, e deve ser rejeitada.
-- INSERT INTO documento_proposta
-- (proposta_id, numero_documento, nome_ficheiro, tipo_ficheiro, caminho_armazenamento, data_envio, descricao)
-- VALUES (9999, 1, 'ficheiro_invalido.pdf', 'pdf', '/uploads/ficheiro_invalido.pdf', NOW(), 'Teste de FK inexistente');
