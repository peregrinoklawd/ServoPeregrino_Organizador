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
0.6-E Authoring/Lifecycle                      R1 AUTO 536/536 / UX SUPERSEDED; R2 ORIGINAL 534/554; R2 HF1 557/558 — SUPERSEDED BY 0.6-F
0.6-F Final Visual Adaptation/Regression        R1 ACTIVE — STATIC 86/86; RUNNER 537; RUNTIME/MANUAL/PERF PENDING
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

**Checkpoint ativo: 0.6-F R1 — Final Visual Adaptation / Regression. A R2 HF1 fechou 557/558; o único FAIL foi absorvido como hotfix da 0.6-F.**



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


## Gate imediato — UICommon

A frente ativa passa a ser a fundação compartilhada de UI antes de continuar a Weapons 0.6-E R2.

Sequência obrigatória:
1. validar `UICommon 0.1 foundation` isoladamente;
2. criar/validar laboratório conjunto mission-first Items + Weapons + UICommon;
3. migrar infraestrutura genérica de Items para UICommon sem alterar UX;
4. executar o contrato `30_ITEMS_UI_REGRESSION_CONTRACT.md`;
5. homologar equivalência Items + UICommon;
6. migrar/implementar Weapons 0.6-E R2 sobre UICommon conforme `32_WEAPONS_0_6_E_R2_UI_FREEZE.md`;
7. validar Weapons em runtime/manual/performance;
8. somente então retomar 0.6-F/0.7;
9. numa rodada posterior, aplicar em Items as melhorias compartilhadas já homologadas.

Regras:
- não criar dependência Items <-> Weapons;
- UICommon permanece separado do Nexus em PBO, embora ambos sejam distribuídos no pacote Core;
- missão e PBO devem consumir os mesmos contratos/fontes, evitando duas implementações divergentes;
- Public Loadouts de Items permanecem pendentes de validação manual específica e não bloqueiam a extração inicial do UICommon.


## Checkpoint ativo — Items + UICommon Equivalence R1

Gate 1 foi concluído e o Hotfix 1 conjunto foi aceito.

Agora:
1. executar UICommon 0.1.1 -> 12/12;
2. executar Items + UICommon Equivalence -> 12/12;
3. smoke/checklist de Items sem redesign;
4. Weapons permanece baseline E R1 -> 536/536;
5. se equivalência fechar, iniciar Weapons 0.6-E R2 sobre UICommon;
6. depois da R2, executar rodada explícita de convergência visual de Items.

A mensagem Items `Vasculhando inventário e catalogando itens...` está confirmada no backlog e NÃO faz parte da Equivalence R1.


## Checkpoint ativo — Weapons 0.6-E R2 + UICommon

Items + UICommon Equivalence R1 foi aprovada para Items.

Checkpoint agora:
1. testar UICommon 12/12 como regressão;
2. testar Items+UICommon 12/12 como regressão;
3. abrir Weapons R2 no cold-open;
4. validar novo fluxo de criação;
5. validar Catálogo -> ARMAS DO KIT;
6. validar SALVAR nome + Recipe;
7. validar PUBLICAR reservado;
8. validar ausência de mutação física;
9. rodar AUTO R2;
10. avaliar wheel/slider e focused refresh manualmente;
11. enviar RPT + prints.

Somente após R2 AUTO/manual/performance verde:
- iniciar 0.6-F Final Visual Adaptation/Regression;
- depois 0.7 Slot-Safe Weapon Application;
- depois 0.8 Multiplayer Authority/Reconciliation.

A convergência visual de Items continua posterior e separada.


## Atualização 03/10/2026 — Weapons 0.6-E R2 Hotfix 1

Resultado real da candidata R2 original:
- AUTO: **534/554 PASS, 20 FAIL**;
- UICommon: **12/12**;
- Items + UICommon Equivalence: **12/12**;
- a candidata R2 original fica **REPROVADA** e não libera 0.6-F.

Causas consolidadas do Hotfix 1:
1. **NOVO / seleção:** o fallback legado do ViewModel selecionava automaticamente o primeiro WeaponKit quando `selectedKitId` estava vazio, sequestrando o estado `pendingNewKit`;
2. **P2 / filtro vazio:** o estado antigo podia continuar chegando ao renderer quando a projeção de Meus Kits não continha a seleção, fazendo P2 impersonar um kit fora do filtro;
3. **Catálogo de acessórios:** a projeção cacheada de compatibilidade podia permanecer associada à arma-base anterior depois de uma troca no Draft dentro do mesmo `kitId`; o dropdown Mira lia o Draft atual e o Catálogo podia continuar lendo a projeção antiga;
4. **runner R2:** a expectativa dos seletores de equipamento ainda exigia os textos antigos completos, embora a R2 use intencionalmente `PRINC. / PORTE / SEC.`;
5. **Items 0.13-A em mission-first:** 4 FAILs eram causados pelo test harness procurando caminhos do addon/PBO em uma missão self-contained.

Hotfix 1:
- preserva `NOVO` sem repository object até a primeira ARMA;
- ao iniciar NOVO, limpa busca/seleção anterior e força a categoria `WEAPON`;
- sincroniza a seleção resolvida pelo ViewModel antes de renderizar ARMAS DO KIT;
- invalida a projeção do Catálogo em troca de arma-base e em DESCARTAR;
- adiciona regressão automática para provar paridade entre a ótica do dropdown e a projeção do Catálogo;
- adiciona regressão para provar rebuild da projeção após troca da arma-base;
- adapta somente o runner Items 0.13-A aos paths mission-first;
- mantém aplicação física em 0.7 e MP/JIP/reconciliação em 0.8.

Validação estática do Hotfix 1:
- **69/69 PASS**;
- runner R2 HF1: **531 assertion sites**;
- runtime real continua pendente; o RPT é a autoridade.

Gate atual:
1. testar R2 HF1 no Arma sem PBOs SP_ORG;
2. UICommon 12/12;
3. Items + UICommon 12/12;
4. validar NOVO -> ARMA -> EQUIPAR NO RASCUNHO;
5. validar dropdown Mira x filtro ÓTICAS para a mesma arma;
6. trocar arma-base no mesmo slot e confirmar que ÓTICAS acompanha a nova arma;
7. validar LIMPAR / DESCARTAR / SALVAR / SALVAR COMO NOVO;
8. executar AUTO R2 HF1;
9. validar wheel/slider sem regressão de full refresh/stutter;
10. enviar RPT + prints.

Somente após AUTO + manual + performance verdes:
- **0.6-F** Final Visual Adaptation/Regression;
- **0.7** Slot-Safe Weapon Application;
- **0.8** Multiplayer Authority/Reconciliation.

### Auditoria BGD Development

A issue **#9** continua marcada como importante, mas **não é gate do checkpoint atual**. O momento de execução permanece em avaliação e pode ser deslocado para a revisão final do projeto antes do packaging/PBO definitivo.


## Atualização 04/10/2026 — Checkpoint ativo: Weapons 0.6-F R1

A 0.6-E R2 HF1 foi executada no Arma:
- **557 PASS / 1 FAIL / 558 total**;
- UICommon: 12/12;
- Items + UICommon: 12/12;
- compatibilidade Mira x Catálogo ÓTICAS: aprovada;
- rebuild da projeção após troca da arma-base: aprovado;
- focused refresh de wheel/slider: preservado;
- único FAIL: cancelamento de NOVO restaurava seleção pelo fallback genérico em vez de manter contrato explícito.

Decisão:
- não criar R2 HF2;
- incorporar o ajuste diretamente à **0.6-F R1**.

### 0.6-F R1 — Final Visual Adaptation / Regression

Build:
`0.6.5.1-final-visual-regression-uicommon-mission-first`

Escopo:
1. congelar a composição visual final da linha 0.6 sem redesign amplo;
2. preservar integralmente o authoring direto da R2 HF1;
3. preservar focused refresh/cache da R3;
4. incorporar `previousKitIdBeforeNew`;
5. `NOVO -> DESCARTAR` restaura o kit anterior quando possível e nunca cria WeaponKit apenas para cancelar;
6. manter aplicação física reservada para 0.7;
7. manter MP/JIP/reconciliação reservada para 0.8.

Validação local:
- Weapons static: **86/86 PASS**;
- full-lab static: **24/24 PASS**;
- runner: **537 assertion sites**;
- Items/Nexus/UICommon: byte-idênticos à HF1;
- runner histórico R2 HF1: byte-idêntico.

Gate para homologar 0.6-F:
1. missão sem PBOs SP_ORG;
2. UICommon 12/12;
3. Items + UICommon 12/12;
4. selecionar kit A -> NOVO -> DESCARTAR -> kit A deve voltar;
5. NOVO -> arma -> EQUIPAR NO RASCUNHO;
6. Mira/ÓTICAS e troca de arma-base;
7. SALVAR / SALVAR COMO NOVO / DUPLICAR / EXCLUIR;
8. PUBLICAR continua reservado;
9. EQUIPAMENTO → continua não mutante;
10. wheel/slider sem full refresh/stutter;
11. AUTO 0.6-F com **0 FAIL**;
12. RPT + prints.

Se fechar:
- **0.6 é homologada e congelada**;
- próximo checkpoint: **0.7 Slot-Safe Weapon Application**;
- depois: **0.8 Multiplayer Authority / Reconciliation**.

### Items

A 0.6-F R1 **não** executa a convergência visual própria de Items.
Continuam no backlog separado:
- `ITENS DO KIT`;
- destaque de linhas alteradas;
- `Mostrar -> Visualizar`;
- `Vasculhando inventário e catalogando itens...`;
- investigação da transparência mission-first x PBO.

### Auditoria BGD Development

Issue #9 continua importante, porém não é gate da 0.6-F. O timing permanece em avaliação e pode ser movido para a revisão final antes do packaging/PBO definitivo.


## Atualização 04/10/2026 — 0.6-F R2 UI Polish

Checkpoint ativo:
**Weapons 0.6-F R2 — UI Polish / Changed-State Highlight**

A R2 concentra os últimos ajustes de UI da linha 0.6:
1. destaque semântico por campo alterado em ARMAS DO KIT;
2. reversão do destaque quando o valor volta ao Recipe salvo;
3. preview/nome/classe de ARMAS DO KIT alinhados ao CONTEÚDO DO EQUIPAMENTO;
4. área visual preparada para futuro preview 3D;
5. regressão completa sem aplicação física.

Validação local:
- Weapons 69/69;
- full-lab 30/30;
- runner 545 assertion sites.

Se runtime + manual + performance fecharem:
- **linha Weapons 0.6 HOMOLOGADA/CONGELADA**;
- próximo checkpoint: **0.7 Slot-Safe Weapon Application**;
- depois: **0.8 Multiplayer Authority/Reconciliation**.

Pendências Items continuam separadas:
- ITENS DO KIT;
- linhas alteradas;
- Visualizar;
- mensagem amigável de catalogação;
- diferença visual mission-first x PBO.

Auditoria BGD continua issue #9, importante, timing em avaliação.


## Atualização 04/10/2026 — Checkpoint 0.6-F R3

Checkpoint ativo:
**Weapons 0.6-F R3 — Search Isolation / Name Editing**

Foco final da linha 0.6:
1. nome inline estável;
2. buscas P2/P3/P4 independentes;
3. busca global do Catálogo pausando filtros;
4. changed-row highlight;
5. preview-ready P2/P4;
6. regressão/performance.

Se fechar runtime/manual/performance com 0 FAIL:
- linha 0.6 homologada/congelada;
- próximo checkpoint: 0.7 Slot-Safe Weapon Application;
- depois 0.8 Multiplayer Authority/Reconciliation.


## Atualização 05/10/2026 — Checkpoint 0.6-F R4

Checkpoint ativo:
**Weapons 0.6-F R4 — Keep Aspect / Uniform Catalog Filters**

R3 real:
- 579 PASS / 3 FAIL / 582;
- os dois FAILs de busca eram test drift;
- o FAIL de header era visual/versionamento.

R4 fecha:
1. preview 2D sem distorção;
2. centralização da arma dentro da área;
3. mesma regra de proporção para P2 e P4;
4. Tipo do Catálogo em botões uniformes;
5. Acessório do Catálogo em uma única linha de botões uniformes;
6. atualização dos testes legados de busca;
7. header R4.

Validação local:
- 86/86;
- runner 560 assertion sites.

Se runtime + manual + performance fecharem com 0 FAIL:
- Weapons 0.6 homologada/congelada;
- próximo gate: 0.7 Slot-Safe Weapon Application;
- depois: 0.8 Multiplayer Authority/Reconciliation.

Botões com imagens estilo Arsenal e Preview 3D real permanecem futuras evoluções, não entram na R4.


## Gate imediato — Weapons 0.6-F R5

Antes de abrir 0.7:
1. validar cold-open sem kits;
2. Catalogo -> arma -> EQUIPAR NO RASCUNHO deve criar kit NOVO automaticamente;
3. validar troca dinâmica Principal/Porte/Secundária sem trava de tipo;
4. confirmar que o tipo interno não aparece em ARMAS DO KIT/footer;
5. validar mensagens amigáveis sem códigos internos;
6. executar AUTO R5 e exigir 0 FAIL;
7. revisar performance/focused refresh;
8. somente então congelar 0.6 e iniciar 0.7 Slot-Safe Weapon Application.

Pendência técnica de repositório: sincronizar o source avançado R5 para a missão canônica; atualmente ela ainda carrega Weapons E R1.


## Atualização 05/10/2026 — Weapons 0.6 liberada / próximo gate 0.7

Resultado da última candidata:
- **0.6-F R6**;
- runtime **595/597**;
- **2 FAILs exclusivamente de test harness** ligados a identificação textual de revisão/header;
- testes manuais aprovados;
- sem regressão funcional observada;
- layout/filtros/preview/authoring/focused-refresh aceitos.

Decisão de continuidade:
- não gerar R7 apenas para trocar/remover texto de header;
- remover ou substituir asserts de texto/versionamento cosmético por checks funcionais estáveis;
- considerar a linha **0.6 encerrada para avanço funcional**;
- iniciar **0.7 — Slot-Safe Weapon Application**.

### 0.7 — Slot-Safe Weapon Application

Objetivo:
aplicar fisicamente o WeaponKit no slot derivado internamente da arma do Draft sem alterar os demais slots/equipamentos do jogador.

Contrato inicial:
- PRIMARY altera somente arma principal;
- HANDGUN altera somente arma de porte;
- SECONDARY altera somente lançador/secundária;
- demais armas permanecem intactas;
- uniforme/colete/mochila permanecem intactos;
- itens gerais permanecem intactos;
- acessórios aplicados devem continuar engine-derived/compatíveis;
- o jogador não precisa gerenciar `targetSlot`; a aplicação usa o metadata interno derivado;
- a ação física do Catálogo/Equipment que estava reservada desde 0.6 passa a ser habilitada nesta fase.

Primeiro passo técnico da 0.7:
1. limpar asserts frágeis herdados da 0.6 que verificam revisão/header literal;
2. sincronizar o source mission-first avançado com o repositório antes de congelar a nova baseline;
3. criar testes de isolamento de slot;
4. somente depois habilitar mutação física na UI.

Próximo após 0.7:
- **0.8 — Multiplayer Authority / JIP / Reconciliation**.

### Pendências paralelas

Items permanece separado:
- ITENS DO KIT;
- destaque de linhas alteradas;
- Visualizar;
- mensagem amigável de catalogação;
- diferença visual mission-first x PBO.

Auditoria BGD:
- issue #9;
- importante;
- timing ainda em avaliação;
- pode ser executada mais perto do fechamento/packaging final.


## Atualização 05/10/2026 — 0.7 com estudo APM pronto

A implementação da 0.7 deve usar como referência:
`docs/44_WEAPONS_0_7_APM_APPLICATION_CASE_STUDY.md`.

Sequência recomendada:
- **0.7-A** Plan / Snapshot / Dry-Run — nenhuma mutação física;
- **0.7-B** Slot-Safe Apply;
- **0.7-C** Post-Validation / Rollback;
- **0.7-D** UI Integration / Undo candidate.

Hipótese principal para spike:
- clonar `getUnitLoadout`;
- substituir somente slot alvo;
- `setUnitLoadout <clone>, false`;
- pós-validar alvo e fingerprints de preservação;
- rollback se houver divergência.

A estratégia é hipótese até runtime; comparar com comandos slot-local se necessário.

### Preview 3D

Caso de estudo:
`docs/45_WEAPONS_PREVIEW_3D_APM_ARMORER_CASE_STUDY.md`.

Não misturar com o primeiro gate 0.7.
Direção preferida:
- arquitetura híbrida nova;
- APM fidelity/transparent integration/natural scale;
- Armorer framing/pivot/diagnostics;
- controles simplificados e mais fluidos.

Timing padrão:
- depois da 0.7 e 0.8;
- spike paralelo permitido apenas após 0.7-B estável.

Handoff:
`docs/46_NEXT_CHAT_HANDOFF_WEAPONS_0_7.md`.


## Atualização 05/10/2026 — checkpoint ativo UICommon 0.2-A

A sincronização do source mission-first Weapons R6 foi concluída.

Portanto, o próximo passo NÃO é abrir imediatamente a mutação física 0.7.

Checkpoint ativo:
**UICommon 0.2-A — Shared Infrastructure Inventory**.

Objetivo:
- comparar Items e Weapons R6 diretamente no Git;
- mapear infraestrutura genérica duplicada;
- classificar `SHARED / CANDIDATE-SHARED / DOMAIN-SPECIFIC / DEFERRED`;
- definir testes de equivalência;
- não alterar runtime antes de revisar a matriz.

Prioridades candidatas:
1. Footer Contexto/Resultado/Histórico;
2. keep-aspect/preview surface genérico;
3. focused invalidation + performance instrumentation;
4. virtual list/window/wheel/slider;
5. search plumbing;
6. theme/generic controls;
7. tooltip/pointer/DnD visual em rodada posterior.

Depois da consolidação/equivalência UICommon 0.2:
- Weapons 0.7-A Plan/Snapshot/Dry-Run;
- 0.7-B Slot-Safe Apply;
- 0.7-C Validation/Rollback;
- 0.7-D UI Integration/Undo candidate;
- 0.8 Multiplayer Authority/Reconciliation.

Referência:
`docs/48_UICOMMON_0_2_SHARED_INFRASTRUCTURE_PLAN.md`.


## Checkpoint — UICommon 0.2-B Pure Shared Primitives

O inventário comparativo real Items x Weapons R6 x UICommon foi concluído antes de qualquer refatoração.

Decisões principais:
- compartilhar mecanismo, nunca regra de domínio;
- controles/tokens/footer/virtual navigation/perf são os maiores alvos reais;
- focused refresh permanece decidido por cada consumidor;
- keep-aspect é CANDIDATE-SHARED porque hoje só Weapons o prova;
- row pool, tooltip overlay e drag ghost ficam DEFERRED;
- UI state/view-model/projeção de catálogo continuam DOMAIN-SPECIFIC.

Primeira extração implementada:
- UICommon display `0.2`;
- semantic `0.2.0.1`;
- build `0.2.0.1-pure-shared-primitives-b1`;
- novo `getVirtualScrollState`;
- novo `pointInRect`;
- foundation source agora possui 24 assertion sites;
- Items + UICommon mantém 12 assertion sites, mas não depende mais do texto literal do build.

Commit técnico:
`7fbc103093fedf583ed10c94cc8bb717ea9ba0f4`.

Static:
- addon/mission parity das novas primitivas: OK;
- referências de domínio nas novas primitivas: 0;
- registros CfgFunctions/description.ext: OK;
- balanceamento estrutural dos arquivos alterados: OK.

Importante:
**24/24 em runtime ainda NÃO foi declarado.**
É necessário RPT real do Arma para homologar a candidata 0.2-B.

Próximo gate:
1. UICommon Foundation 0.2-B no Arma;
2. Items + UICommon Equivalence;
3. se verdes, iniciar 0.2-C Virtual Navigation + Footer sem alterar domínio.


## Checkpoint aprovado — UICommon 0.2-B

RPT real do Arma recebido para a missão canônica.

Build executado:
`0.2.0.1-pure-shared-primitives-b1`.

Resultado runtime:
- UICommon Foundation: **24 PASS / 0 FAIL**;
- Items + UICommon Equivalence: **12 PASS / 0 FAIL**;
- UICommon inicializou corretamente;
- Items inicializou corretamente;
- Weapons 0.6-F R6 permaneceu inicializando na mesma missão;
- nenhuma regressão SP_ORG foi observada neste gate.

Conclusão:
**UICommon 0.2-B — HOMOLOGADA / CONGELADA.**

Observação ambiental:
o RPT contém erros de parâmetro em `CBA_fnc_addPerFrameHandler` durante PostInit.
A missão canônica empacotada não contém chamada a `CBA_fnc_addPerFrameHandler`, e os erros não impediram inicialização nem os gates 24/24 e 12/12. Portanto, não são atribuídos à 0.2-B neste checkpoint.

Próximo gate:
**UICommon 0.2-C — Virtual Navigation + Footer Rendering**, preservando focused refresh e sem mover regra de domínio para UICommon.


## Checkpoint ativo — UICommon 0.2-C C1

A 0.2-B permanece homologada como fallback.

Candidata:
- display: `0.2`;
- semantic: `0.2.0.2`;
- build: `0.2.0.2-virtual-navigation-footer-c1`;
- commit técnico base: `70f54e6fad35d775938bd9f0d15c45d488f550cf`;
- correção de revisão: `df0b75ba732397c56536e02b72cf447889ab841e`.

Escopo implementado:
- novo `syncVirtualSlider`, baseado em `getVirtualScrollState`;
- novo `buildFooterBandStructuredText`;
- novo `renderFooter`;
- Items Full/Catalog focused usam slider compartilhado;
- Weapons Full/Catalog focused usam slider compartilhado;
- Items Full/Catalog/Draft/Equipment usam renderer de footer compartilhado;
- Weapons Full/Catalog/Draft usam renderer de footer compartilhado;
- wheel hit testing de Items e Weapons passa a usar `pointInRect`.

Ownership preservado:
- Items/Weapons continuam construindo contexto, mensagem, histórico, filtros, seleção e regras de evento;
- UICommon não conhece ItemKit, WeaponKit, catálogo de domínio, targetSlot ou aplicação física;
- wheel continua chamando `CATALOG_SCROLL` do módulo consumidor;
- nenhuma chamada global de refresh foi introduzida.

Performance contract:
- `CATALOG_SCROLL -> offset -> refreshCatalogWindowUI`;
- focused refresh continua registrando `fullRefresh=false`;
- slider/footer não podem causar recapture de Equipment ou rebuild global por si próprios.

Static gate:
- addon/missão UICommon: paridade preservada;
- addon/missão Items nos arquivos migrados: paridade preservada;
- novas funções UICommon: zero referências de domínio;
- blocos antigos de footer direto removidos dos refreshers migrados;
- blocos manuais de `sliderSetRange` removidos dos refreshers migrados;
- balanceamento estrutural dos arquivos alterados: OK;
- UICommon Foundation: **31 assertion sites**;
- Items + UICommon Equivalence: **16 assertion sites**;
- runner Weapons R6 não foi modificado.

Runtime:
**PENDENTE DE RPT REAL DO ARMA.**

Gate esperado:
1. UICommon Foundation: **31/31**;
2. Items + UICommon Equivalence: **16/16**;
3. regressão Weapons R6 deve manter no máximo os mesmos **2 FAILs NON_FUNCTIONAL/HARNESS-ONLY** já conhecidos; qualquer FAIL novo é bloqueador;
4. abrir Items e Weapons e validar footer CONTEXTO/RESULTADO/HISTÓRICO;
5. wheel/slider de catálogo sem stutter e com `fullRefresh=false` no RPT.

Não iniciar 0.2-D antes deste gate.


## Checkpoint — UICommon 0.2-C C2 performance

RPT real da C1:
- UICommon Foundation: **31 PASS / 0 FAIL**;
- Items + UICommon Equivalence: **16 PASS / 0 FAIL**;
- Weapons R6: **595 PASS / 2 FAIL / 597**, exatamente os dois FAILs harness/version-text já conhecidos;
- wheel do Weapons: aproximadamente **6–10 ms**, `projectionBuilt=false`, `fullRefresh=false`;
- wheel do Items: aproximadamente **13–14 ms**, sem projection rebuild e sem equipment recapture.

Manual:
- footer e navegação aprovados;
- foi percebido stutter ao enviar/trocar arma-base do Catálogo para o rascunho.

Diagnóstico do RPT:
- após a seleção/equip da arma, o caminho executava `mode=FULL`;
- exemplos manuais: **298 ms**, **246 ms**, **110 ms**, **97 ms**, **281 ms**, **346 ms**;
- nesses eventos `projectionBuilt=true`;
- o custo não vem de autosave nem de mutação física: em kit existente a arma é alterada somente no draft de sessão;
- a persistência real continua acontecendo apenas em SALVAR;
- o excesso era `_refresh=true` em `CATALOG_TO_DRAFT` / `SET_DRAFT_WEAPON`.

C2:
- build `0.2.0.2-virtual-navigation-footer-c2`;
- commit técnico `0d584e3a4b874418de171a753b68292184737a22`;
- base-weapon swap em kit existente agora atualiza somente **P2 Draft + P3 Catalog**;
- P1 e P4 não são reconstruídos;
- accessory Catalog-to-Draft atualiza somente P2;
- auto-create sem kit selecionado mantém FULL porque cria um novo WeaponKit de sessão e P1 realmente muda;
- nova regressão automática garante zero incremento de full refresh e +1 Draft/+1 Catalog focused no base swap.

C1 não é congelada como 0.2-C final por causa do gate de performance manual.
C2 aguarda RPT real.

Runtime esperado da C2:
- UICommon: **31/31**;
- Items + UICommon: **16/16**;
- Weapons R6+C2: **596 PASS / 2 FAIL / 598 total**, mantendo apenas os dois harness-only conhecidos;
- durante troca de arma-base em kit existente devem aparecer `DRAFT_FOCUSED reason=CATALOG_TO_DRAFT` e `CATALOG_FOCUSED reason=CATALOG_TO_DRAFT`, sem `mode=FULL` provocado por essa operação.


## 06/10/2026 — C2 runtime confirmado; harness endurecido para 0 FAIL

- C2 removeu o FULL refresh do base-weapon Catalog-to-Draft.
- O regression check de Draft+Catalog focused passou no RPT real.
- Stutter residual acompanha a projeção de compatibilidade; aceito para este gate.
- Dois FAILs de versão/header foram removidos do conjunto bloqueante.
- Commit de hardening: `7933fbb8a1838bf817c0b809834b8cf105eb6932`.
- Próximo gate: Weapons **594/594, 0 FAIL**, com 6 observações não bloqueantes.

## 06/10/2026 — UICommon 0.2-C homologada

Runtime real:
- UICommon: **31/31**;
- Items + UICommon: **16/16**;
- Weapons: **594/594**, **0 FAIL**, 6 observações;
- C2 base-weapon Catalog-to-Draft sem FULL refresh;
- stutter residual de projection rebuild aceito para este gate.

Estado:
**UICommon 0.2-C — HOMOLOGADA / CONGELADA.**

Próxima entrega:
**UICommon 0.2-D — Shared Visual Foundation / HPP.**

Nova regra de pacote de teste:
a missão distribuída deve ter nome próprio por entrega/revisão. O source canônico permanece único no Git; o workflow renomeia a pasta somente no pacote.


## UICommon 0.2-D R1 — Shared Visual Foundation / HPP

Candidata:
- semantic `0.2.0.3`;
- build `0.2.0.3-shared-visual-hpp-d1`;
- commit técnico `7f2d86e406826087a0421282f89b130cf62891d4`;
- missão distribuída: `SP_ORG_UI_Lab_UICommon_0_2_D_R1.VR`.

Extração:
- novo `UICommon/ui/shared_controls.hpp`;
- métricas genéricas de clear/search/header anchor;
- Text / Title;
- Picture e PictureKeepAspect como variantes explícitas;
- SearchIcon e SearchIconKeepAspect;
- Button / ButtonDanger / IconButton;
- Edit;
- List base;
- Structured + três bases de Footer;
- VSlider.

Preservado:
- Items mantém CT_CONTROLS_TABLE e geometrias próprias;
- Weapons mantém Combo, keep-aspect e rowHeight 0.033;
- nenhum IDC mudou;
- nenhuma action/event handler mudou;
- nenhuma geometria de painel mudou;
- domínio e refresh routing não mudaram.

Static gate:
- UICommon addon/mission shared HPP byte-idênticos;
- Items addon/mission byte-idênticos;
- corpo de `SP_ORG_Items_Dialog` byte-idêntico à 0.2-C;
- corpo de `SP_ORG_Weapons_Dialog` byte-idêntico à 0.2-C;
- shared HPP com zero referências Items/Weapons/ItemKit/WeaponKit;
- keep-aspect Weapons preservado;
- Weapons list rowHeight 0.033 preservado;
- delimitadores estruturais balanceados;
- workflow de pacote: sucesso.

Runtime:
**PENDENTE DE RPT REAL.**

Gate:
- UICommon 31/31;
- Items + UICommon 16/16;
- Weapons 594/594, 0 FAIL;
- abrir Items e Weapons e comparar visualmente com a entrega anterior;
- nenhum erro de config/HPP;
- wheel/slider/focused refresh sem regressão.


## 06/10/2026 — UICommon 0.2-D R2 visual polish candidata

R1 runtime-green: 31/31 + 16/16 + Weapons 594/594.

R2:
- build `0.2.0.4-shared-visual-polish-d2`;
- buscas compactas com lupa/X internos;
- superfícies/botões/barras suavizados sem decoração por linha virtualizada;
- MEUS KITS visualmente convergente;
- Items `ITENS DO KIT` + `Visualizar:`;
- footer Items/Weapons alinhado no span completo;
- zero mudança nos eventos dos dialogs contra R1;
- Items DnD mantém hit-test original com visual layer separado.

Gate real: 35/35 + 16/16 + 594/594 0 FAIL + smoke visual/DnD.


## 06/10/2026 — UICommon 0.2-D R3 candidata

R2: funcional 35/35 + 16/16 + Weapons 594/594, porém visual gate de cantos reprovado.

R3:
- build `0.2.0.5-true-rounded-responsive-d3`;
- rounded rect real = 4 círculos alpha + 2 fills;
- painéis/footer/action buttons;
- zero decoração por linha virtualizada;
- acessórios Weapons menores;
- títulos padronizados;
- lower cards P2/P3/P4 alinhados;
- Histórico com contraste recuperado;
- busca na linha do título somente em aspect >=2.0;
- fallback STANDARD preserva layout de duas linhas;
- RPT registra resolução/profile;
- eventos Items 51/51 e Weapons 47/47 idênticos à R2.

Gate: 39/39 + 16/16 + 594/594 0 FAIL + avaliação visual ultrawide e resolução padrão.


## 06/10/2026 — UICommon 0.2-D R4

R3 rejeitada apesar de 39/39 + 16/16 + 594/594: a tentativa de rounded geometry degradou a interface e o responsive Weapons tinha erro por macro não preprocessada.

R4 restaura integralmente o baseline visual/controles da R2 e reaplica somente:
- search-on-title WIDE + fallback STANDARD;
- títulos/acessórios/lower cards Weapons;
- contraste do Histórico.

Rounded panels/buttons foram abandonados nesta fase.
Gate: 36/36 + 16/16 + 594/594, 0 FAIL, sem erro SQF responsive.
