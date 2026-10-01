# Roadmap e próximo passo

## Gate imediato — Items

**Validar Addon Packaging R2**. Enquanto o engine não montar os PBOs, não iniciar trabalho funcional 0.13-B.

## Fechar Items 0.13-A

Depois do load gate:
- smoke UI;
- host + amigos;
- cliente -> servidor -> clientes;
- republish/revision;
- dois autores;
- regressão curta de DnD, Whole-Kit, EXACT, Equipment, áudio e carga.

## Items 0.13-B — JIP & State Reconciliation

- bootstrap explícito;
- revisão autoritativa;
- detectar cliente stale;
- refresh/recovery.

## Items 0.13-C — Server Persistence & Recovery

- persistência pública controlada no servidor;
- schema/versioning/migrations;
- last-good/recovery;
- restart.

## Items 0.13-D — Permissions, Concurrency & Moderation

- ACL;
- update/delete autorizados;
- locks/concurrency;
- rate limit;
- moderação server-side.

## Items 0.13-E — Long-session & Large-modset Hardening

- soak;
- pruning/limits;
- telemetria;
- grandes catálogos/modsets;
- timeout/retry/recovery.

## Cross-module foundation

Sequência recomendada para **integrações futuras**, não pré-requisito para iniciar núcleos independentes:
1. congelar contratos públicos relevantes no Nexus;
2. migrar a baseline real do Armorer para o monorepo sem feature nova;
3. provar coexistência Nexus + Items + Armorer;
4. formalizar Weapons;
5. formalizar WeaponCondition;
6. formalizar Equipment/Sets;
7. formalizar Policy/ServerIntegration;
8. formalizar Hub após existirem contratos públicos suficientes para descoberta, navegação e passagem de contexto.

## Weapons

Produto player-facing independente, análogo a Items no princípio de isolamento de domínio.

Gates:
- WeaponInstance/serial lifecycle;
- WeaponConfiguration;
- Catalog/Compatibility;
- WeaponRecipe;
- WeaponKit;
- UI própria de organização/configuração de armas;
- aplicação slot-safe sem alterar o restante do loadout;
- autoridade/reconciliação multiplayer.

## WeaponCondition

Primeiros gates:
- provider autoritativo de condição;
- WeaponConditionState;
- shotsPending;
- água/natação/submersão;
- wear evaluation em lote;
- condition por peça;
- manutenção lógica;
- adapters externos.

## Armorer

- importar baseline histórica;
- validar equivalência;
- manter Armorer como experiência especializada de bancada/Preview/peças/manutenção;
- consumir Weapons para configuração/receitas/kits sem substituir a UI geral de Weapons;
- integrar WeaponCondition para condição/manutenção;
- somente depois evoluir manutenção 2.x.

## Policy

- whitelist/blacklist genérica;
- validação UI + executor/server;
- ownership único.

## ServerIntegration

- PersistenceProvider;
- StockProvider;
- EconomyProvider;
- QUERY/QUOTE -> RESERVE -> COMMIT -> RELEASE/ROLLBACK.

## 1.0 do ecossistema

Não significa todos os módulos terem todas as features futuras. Significa contratos públicos estáveis, baselines homologadas e integração previsível entre os módulos liberados.


## Hub

Primeiros gates:
- contrato de descoberta dos módulos disponíveis;
- padrão de abertura/navegação pública;
- passagem de contexto entre módulos;
- menu principal dinâmico;
- laboratório com Nexus + pelo menos dois módulos;
- provar que módulos continuam funcionando sem Hub;
- somente depois adicionar ações integradas multi-módulo.

## Weapons — progresso mission-first

### 0.1-A — Foundation & Identity Spike
Source integrado na branch. Base histórica da linha atual.

### 0.1-B — WeaponInstance Lifecycle / Event-Delta Evidence — APPROVED SP
- 128/128 AUTO;
- 3/3 live Take/Put;
- CORRELATED / AMBIGUOUS / UNPROVEN;
- identidade física intrínseca continua não alegada.

### 0.2 — WeaponConfiguration — APPROVED SP
- 175/175 AUTO;
- schema 0.2-candidate;
- capture/diff/apply/round-trip;
- PRIMARY/HANDGUN/SECONDARY;
- loadedState separado e preservado.

### 0.3 — Catalog & Compatibility — APPROVED SP
- candidata final R2;
- **213/213 AUTO**;
- catálogo-base real: 2770 armas;
- catálogo com presets: 3380;
- compatibilidade de attachments/magazines derivada do engine;
- provenance modded e cache aprovados;
- reverse lookup global evitado em favor de futuro índice reverso derivado do catálogo filtrado.

### 0.4 — WeaponRecipe — APPROVED SP

- R3: **245/245 AUTO**.
- Model/validation/fingerprint/deep-copy: approved.
- PRIMARY/HANDGUN/SECONDARY: approved.
- Runtime variants for SECONDARY resolved generically by `baseWeapon`.
- R4 hygiene passed, but runtime total was 245/246 because SECONDARY class changed between capture/apply.
- R5 final: **251/251 AUTO**.
- Slot-aware runtime/base family equivalence applies only to SECONDARY type=4 classes sharing `baseWeapon`.
- PRIMARY/HANDGUN remain strict.
- R4 case-insensitive hygiene remains green.
- Recipe schema/semantics remain unchanged.
- **WeaponRecipe mission-first frozen.**

### Roadmap corrigido de produto

```text
0.4  WeaponRecipe                            APPROVED 251/251
0.5  WeaponKit                               APPROVED 301/301

0.6-A Player UI Shell                        FROZEN BASELINE 362/362
0.6-B Selection + Information                APPROVED R4 397/397
0.6-C Compatibility Selectors                APPROVED R1 445/445
0.6-D WeaponKit Draft                         R1 APPROVED 471/471; R2 PERF REJECTED; R3 APPROVED 512/512
0.6-E Authoring/Lifecycle                      R1 AUTO 536/536 / UX SUPERSEDED; R2 ACTIVE — STATIC 296/296; RUNTIME PENDING (~545 projected)
0.6-F Final Visual Adaptation/Regression
0.7  Slot-Safe Weapon Application
0.8  Multiplayer Authority / Reconciliation
```

#### 0.4 — WeaponRecipe
Representar de forma estruturada uma montagem desejada e validável.

Estado atual: **R5 homologada 251/251**; baseline mission-first congelada.

#### 0.5 — WeaponKit
Unidade reutilizável/salvável pelo jogador. Um WeaponKit representa **uma arma configurada para um slot**, não um loadout completo.

Estado homologado:
- schema `0.5-kit-candidate`;
- `kitId + name + targetSlot + recipe`;
- repository `SESSION_LOCAL_CANDIDATE`;
- create/get/list/rename/duplicate/update/delete;
- runtime final **301/301**;
- UI segue em 0.6, application em 0.7 e MP em 0.8.

#### 0.6 — Weapons Player UI / Kit Builder
UI própria, simples e direta, fortemente inspirada nas lições aprendidas da parte de armas do APM histórico:
- meus kits;
- catálogo de armas;
- arma/configuração selecionada;
- acessórios compatíveis;
- informações da arma;
- criar/editar/duplicar/excluir/salvar kit;
- escolher slot alvo;
- preparar ação de equipar.

#### 0.7 — Slot-Safe Weapon Application
Aplicar/trocar apenas PRIMARY, HANDGUN ou SECONDARY alvo. Uniforme, colete, mochila, itens, outras armas e demais domínios devem permanecer inalterados.

#### 0.8 — Multiplayer Authority / Reconciliation
Autoridade servidor/cliente, concorrência, transferências, JIP/reconnect e reconciliação.

### Fronteira com Armorer

**Weapons UI** é a interface cotidiana de organização/configuração de armas e kits.

**Armorer UI** é a experiência especializada de bancada: Preview 3D avançado, peças/componentes, inspeção, condição e manutenção.

Armorer consome modelos/serviços de Weapons; Weapons não depende do Armorer para ser utilizável.

Gates paralelos ainda abertos: integração addon/PBO, Packaging, MP/JIP/reconnect e identidade física intrínseca. Contratos v1 ainda não devem ser congelados apenas pelos gates mission-first SP.


### 0.6-A — Player UI Shell — FROZEN BASELINE

R4 fechou o shell em **362/362 PASS / 0 FAIL**.

Decisões congeladas durante os checkpoints funcionais:
- layout: `MEUS KITS | KIT SELECIONADO | CATÁLOGO DE ARMAS`;
- rodapé semântico: `Context | Message | History`;
- nomes player-facing: `Principal / Porte / Secundária`;
- filtros `Todos / Principal / Porte / Secundária` em Meus Kits e Catálogo;
- escala de botões/textos igual à linguagem visual do Items;
- opacidade atual;
- largura safeZone atual, inclusive ultrawide;
- catálogo renderiza até 250 resultados por refresh e mantém o conjunto completo em cache;
- nenhuma mutação de WeaponKit/loadout no shell.

### Estratégia 0.6 após freeze do shell

Durante **0.6-B até 0.6-E**, priorizar funcionalidade e testes. Não reabrir polish visual a cada checkpoint.

Depois, em **0.6-F**, adaptar a UI ao conteúdo funcional final.

Polish compartilhado já registrado:
- reavaliar densidade vertical de KIT SELECIONADO;
- separar visualmente o rodapé em três faixas `Context / Message / History`;
- aplicar a mesma mudança de rodapé em **Items e Weapons**, na mesma rodada;
- validar novamente 1080p e ultrawide.

Referência: `docs/29_SHARED_UI_ITEMS_WEAPONS.md`.

### 0.6-B — Selection + Information — APPROVED R4

Final mission-first: **397/397 PASS / 0 FAIL**.

Histórico:
- R1: 392/392 funcional, mas rejeitada por warning massivo de structured text causado por `&`;
- R2: 392/392 e higiene corrigida; manual revelou lista MEUS KITS vazia até interação;
- R3: abertura corrigida, mas AUTO 391/396 por race de timing;
- R4: handshake inicial explícito e teste sincronizado; 397/397.

Contrato homologado:
- seleção de Catálogo e WeaponKit = informação read-only;
- MEUS KITS abre em TODOS/ALL com busca vazia;
- lista inicial sincroniza com repository;
- primeiro kit é selecionado quando existe;
- apresenta nome/tipo/classe/picture/origem/baseWeapon/descrição;
- nenhuma mutação de WeaponKit;
- nenhuma mutação de loadout;
- compatibilidade permanece para 0.6-C;
- draft permanece para 0.6-D;
- authoring permanece para 0.6-E;
- shell visual R4 permanece congelado.

**Checkpoint ativo: 0.6-E R2 — UX Convergence / Direct Draft Equip. R1 fechou 536/536, mas foi superada no gate manual de UX; R2 está 296/296 static, runner source 518, runtime projetado ~545.**



#### 0.6-C R1 — homologada

- baseline: 0.6-B R4 homologada 397/397;
- build: `0.6.2.1-compatibility-selectors-read-only-mission-first`;
- static: **335/335**;
- runtime real: **445/445 PASS / 0 FAIL**;
- dropdowns: Mira/Boca/Pointer/Bipé/Carregador;
- fonte: engine de compatibilidade da 0.3;
- comportamento: consulta read-only; valor salvo é restaurado após seleção alternativa;
- sem draft, authoring, aplicação física ou MP;
- shell R4 preservado.

**Gate 0.6-D fechado. Gate atual: 0.6-E R1 Authoring/Lifecycle.**


#### 0.6-D R1 — homologada

- baseline: 0.6-C R1 homologada **445/445**;
- build: `0.6.3.1-weaponkit-draft-local-mission-first`;
- static original: **260/260**;
- runner source: **444 assertions**;
- runtime real: **471/471 PASS / 0 FAIL**;
- draft session-local por WeaponKit;
- Mira/Boca/Pointer/Bipé/Carregador editam somente o draft;
- compatibilidade continua derivada da engine 0.3;
- status SALVO/ALTERADO + DESCARTAR funcional;
- draft deve sobreviver refresh/foco/fechar-reabrir sem perda silenciosa;
- repository/loadout permanecem imutáveis;
- arma-base e authoring/save continuam para 0.6-E;
- aplicação física continua para 0.7;
- MP continua para 0.8;
- shell R4 preservado.

**A convergência estrutural R2 foi implementada; como o gate manual de performance falhou, 0.6-E permanece bloqueada até a correção R3.**


#### 0.6-D R2 — AUTO verde / gate manual de performance reprovado

- baseline funcional: 0.6-D R1 **471/471**;
- build: `0.6.3.2-ui-convergence-equipment-content-mission-first`;
- static: **232/232**;
- runner source: **473 assertions**;
- runtime real: **500/500 PASS / 0 FAIL**;
- quatro painéis alinhados estruturalmente ao Items Multiplayer Lab R3;
- transparência/tokens visuais do Items;
- catálogo com filtro Tipo + Acessório;
- janela contínua de 32 linhas + scrollbar/wheel;
- quarto painel Conteúdo do Equipamento read-only;
- título `KIT SELECIONADO / RASCUNHO`;
- draft 0.6-D R1 preservado;
- authoring/save permanece 0.6-E;
- aplicação física permanece 0.7;
- MP permanece 0.8;
- backlog formal Items↔Weapons em `docs/29_SHARED_UI_ITEMS_WEAPONS.md`.

- manual: **REPROVADO** por stuttering do catálogo; o RPT mostrou full refresh em cada passo de scroll (~246–254 ms).

#### 0.6-D R3 — HOMOLOGADA

- build: `0.6.3.3-focused-refresh-header-polish-mission-first`;
- static **272/272**;
- runner source **485**;
- runtime projetado **512**, pendente;
- refresh focal de catálogo/draft/equipamento;
- projeção/filtro do catálogo cacheados;
- header ancorado da direita para a esquerda a partir do X;
- mensagem amigável de catalogação;
- nenhuma mudança de ownership/gate: authoring 0.6-E, aplicação 0.7, MP 0.8.

**Gate R3 fechado. 0.6-E liberada para implementação mission-first.**


#### 0.6-E R1 — AUTO 536/536 / UX superada

- build: `0.6.4.1-authoring-lifecycle-session-local-mission-first`;
- baseline: 0.6-D R3 **512/512**;
- static: **257/257**;
- runner source: **509**;
- runtime projetado: ~**536**, pendente;
- NOVO / RENOMEAR / DUPLICAR / EXCLUIR;
- SALVAR / SALVAR COMO NOVO;
- troca da arma-base no draft, somente dentro do mesmo slot;
- mudança da arma-base reseta attachments/magazine do draft;
- focused refresh R3 preservado;
- nome inline preservado durante refresh focal;
- repository continua session-local;
- nenhuma mutação de loadout físico;
- aplicação continua 0.7;
- MP/JIP/reconnect continua 0.8.

**0.6-F bloqueada até runtime/manual da 0.6-E R2.**


#### 0.6-E R2 — candidata ativa

- build: `0.6.4.2-ux-convergence-direct-draft-equip-mission-first`;
- R1: **536/536**, authoring funcional preservado;
- static R2: **296/296**;
- runner source: **518**;
- runtime projetado: ~**545**, pendente;
- NOVO passa a preparar rascunho e pedir a arma via Catálogo;
- `←` e `EQUIPAR NO RASCUNHO` aplicam seleção do Catálogo ao draft;
- P1 converge para `Novo/Duplicar/Excluir/Publicar`;
- rename fica no P2 via nome inline + SALVAR;
- P2/P4 recebem buscas sincronizadas ao Catálogo;
- P2 recebe ações no topo e destrutivas vermelhas;
- Bipé + Empunhadura = filtro UNDERBARREL;
- P4 usa Visualizar + slots na mesma linha;
- footer sem outer frame e Histórico com maior contraste;
- ação física da seta direita permanece **DEFERRED_0_7**;
- focused refresh R3 preservado.

**0.6-F bloqueada até runtime/manual da R2.**
