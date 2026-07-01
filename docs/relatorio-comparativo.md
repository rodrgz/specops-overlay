# Relatorio comparativo: `code-modernization` vs. `tlc-spec-driven`

Data da analise: 2026-07-01

## Resumo executivo

Os dois repositorios nao competem diretamente. Eles resolvem problemas
relacionados, mas em camadas diferentes.

`code-modernization` e um plugin especializado em modernizacao de sistemas
legados. Ele cobre descoberta, mapeamento arquitetural, extracao de regras de
negocio, briefing executivo, transformacao, uplift de versao, reimaginacao e
hardening de seguranca. E mais adequado para programas de modernizacao de
sistemas grandes, especialmente quando ha codigo legado, risco operacional,
necessidade de artefatos para stakeholders e preocupacao com segredos.

`tlc-spec-driven` e uma skill generica de desenvolvimento orientado por
especificacao. Ela cobre planejamento e implementacao de features com fases
adaptativas, rastreabilidade de requisitos, testes derivados da spec, commits
atomicos, validacao independente e uma camada de licoes aprendidas. E mais
adequada para construir features com alto rigor de qualidade em qualquer stack.

Conclusao principal: `code-modernization` e melhor como esteira de
modernizacao legado-para-moderno; `tlc-spec-driven` e melhor como metodo de
execucao e validacao de features. O uso combinado e forte: usar
`code-modernization` para descobrir regras, arquitetura e riscos de um legado,
e usar `tlc-spec-driven` para implementar fases aprovadas com gates de testes,
commits atomicos e verificacao independente.

## Escopo e metodologia

Esta comparacao foi feita por leitura estatica dos arquivos no workspace:

- `code-modernization/`
- `tlc-spec-driven/`

Foram analisados README, comandos, agentes, workflows, referencias de processo,
script Python, licencas declaradas e estrutura de arquivos. Nao foi feita uma
execucao real dos workflows JavaScript porque eles dependem de um runtime
externo com globais como `args`, `agent`, `parallel`, `pipeline`, `budget` e
`log`. O script Python de `tlc-spec-driven` foi checado com `--help` e respondeu
corretamente.

Nao foram encontrados manifests tradicionais de build ou teste, como
`package.json`, `pyproject.toml`, `Makefile`, CI ou suites automatizadas dos
proprios repositorios.

## Inventario objetivo

| Item | `code-modernization` | `tlc-spec-driven` |
| --- | --- | --- |
| Natureza | Plugin de modernizacao de codigo legado | Skill de spec-driven development |
| Arquivo principal | `README.md` | `SKILL.md` |
| Arquivos listados | 26 | 14 |
| Linhas analisadas | 3.604, sem contar `LICENSE` e imagem | 2.858 |
| Markdown | 18 arquivos | 13 arquivos |
| Codigo executavel/orquestrador | 5 workflows JavaScript | 1 script Python |
| Assets | HTML interativo e screenshot | Nenhum asset visual |
| Licenca | `LICENSE` Apache 2.0 | `license: CC-BY-4.0` no frontmatter |
| Testes do repositorio | Nao encontrados | Nao encontrados |
| Manifest de pacote | Nao encontrado | Nao encontrado |
| CI | Nao encontrado | Nao encontrado |

Distribuicao aproximada por linhas:

| Categoria | `code-modernization` | `tlc-spec-driven` |
| --- | ---: | ---: |
| README / skill principal | 122 | 164 |
| Comandos / referencias de processo | 1.425 em comandos | 2.324 em referencias |
| Agentes | 531 | Nao separado em agentes proprios |
| Workflows / scripts | 1.008 em JS | 370 em Python |
| HTML / asset tecnico | 518 | 0 |

## Proposito e modelo mental

### `code-modernization`

O repositorio assume que o usuario tem um sistema legado em `legacy/<system>`
e quer produzir artefatos em `analysis/<system>` e `modernized/<system>`.

O fluxo central declarado no README e:

```text
preflight -> assess -> map -> extract-rules -> brief -> (reimagine | transform | uplift) -> harden
```

Esse modelo e sequencial e deliberado. A tese do projeto e que modernizacao
falha quando times pulam descoberta, transformam codigo antes de entender
regras de negocio ou entregam sem harness de equivalencia.

### `tlc-spec-driven`

O repositorio assume que o usuario quer planejar e implementar uma feature com
rigor proporcional ao tamanho da mudanca. O fluxo central e:

```text
Specify -> Design -> Tasks -> Execute
```

`Specify` e `Execute` sempre existem. `Design` e `Tasks` podem ser pulados para
mudancas pequenas. A tese do projeto e que qualidade vem de requisitos claros,
testes derivados da especificacao, gates obrigatorios e verificacao
independente.

## Estrutura e organizacao

### `code-modernization`

Estrutura principal:

```text
code-modernization/
  README.md
  LICENSE
  commands/
  agents/
  workflows/
  assets/
```

Pontos fortes:

- A separacao entre `commands/`, `agents/`, `workflows/` e `assets/` deixa
  clara a arquitetura operacional.
- Cada comando tem um objetivo distinto e produz artefatos especificos.
- Os agentes tem papeis especializados e prompts bem delimitados.
- Os workflows JavaScript adicionam orquestracao estruturada acima dos prompts.
- O viewer de topologia em `assets/topology-viewer.html` da suporte a um
  artefato visual, o que e importante em modernizacao.

Pontos fracos:

- O repositorio se apresenta como plugin, mas a copia analisada nao contem um
  manifest visivel de plugin.
- Os workflows JavaScript nao sao programas standalone. Eles dependem de um
  ambiente de workflow especifico.
- Nao ha testes automatizados para validar schemas, prompts, renderizacao de
  artefatos ou consistencia entre README e comandos.

### `tlc-spec-driven`

Estrutura principal:

```text
tlc-spec-driven/
  SKILL.md
  references/
  scripts/lessons.py
```

Pontos fortes:

- `SKILL.md` funciona como contrato principal e roteia para referencias
  especializadas.
- As referencias sao separadas por fase: specify, discuss, design, tasks,
  implement, validate, memory, lessons e code-analysis.
- A estrutura `.specs/` e bem definida e cria persistencia entre sessoes.
- `scripts/lessons.py` transforma uma parte do processo em bookkeeping
  deterministico.

Pontos fracos:

- Nao ha um README convencional explicando instalacao, exemplos e integracao.
- A licenca aparece no frontmatter, mas nao ha arquivo `LICENSE` separado.
- A maior parte das garantias depende de cumprimento pelo agente, nao de
  automacao executavel.
- Nao ha testes do script `lessons.py`, apesar de ele ser a parte mais
  concreta do repositorio.

## Comparacao de capacidades

| Capacidade | `code-modernization` | `tlc-spec-driven` |
| --- | --- | --- |
| Descoberta de legado | Muito forte | Fora do escopo principal |
| Analise de portfolio | Forte, com workflow dedicado | Nao cobre |
| Mapa arquitetural/topologia | Forte, com JSON, Mermaid e HTML | So usa diagramas no design |
| Extracao de regras de negocio | Forte, com referees e painel P0 | Especifica requisitos novos, nao minera legado |
| Briefing executivo | Forte | Nao e foco |
| Transformacao de modulo legado | Forte, com caracterizacao e equivalencia | Poderia executar tarefas, mas nao define uma esteira de legado |
| Uplift de versao | Muito forte e detalhado | Fora do escopo |
| Hardening de seguranca | Muito forte | Trata seguranca como risco de design, nao como esteira propria |
| Planejamento de features | Medio | Muito forte |
| Decomposicao em tarefas | Medio | Muito forte |
| Testes derivados de criterios | Forte em transform/uplift | Muito forte e sistematico |
| Verificacao independente | Forte em workflows e revisoes | Muito forte, com Verifier obrigatorio |
| Persistencia de decisoes | Limitada a artefatos `analysis/` | Forte via `.specs/STATE.md` |
| Licoes aprendidas | Nao possui camada propria | Forte via `lessons.py` |

## Fluxo de trabalho

### Fluxo de `code-modernization`

O fluxo e orientado a programas de modernizacao:

1. `modernize-preflight` verifica readiness de ambiente, stack, toolchain,
   source completeness e contexto opcional.
2. `modernize-assess` produz inventario, complexidade, debt, seguranca,
   gaps de documentacao e recomendacao de padrao de modernizacao.
3. `modernize-map` cria grafo de chamadas, grafo de dados, entry points,
   dead-end candidates, fluxos por persona e viewer HTML.
4. `modernize-extract-rules` extrai regras de negocio em Rule Cards.
5. `modernize-brief` sintetiza um plano aprovado por humanos.
6. `modernize-transform`, `modernize-reimagine` ou `modernize-uplift`
   executam a estrategia.
7. `modernize-harden` encontra vulnerabilidades e gera patches revisaveis.
8. `modernize-status` informa progresso, staleness e higiene de segredos.

O ponto mais maduro do fluxo e a consciencia de que modernizacao precisa de
gates humanos e artefatos rastreaveis antes de alterar codigo.

### Fluxo de `tlc-spec-driven`

O fluxo e orientado a features:

1. `Specify` captura problema, objetivos, user stories, criterios de aceite,
   edge cases, assumptions e rastreabilidade.
2. `Discuss` entra quando ha areas cinzentas de comportamento.
3. `Design` define arquitetura, componentes, reuso, riscos e decisoes.
4. `Tasks` cria matriz de cobertura, comandos de gate, tarefas atomicas,
   dependencias e validacoes pre-aprovacao.
5. `Execute` implementa uma tarefa por vez, escreve testes antes do codigo,
   roda gate, revisa adequacao dos testes e faz commit atomico.
6. `Validate` roda uma verificacao independente com evidence-or-zero,
   spec-anchored outcome check e discrimination sensor.
7. `Lessons` grava sinais de falha em uma camada reutilizavel.

O ponto mais maduro do fluxo e a recusa explicita de aceitar "cobertura" sem
evidencia de assertion em `file:line` e sem comparar o valor assertado contra o
resultado definido na spec.

## Qualidade de verificacao

### `code-modernization`

Pontos fortes:

- `extract-rules` usa referees para validar citacoes antes de aceitar regras.
- Regras P0 passam por um painel independente.
- `harden-scan` tenta refutar findings e confirma Critical/High com segundo
  juiz.
- `transform` exige testes de caracterizacao antes da implementacao.
- `uplift` distingue dual-run real de target-only e documenta a forca da prova.
- `brief` para se artefatos de descoberta estiverem faltando.

Lacunas:

- Nao ha uma regra global equivalente ao Verifier de `tlc-spec-driven` para
  toda entrega.
- A verificacao e distribuida por comando. Isso e adequado ao dominio, mas
  menos uniforme.
- Os workflows nao tem testes automatizados de schema ou comportamento.

### `tlc-spec-driven`

Pontos fortes:

- Testes devem derivar da spec, nao da implementacao.
- Cada criterio precisa mapear para uma assertion concreta.
- Cada assertion precisa bater com o resultado esperado definido na spec.
- Tests devem ser necessarios e suficientes: sem gaps e sem testes fora do
  escopo.
- O gate deve passar antes do commit.
- O Verifier e obrigatorio apos a ultima tarefa.
- O discrimination sensor testa se os testes falham quando o comportamento e
  quebrado.
- Falhas viram fix tasks e podem virar licoes.

Lacunas:

- O Verifier e descrito como processo, nao implementado como script.
- O discrimination sensor depende de disciplina operacional e suporte do
  ambiente.
- O processo pode ser pesado para mudancas pequenas se o auto-sizing nao for
  aplicado com rigor.

## Seguranca e tratamento de codigo nao confiavel

### `code-modernization`

Este e o repositorio mais forte em seguranca.

Padroes recorrentes:

- Codigo analisado e tratado como dado, nunca como instrucao.
- Texto instruction-shaped em fonte legada vira finding.
- Credenciais sao mascaradas em todos os artefatos compartilhaveis.
- Segredos brutos so podem ir para arquivos locais/gitignored.
- `harden` separa patch compartilhavel de patch local com credenciais.
- Se nao ha git, o comando move arquivos sensiveis para `~/.modernize/<system>/`.
- O viewer de topologia escapa `<`, `>` e `&` antes de injetar JSON no HTML,
  evitando breakout de `</script>`.

Essa disciplina e consistente entre README, comandos, agentes e workflows.

### `tlc-spec-driven`

`tlc-spec-driven` trata seguranca mais como criterio de design e qualidade do
que como fluxo proprio.

Pontos positivos:

- `specify` inclui dimensoes implicitas como auth, rate limit, failure states,
  idempotencia e concorrencia.
- `design` exige flagar riscos de seguranca encontrados nas areas tocadas.
- `tasks` e `validate` forcam cobertura de criterios e edge cases.

Lacunas:

- Nao ha politica detalhada de quarantine de segredos.
- Nao ha equivalente a `security-auditor`.
- Nao ha regras especificas para patches que removem credenciais.

Se a prioridade for seguranca de legado, `code-modernization` e claramente mais
completo. Se a prioridade for evitar regressao funcional em features novas,
`tlc-spec-driven` e mais completo.

## Automacao real vs. especificacao de processo

`code-modernization` tem mais automacao de orquestracao:

- `extract-rules.js`
- `harden-scan.js`
- `portfolio-assess.js`
- `reimagine-scaffold.js`
- `uplift-deltas.js`

Esses workflows usam schemas, validacao de nomes, deduplicacao, fan-out de
agentes, verificacao independente e objetos estruturados de retorno. Eles nao
escrevem arquivos diretamente; a sessao chamadora escreve os artefatos. Essa
separacao e boa para seguranca.

`tlc-spec-driven` tem uma automacao menor, mas mais deterministica:

- `scripts/lessons.py`

O script gerencia IDs, candidatos, promocoes, quarentena, pruning e renderizacao
de licoes. Ele usa apenas biblioteca padrao e valida entradas obrigatorias,
como `--source`. Isso reduz fragilidade do bookkeeping.

Em termos de "codigo executavel proprio", `tlc-spec-driven` tem menos codigo,
mas o script e standalone. `code-modernization` tem mais codigo, mas ele depende
de um runtime especifico de workflow.

## Documentacao e experiencia de uso

### `code-modernization`

O README e mais completo para um usuario final. Ele explica:

- instalacao via `/plugin install`;
- quickstart;
- sequencia de comandos;
- comandos e agentes;
- setup de permissao recomendado;
- pre-requisitos;
- notas de seguranca;
- nota sobre COCOMO;
- orquestracao dinamica.

Isso torna o repositorio mais apresentavel como produto.

Risco: a copia local nao contem manifest visivel de plugin ou testes que
comprovem que a instalacao descrita bate com a estrutura atual.

### `tlc-spec-driven`

`SKILL.md` e muito forte como contrato para agentes, mas menos amigavel como
documentacao de repositorio. Ele explica o fluxo, regras criticas,
auto-sizing, estrutura `.specs/`, estrategia de contexto, sub-agents e comandos
por trigger.

Risco: um humano novo no repo pode precisar ler varios arquivos em `references/`
antes de entender o uso completo. Um README curto com exemplos ajudaria.

## Manutenibilidade

### `code-modernization`

Pontos positivos:

- Modulos por comando e agente facilitam evolucao por area.
- Workflows usam schemas de retorno, o que reduz outputs soltos.
- Ha repeticao deliberada das regras de seguranca, evitando perda de contexto
  quando um agente roda isolado.

Riscos:

- A superficie e ampla: comandos, agentes, workflows, assets e README precisam
  evoluir juntos.
- Parte do comportamento vive em prompts longos. Sem testes de regressao, e
  facil quebrar contratos entre comando e workflow.
- Os workflows tem globais de runtime e nao deixam claro localmente como rodar
  checks automatizados.

### `tlc-spec-driven`

Pontos positivos:

- A separacao por referencias deixa cada fase relativamente isolada.
- O contrato principal em `SKILL.md` orienta quando carregar cada referencia.
- `lessons.py` evita que bookkeeping importante dependa so de edicao manual.
- O processo tem guardrails contra scope creep, delecao de testes e perda de
  decisoes.

Riscos:

- A densidade do processo pode gerar atrito.
- A duplicacao de algumas regras entre `SKILL.md`, `implement.md`,
  `validate.md` e `sub-agents.md` aumenta custo de manutencao.
- Nao ha testes para garantir que os templates e referencias continuam
  consistentes.

## Adequacao por cenario

| Cenario | Melhor escolha | Motivo |
| --- | --- | --- |
| Avaliar um monolito legado | `code-modernization` | Tem assess, map, extract-rules e brief |
| Criar um roadmap executivo de modernizacao | `code-modernization` | Produz artefatos para steering committee |
| Extrair regras de negocio de COBOL/Java/.NET legado | `code-modernization` | Tem agentes e workflows especializados |
| Fazer uplift .NET Framework para .NET moderno | `code-modernization` | Tem delta catalog, dual-run e minimal-diff |
| Harden de seguranca de sistema legado | `code-modernization` | Tem scanner, triagem, patches e quarantine |
| Implementar feature nova com alto rigor | `tlc-spec-driven` | Tem spec, tasks, gates, verifier e lessons |
| Garantir testes significativos | `tlc-spec-driven` | Evidence-or-zero e discrimination sensor |
| Controlar decisoes entre sessoes | `tlc-spec-driven` | `.specs/STATE.md` separa Decisions e Handoff |
| Reduzir regressao por comportamento mal especificado | `tlc-spec-driven` | Spec-anchored outcome check |
| Melhorar processo ao longo do projeto | `tlc-spec-driven` | `lessons.py` promove licoes confirmadas |

## Pontuacao qualitativa

Escala: 1 baixo, 5 alto.

| Criterio | `code-modernization` | `tlc-spec-driven` |
| --- | ---: | ---: |
| Clareza de proposito | 5.0 | 5.0 |
| Foco de dominio | 5.0 | 4.5 |
| Abrangencia funcional | 5.0 | 4.0 |
| Rigor de verificacao | 4.0 | 5.0 |
| Seguranca operacional | 5.0 | 3.5 |
| Automacao concreta | 4.0 | 3.0 |
| Portabilidade standalone | 2.5 | 3.5 |
| Documentacao para usuario final | 4.5 | 3.5 |
| Manutenibilidade | 3.5 | 4.0 |
| Prontidao como pacote | 3.0 | 2.5 |

Leitura da pontuacao:

- `code-modernization` vence em dominio, seguranca, amplitude e artefatos de
  modernizacao.
- `tlc-spec-driven` vence em rigor de feature delivery, rastreabilidade,
  verificacao e aprendizado continuo.

## Principais riscos encontrados

### Riscos em `code-modernization`

1. Ausencia de manifest local de plugin ou metadata de pacote.
   O README descreve instalacao via plugin oficial, mas a arvore local nao
   permite validar esse caminho.

2. Workflows nao sao executaveis standalone.
   Eles dependem de runtime externo. Isso e aceitavel para um plugin, mas reduz
   testabilidade local.

3. Falta de testes automatizados.
   Nao ha testes de schema, snapshot de artefatos, lint de markdown, validacao
   do viewer ou smoke tests dos workflows.

4. Grande dependencia de prompts longos.
   A qualidade e alta, mas prompts longos precisam de regressao automatica para
   evitar drift.

5. Possivel custo operacional alto.
   Alguns comandos fan-out em dezenas de agentes. Isso e forte para cobertura,
   mas precisa de controle de custo, logs e retomada confiavel.

### Riscos em `tlc-spec-driven`

1. Processo pode ser pesado.
   A skill tenta mitigar com auto-sizing, mas a documentacao e extensa. Sem boa
   calibragem, tarefas medias podem receber cerimonia demais.

2. Verifier e discrimination sensor dependem de execucao por agente.
   O repositorio descreve o processo, mas nao fornece um executor automatico.

3. Falta de testes para `lessons.py`.
   O script e pequeno e respondeu ao `--help`, mas deveria ter testes para
   add, promote, prune, penalize e render.

4. Licenca menos evidente para consumidores.
   A licenca esta no frontmatter do `SKILL.md`, mas falta um arquivo `LICENSE`.

5. Pouca documentacao de instalacao.
   Um README com quickstart, exemplos e fluxo minimo reduziria atrito.

## Recomendacoes de melhoria

### Para `code-modernization`

1. Adicionar manifest de plugin ou explicar por que ele nao aparece nesta
   distribuicao.
2. Adicionar testes de contrato para os workflows:
   - args invalidos;
   - validacao de nomes;
   - schemas minimos;
   - deduplicacao;
   - ordenacao de severidade;
   - tratamento de injection flags.
3. Criar fixtures pequenas de legado para smoke tests:
   - um mini COBOL ou Java legacy;
   - uma regra de negocio;
   - uma credencial fake;
   - um grafo de chamadas simples.
4. Validar o `topology-viewer.html` com uma amostra de `topology.json`.
5. Adicionar uma matriz README -> comandos -> workflows, para garantir que a
   documentacao nao prometa comportamento ausente.
6. Incorporar uma etapa de validacao final inspirada em `tlc-spec-driven`,
   principalmente para `transform`, `reimagine` e `uplift`.

### Para `tlc-spec-driven`

1. Adicionar `README.md` com:
   - quando usar;
   - quickstart;
   - exemplo pequeno;
   - exemplo grande;
   - como o `.specs/` evolui.
2. Adicionar arquivo `LICENSE` correspondente ao frontmatter.
3. Adicionar testes para `scripts/lessons.py`.
4. Criar exemplos completos de `.specs/features/<feature>/`.
5. Fornecer um modo mais explicito de execucao "small feature" para evitar
   excesso de processo.
6. Adicionar uma politica de segredos inspirada em `code-modernization`.
7. Adicionar uma checklist de seguranca para features que tocam auth, dados
   sensiveis, pagamentos ou integracoes externas.

## Proposta de uso combinado

O melhor desenho e tratar os dois repositorios como complementares:

1. Rode `code-modernization` no legado.
2. Gere `ASSESSMENT.md`, `topology.json`, `BUSINESS_RULES.md` e
   `MODERNIZATION_BRIEF.md`.
3. Converta fases aprovadas do brief em specs de `tlc-spec-driven`.
4. Use P0 Rule Cards como acceptance criteria ou behavior contracts.
5. Execute cada fase com tarefas atomicas, gates e commits de
   `tlc-spec-driven`.
6. Use o Verifier e o discrimination sensor para validar a entrega final.
7. Alimente falhas recorrentes em `lessons.py`.

Essa combinacao cobre o ciclo completo:

- descoberta e entendimento do legado;
- planejamento executivo;
- implementacao disciplinada;
- verificacao independente;
- aprendizado persistente.

## Veredito final

`code-modernization` e mais ambicioso e mais especializado. Ele parece melhor
preparado para vender e conduzir um programa de modernizacao real, especialmente
em ambientes legados com riscos de seguranca, dependencia de stakeholders e
necessidade de mapas visuais.

`tlc-spec-driven` e mais rigoroso no nivel de feature delivery. Ele e menos
vistoso como produto, mas tem uma disciplina de engenharia mais transferivel:
spec clara, tarefas pequenas, testes fortes, commits atomicos, validacao
independente e licoes aprendidas.

Se for preciso escolher apenas um:

- Escolha `code-modernization` para modernizar sistemas legados.
- Escolha `tlc-spec-driven` para construir features com qualidade verificavel.

Se o objetivo for maximizar resultado em um projeto de modernizacao, use os
dois: `code-modernization` para descobrir e planejar, `tlc-spec-driven` para
executar e validar.
