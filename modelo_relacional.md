# Modelo relacional — Nexus TCC

Notação: **PK** = chave primária; **FK** = chave estrangeira; **UQ** = valor único; `NN` = não nulo.

## 1. UTILIZADOR
`UTILIZADOR(id_utilizador PK, nome, email UQ, telefone, papel, estado_conta, curso, area_supervisao, data_criacao)`

- `id_utilizador`: `INT`, PK, auto incremento.
- `nome`: `VARCHAR(100)`, NN.
- `email`: `VARCHAR(120)`, NN, UQ.
- `telefone`: `VARCHAR(20)`, pode ser nulo.
- `papel`: `ENUM('admin','responsavel','docente','estudante')`, NN.
- `estado_conta`: `ENUM('ativo','pendente','inativo')`, NN.
- `curso`, `area_supervisao`: texto opcional conforme o papel.
- `data_criacao`: `DATETIME`, NN.

## 2. PROPOSTA_TCC
`PROPOSTA_TCC(id_proposta PK, titulo, resumo, area, estado, fase_atual, data_submissao, data_atualizacao, estudante_id FK, docente_id FK)`

- `estudante_id` referencia `UTILIZADOR(id_utilizador)` e deve identificar um estudante.
- `docente_id` referencia `UTILIZADOR(id_utilizador)` e deve identificar o orientador.
- Estados: `pendente`, `aceite`, `recusado`, `em_desenvolvimento`, `defendido`.
- Fases: `proposta`, `analise`, `desenvolvimento`, `revisao`, `defesa`, `concluido`.

## 3. DOCUMENTO_PROPOSTA — entidade fraca
`DOCUMENTO_PROPOSTA(proposta_id PK/FK, numero_documento PK, nome_ficheiro, tipo_ficheiro, caminho_armazenamento, data_envio, descricao)`

- Chave primária composta: `(proposta_id, numero_documento)`.
- `proposta_id` referencia `PROPOSTA_TCC(id_proposta)`.
- O documento não tem identificação completa sem a proposta a que pertence; por isso é modelado como entidade fraca.
- `tipo_ficheiro`: `pdf`, `docx`, `xlsx`, `imagem`, `outro`.

## 4. MENSAGEM
`MENSAGEM(id_mensagem PK, proposta_id FK, remetente_id FK, conteudo, data_envio, lida)`

- `proposta_id` referencia `PROPOSTA_TCC`.
- `remetente_id` referencia `UTILIZADOR`.
- `lida` é um booleano.

## 5. REUNIAO
`REUNIAO(id_reuniao PK, proposta_id FK, estudante_id FK, docente_id FK, data_hora, local_ou_link, notas, estado)`

- As três FKs referenciam proposta/utilizadores.
- Estados: `agendada`, `realizada`, `cancelada`, `adiada`.

## 6. NOTIFICACAO
`NOTIFICACAO(id_notificacao PK, destinatario_id FK, titulo, mensagem, data_criacao, lida)`

- `destinatario_id` referencia `UTILIZADOR(id_utilizador)`.

## 7. HISTORICO_FASE
`HISTORICO_FASE(id_historico PK, proposta_id FK, fase_anterior, fase_nova, alterado_por FK, data_alteracao, observacao)`

- `proposta_id` referencia `PROPOSTA_TCC`.
- `alterado_por` referencia `UTILIZADOR`.
- Guarda a transição e não substitui `fase_atual` na proposta.

## 8. DEFESA_TCC
`DEFESA_TCC(id_defesa PK, proposta_id UQ/FK, data_hora, local, resultado, estado, observacoes)`

- `proposta_id` referencia `PROPOSTA_TCC(id_proposta)` e é único: no máximo uma defesa registada por proposta.
- `resultado`: pode ser nulo até à avaliação; valores permitidos incluem `aprovado`, `aprovado_com_correcoes`, `reprovado`.
- `estado`: `por_agendar`, `agendada`, `realizada`, `cancelada`.

## Relacionamentos, cardinalidade e participação

1. **UTILIZADOR (estudante) — PROPOSTA_TCC:** um estudante pode submeter `0..N` propostas; cada proposta tem exatamente `1` estudante. Participação da proposta: total; do estudante: parcial.
2. **UTILIZADOR (docente) — PROPOSTA_TCC:** um docente pode orientar `0..N` propostas; cada proposta indica exatamente `1` docente. Participação da proposta: total; do docente: parcial.
3. **PROPOSTA_TCC — DOCUMENTO_PROPOSTA:** uma proposta pode ter `0..N` documentos; cada documento pertence exatamente a `1` proposta. Participação do documento: total; da proposta: parcial. Documento é entidade fraca.
4. **PROPOSTA_TCC — MENSAGEM:** uma proposta pode ter `0..N` mensagens; cada mensagem pertence a `1` proposta. Participação da mensagem: total.
5. **UTILIZADOR — MENSAGEM:** um utilizador pode enviar `0..N` mensagens; cada mensagem tem exatamente `1` remetente.
6. **PROPOSTA_TCC — REUNIAO:** uma proposta pode ter `0..N` reuniões; cada reunião refere exatamente `1` proposta.
7. **UTILIZADOR — NOTIFICACAO:** um utilizador pode receber `0..N` notificações; cada notificação tem exatamente `1` destinatário.
8. **PROPOSTA_TCC — HISTORICO_FASE:** uma proposta pode ter `0..N` entradas de histórico; cada entrada pertence exatamente a `1` proposta.
9. **UTILIZADOR — HISTORICO_FASE:** um utilizador pode realizar `0..N` alterações; cada entrada tem exatamente `1` autor.
10. **PROPOSTA_TCC — DEFESA_TCC:** uma proposta pode ter `0..1` defesa registada; cada registo de defesa pertence a exatamente `1` proposta.

> Nota de implementação: as chaves estrangeiras garantem a existência do registo referenciado, mas não conseguem, por si só, garantir que `estudante_id` aponta para um utilizador com papel `estudante` e `docente_id` para um utilizador com papel `docente`. Essa regra deve ser validada pela aplicação ou por triggers/rotinas específicas.
