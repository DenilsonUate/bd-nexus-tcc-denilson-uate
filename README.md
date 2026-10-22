# Nexus TCC — Base de Dados

**Curso:** Licenciatura em Informática — 2.º ano  
**Disciplina:** Tecnologias de Base de Dados  
**Tema:** Gestão de propostas e acompanhamento de Trabalhos de Conclusão de Curso (TCC)  
**Sistema web previsto:** Nexus TCC — gestão de propostas, documentos, mensagens, reuniões, notificações e acompanhamento das fases do TCC.

> **DENILSON SANSAO UATE**
## 1. Descrição do problema

O acompanhamento de Trabalhos de Conclusão de Curso pode envolver vários intervenientes, como estudantes, docentes orientadores e responsáveis administrativos. Quando as propostas, documentos, mensagens, reuniões e mudanças de fase são registados de forma dispersa, torna-se mais difícil consultar o estado de cada trabalho, recuperar o histórico de decisões e acompanhar os prazos.

O **Nexus TCC** pretende centralizar esse processo num sistema web para a Faculdade de Ciências e Tecnologia da Universidade Licungo. O estudante poderá submeter uma proposta, acompanhar o estado do TCC, consultar documentos e comunicar com o orientador. O docente poderá consultar as propostas sob sua orientação, trocar mensagens, agendar reuniões e registar a evolução do trabalho. O responsável administrativo poderá gerir utilizadores e acompanhar os processos. A base de dados guarda os dados estruturados e relaciona-os por chaves primárias e estrangeiras, evitando referências a registos inexistentes.

Esta entrega corresponde à **base de dados** do projeto, não à integração do HTML com um servidor. O protótipo HTML atual usa armazenamento local do navegador (`localStorage`); para partilhar dados reais entre utilizadores e dispositivos, será necessária uma API/backend ligado ao MySQL. O navegador não deve ligar-se diretamente ao servidor MySQL.

## 2. Regras de negócio

1. Cada utilizador tem um identificador único.
2. O e-mail institucional é obrigatório e não pode repetir-se.
3. Um utilizador assume um dos papéis previstos: `admin`, `responsavel`, `docente` ou `estudante`.
4. O estado da conta pode ser `ativo`, `pendente` ou `inativo`.
5. Cada proposta pertence a um estudante e indica um docente orientador.
6. Uma proposta tem título, resumo, área, estado e fase atual.
7. Os estados da proposta são controlados por valores definidos na tabela.
8. Uma proposta pode possuir vários documentos; cada documento é identificado pelo par `(proposta_id, numero_documento)`. Por depender da proposta para ser identificado, `documento_proposta` é a entidade fraca deste modelo.
9. Cada mensagem pertence a uma proposta e é enviada por um utilizador registado.
10. Cada reunião está associada a uma proposta e aos participantes estudante e docente.
11. Cada notificação tem um destinatário registado.
12. O histórico regista as alterações de fase das propostas, o utilizador que efetuou a alteração e a data.
13. Cada registo filho deve apontar para uma chave existente; as chaves estrangeiras impedem referências órfãs.
14. Os registos de histórico e documentos não devem ser apagados casualmente, porque sustentam a rastreabilidade do TCC.
15. As datas de criação/ocorrência são armazenadas com tipos temporais, e os campos de texto têm limites adequados.
16. As palavras-passe do sistema web real devem ser guardadas como hash seguro no backend. Os dados deste trabalho são fictícios e não incluem credenciais reais.

## 3. Entidades incluídas

- `utilizador`: estudantes, docentes e responsáveis.
- `proposta_tcc`: proposta e estado de cada TCC.
- `documento_proposta`: ficheiros submetidos associados a uma proposta (entidade fraca).
- `mensagem`: comunicação relacionada com uma proposta.
- `reuniao`: encontros de orientação.
- `notificacao`: avisos destinados a utilizadores.
- `historico_fase`: auditoria da progressão de cada proposta.
- `defesa_tcc`: informação de calendário/resultado de defesa ou estado de agendamento.

## 4. Integridade e decisões do modelo

- Todas as tabelas têm chave primária.
- As relações entre tabelas são protegidas por `FOREIGN KEY`.
- O e-mail de utilizador tem restrição `UNIQUE`.
- Os campos de estado, papel e fase usam `ENUM`, limitando valores inválidos.
- A entidade fraca `documento_proposta` usa uma chave primária composta: `(proposta_id, numero_documento)`.
- A tabela `defesa_tcc` tem `proposta_id` único, permitindo no máximo um registo de defesa por proposta.
- `ON DELETE RESTRICT` é usado nas relações que preservam documentos, mensagens, reuniões, histórico e defesas. Notificações podem ser eliminadas em conjunto com o respetivo utilizador.
- Os dados de demonstração são fictícios, criados para testar consultas e relacionamentos.

## 5. Ficheiros

- `diagrama_er.png` — diagrama Entidade-Relacionamento.
- `modelo_relacional.md` — tabelas, atributos, chaves e cardinalidades.
- `01_criacao_e_insercao.sql` — cria a base de dados, tabelas e 20 registos por tabela.
- `02_manipulacao.sql` — consultas, JOIN, UPDATE, DELETE e bloco de teste de integridade comentado.
- `03_teste_integridade.sql` — tentativa isolada de inserir uma chave estrangeira inexistente; espera-se erro de integridade.

## 6. Como executar (MySQL 8.0+)

1. Abra MySQL Workbench, phpMyAdmin ou o cliente MySQL.
2. Execute `01_criacao_e_insercao.sql` desde o início.
3. Execute `02_manipulacao.sql`.
4. Para demonstrar a integridade referencial, execute a instrução de `03_teste_integridade.sql` **separadamente**. Ela deve falhar de propósito; esse erro é a demonstração esperada, não uma falha do script principal.
5. Confirme que cada uma das oito tabelas contém pelo menos 20 registos.

A base de dados usada é `nexus_tcc`. O script de criação remove e recria essa base de dados; faça uma cópia antes de o voltar a executar se tiver dados importantes.

## 7. Sistema web futuro

A interface HTML/CSS/JavaScript poderá ser ligada a esta base de dados por um backend/API (por exemplo, Java com Spring Boot ou PHP). O backend deverá validar permissões por papel, autenticar utilizadores com segurança, validar dados e executar consultas parametrizadas. O HTML atual é um protótipo local; a integração real é uma etapa posterior.

## 8. Preparação da apresentação em vídeo

Sugestão de sequência alinhada ao enunciado:
1. Apresentar o tema e o problema.
2. Explicar regras de negócio e como foram escolhidas as entidades.
3. Mostrar o diagrama ER, cardinalidades, participação e entidade fraca.
4. Executar o script de criação e mostrar as oito tabelas e os respetivos registos.
5. Antes de cada consulta/comando, dizer o resultado esperado; depois executar e comparar.
6. Mostrar o teste de integridade referencial, explicando por que o MySQL rejeita a chave estrangeira inexistente.
7. Concluir com o que foi aprendido e com a ligação prevista ao sistema web.

**Antes de entregar:** validar o nome do estudante, executar os scripts no SGBD usado na aula, capturar resultados reais e acrescentar ao README o link do vídeo e o link do repositório GitHub.
