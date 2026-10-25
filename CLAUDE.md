# CLAUDE.md — Chat IA

Guia de desenvolvimento para o Claude Code. Leia antes de qualquer tarefa neste repositório.

## O projeto

Cliente de chat de IA próprio que consome a API **RouteLLM da Abacus.ai** (endpoint compatível com a OpenAI) para acessar vários modelos com uma única assinatura. Além do chat, processa documentos (PDF, Excel, Word), responde perguntas sobre eles (RAG) e gera novos arquivos para download.

É um projeto de portfólio: o código precisa mostrar decisões de nível pleno (processamento assíncrono, streaming, controle de custo, segurança, testes, observabilidade). Prefira soluções simples, explícitas e bem testadas a soluções "espertas".

## Stack

- **Backend:** Ruby on Rails 8 em modo API, Puma, Sidekiq, Redis, PostgreSQL com pgvector
- **Frontend:** React + TypeScript, Vite, TanStack Query, `@rails/actioncable`, `@rails/activestorage`, `react-markdown`
- **Infra:** Docker + Docker Compose, Nginx, Prometheus, Grafana, Sentry, GitHub Actions
- **Testes:** RSpec, FactoryBot, Faker, Shoulda Matchers, Capybara + Cuprite, WebMock, VCR, SimpleCov; Vitest + Testing Library no front
- **Segurança:** Brakeman, Semgrep, bundler-audit, npm audit

## Estrutura do repositório

```
chat-ia/
├── backend/               # Rails API
├── frontend/              # Vite + React + TS
├── nginx/                 # configuração do Nginx (TLS, CSP, proxy)
├── monitoring/            # prometheus.yml, dashboards do Grafana
├── .semgrep/rules.yml     # regras próprias do Semgrep
├── .github/workflows/     # CI/CD
├── compose.yml            # produção
├── compose.dev.yml        # desenvolvimento
└── README.md
```

## Ambiente: tudo roda em Docker

Nunca instale gems, pacotes npm ou serviços diretamente na máquina host. Todo comando roda dentro dos containers.

```bash
# subir o ambiente de desenvolvimento
docker compose -f compose.dev.yml up -d

# comandos Rails
docker compose -f compose.dev.yml exec backend bin/rails console
docker compose -f compose.dev.yml exec backend bin/rails db:migrate
docker compose -f compose.dev.yml exec backend bundle add <gem>

# testes
docker compose -f compose.dev.yml exec backend bundle exec rspec
docker compose -f compose.dev.yml exec frontend npx vitest run

# qualidade e segurança
docker compose -f compose.dev.yml exec backend bundle exec rubocop
docker compose -f compose.dev.yml exec backend bundle exec brakeman --no-pager -q
docker compose -f compose.dev.yml exec frontend npm run lint
semgrep scan --config p/ruby --config p/javascript --config p/typescript --config p/react --config p/owasp-top-ten --config p/secrets --config .semgrep/rules.yml --error
```

Serviços do Compose: `nginx`, `backend` (Puma), `sidekiq`, `frontend` (só em dev, servidor do Vite), `redis`, `prometheus`, `grafana` e `db-test` (só em dev, Postgres com pgvector descartável para testes).

### Imagens

- `backend/Dockerfile`: multi-stage, baseado no Dockerfile de produção gerado pelo Rails 8. Usuário não-root.
- O `sidekiq` usa a **mesma imagem** do backend, só muda o comando (`bundle exec sidekiq`).
- `frontend`: estágio Node para o build do Vite; os arquivos estáticos são copiados para a imagem do Nginx em produção.
- Não coloque segredos em imagens. Tudo vem de variáveis de ambiente (`.env`, nunca commitado; mantenha `.env.example` atualizado).

## Banco de dados: ATENÇÃO

**O banco de dados de desenvolvimento e produção já existe e NÃO roda no Docker Compose.** O app conecta via `DATABASE_URL`.

Regras obrigatórias:

- **Nunca** execute `db:drop`, `db:reset`, `db:schema:load`, `db:setup`, `db:purge` ou `db:truncate_all` apontando para o banco existente.
- **Nunca** rode SQL destrutivo (`DROP`, `TRUNCATE`, `DELETE` sem `WHERE`) fora do banco de teste.
- Antes de rodar uma migration, mostre o que ela faz e peça confirmação.
- Toda migration deve ser reversível (`change` ou `up`/`down`) e passar pelo `strong_migrations`.
- Os testes usam **somente** o `db-test` (em dev) ou o Postgres temporário do CI. Confira que `RAILS_ENV=test` aponta para ele antes de rodar o RSpec.
- Se o container precisar acessar um Postgres que roda no host, use `host.docker.internal` com `extra_hosts: ["host.docker.internal:host-gateway"]`.

Pontos ainda em aberto (pergunte ao desenvolvedor antes de assumir):

- Se o banco existente é um database dedicado a este projeto ou compartilhado com outros sistemas.
- Se a extensão `pgvector` está instalada. Sem ela, a fase de embeddings fica bloqueada; a busca full-text funciona sem ela.

Convenções de banco:

- Valores monetários em `decimal` (ex.: `precision: 12, scale: 6` para custo em dólar), nunca `float`.
- Índices: GIN em `document_chunks.tsv`, HNSW em `document_chunks.embedding`, composto em `messages (conversation_id, created_at)`.
- Chaves estrangeiras com `foreign_key: true` e `null: false` sempre que a regra de negócio permitir.

## Arquitetura

Princípio central: **o Rails só recebe requisições e transmite eventos; todo trabalho pesado roda no Sidekiq.** Nada de chamada à IA, extração de documento ou geração de arquivo dentro de um request.

### Backend

- **Abstração de provider:** a aplicação depende de interfaces, não de fornecedores.
  - `ChatProvider` → adapter `Providers::Abacus` (gem `ruby-openai` com `uri_base` do RouteLLM)
  - `EmbeddingProvider` → adapter `Providers::LocalEmbeddings` (gem `informers`)
  - Controllers, jobs e services nunca instanciam o cliente HTTP diretamente.
- **Service objects** em `app/services/`, com um método público `call` e nome de ação (`BuildConversationContext`, `CalculateMessageCost`, `SummarizeHistory`, `SearchDocumentChunks`, `RenderDocument`).
- **Jobs** em `app/jobs/`: `GenerateReplyJob`, `SummarizeConversationJob`, `ExtractDocumentJob`, `IndexDocumentJob`, `GenerateDocumentJob`, `SyncLlmModelsJob`.
  - Jobs devem ser idempotentes: rodar duas vezes não pode duplicar dados nem custo.
  - `retry_on` com backoff para timeout e 429; `discard_on` para 401. Esgotadas as tentativas, marque o registro como `failed`.
  - Passe IDs para os jobs, nunca objetos inteiros.
- **Action Cable:** `ConversationChannel`, eventos `delta`, `done`, `failed`, `document_ready`. O job envia só o pedaço novo do texto, com throttle de cerca de 100ms.
- **Serialização:** Alba. **Paginação:** Pagy. **Rate limit:** Rack::Attack.
- **Extratores e renderizadores** por formato, escolhidos pelo `content_type` real do arquivo.

### Frontend

- Componentes funcionais com hooks, TypeScript estrito (`strict: true`), sem `any`.
- Dados da API sempre via TanStack Query; nada de `fetch` solto em componente.
- Streaming num hook dedicado (`useConversationStream`) que assina o canal e acumula os deltas.
- Upload direto com `@rails/activestorage`.
- Tipos da API em `frontend/src/api/types.ts`.

## Regras de negócio essenciais

Detalhes completos no documento de especificação do projeto. Resumo do que não pode ser quebrado:

1. Todo recurso pertence a um usuário; sempre escope consultas por `current_user` (`current_user.conversations.find(...)`).
2. O system prompt é **copiado** para a conversa na criação; editar o prompt não altera conversas existentes.
3. O system prompt é enviado inteiro em toda chamada e nunca entra no resumo automático.
4. Contexto enviado à IA: system prompt + resumo (se houver) + últimas N mensagens + trechos de documentos (se houver).
5. Custo = tokens de entrada ÷ 1.000.000 × preço de entrada + tokens de saída ÷ 1.000.000 × preço de saída, com os tokens informados pela API.
6. Mensagens: `pending` → `streaming` → `completed` ou `failed`. Documentos: `uploaded` → `processing` → `ready` ou `failed`.
7. Planilhas não usam busca vetorial: os dados vão para o prompt e os cálculos são feitos em Ruby.
8. Geração de documentos: a IA devolve JSON, validado com `json_schemer`; o arquivo é gerado pelo código Ruby, nunca pela IA.
9. Cada `DocumentChunk` guarda o nome do modelo de embedding; trocar de modelo exige reindexação.

## Segurança

- Respostas da IA e conteúdo de documentos são **entrada não confiável**.
  - Proibido `dangerouslySetInnerHTML` e `rehype-raw`. O `react-markdown` deve continuar sem HTML cru.
- SQL: nunca interpole strings em `where`, `order`, `find_by_sql`, `execute` ou `Arel.sql`. Use placeholders ou hash.
- Uploads: valide tamanho máximo e `content_type` real, não só a extensão.
- Nenhum script inline em HTML; a CSP não permite `unsafe-inline`.
- Nunca commite chaves, tokens ou `.env`. Nos testes, a chave da Abacus é filtrada dos cassettes do VCR.
- `/metrics`, Sidekiq Web, Prometheus e Grafana só com autenticação ou na rede interna.
- Falsos positivos do Brakeman vão para `config/brakeman.ignore` com justificativa. Não desative regras do Semgrep sem justificar no código.

## Testes

- Todo código novo vem com teste. Escreva o teste junto com a implementação.
- **Nenhum teste chama a API real.** Use WebMock ou cassettes do VCR.
- Teste os caminhos de erro das integrações: timeout, 429, 401, JSON inválido da IA.
- Specs de request para os endpoints, specs de job para os jobs, specs de service para a lógica.
- Capybara só para os fluxos principais de ponta a ponta; eles são lentos.
- Use `shoulda-matchers` para validações e associações.
- Antes de considerar uma tarefa concluída, rode: RSpec, RuboCop, Brakeman, Vitest e ESLint. Tudo deve passar.

## Observabilidade

- Erros: Sentry (Rails e Sidekiq). Inclua `conversation_id` e modelo no contexto.
- Métricas: Yabeda. Toda chamada à IA registra no grupo `llm`: `tokens_total` (por modelo e direção), `cost_usd_total`, `requests_total` (por status), `latency_seconds`, `time_to_first_token_seconds`.
- Logs: Lograge em JSON, com `conversation_id` e modelo no payload. Nunca logue conteúdo de mensagens, documentos ou chaves.

## Convenções de código

- Ruby: siga o RuboCop do projeto. Métodos curtos, nomes explícitos, sem metaprogramação desnecessária.
- Evite callbacks de model com efeitos colaterais (chamadas externas, enfileirar jobs); prefira services.
- Evite N+1 (o Bullet acusa em dev).
- TypeScript: nomes em inglês no código; textos da interface em português.
- Commits pequenos, no padrão Conventional Commits (`feat:`, `fix:`, `test:`, `refactor:`, `chore:`, `docs:`).

## Roteiro de desenvolvimento

Siga as fases em ordem. Cada fase termina com testes passando e o pipeline verde.

1. **Setup:** monorepo, Rails API, Docker/Compose, conexão com o banco existente, Redis, Vite + React, autenticação, CI
2. **Chat básico:** conversas e mensagens, `ChatProvider` + adapter da Abacus, `GenerateReplyJob` com retry
3. **Streaming:** `ConversationChannel` e hook no React
4. **Prompts:** cadastro, variáveis `{{variavel}}`, cópia para a conversa, prompt padrão
5. **Modelos e custo:** sincronização via `/v1/models`, custo por mensagem, métricas de IA
6. **Resumo automático** do histórico
7. **Documentos:** upload e extração de PDF, Excel e Word
8. **RAG:** full-text search; depois embeddings com `informers` e busca híbrida
9. **Geração de documentos:** JSON validado → PDF, Excel ou Word, com download

## Como trabalhar neste repositório

- Antes de implementar algo grande, apresente um plano curto e espere aprovação.
- Pergunte em vez de assumir quando a regra de negócio não estiver clara.
- Não adicione gems ou pacotes npm fora da stack acima sem perguntar.
- Não altere `compose.yml`, workflows do CI ou configuração de segurança sem avisar o que muda e por quê.
- Ao terminar uma tarefa, resuma o que mudou e quais comandos foram rodados para verificar.
