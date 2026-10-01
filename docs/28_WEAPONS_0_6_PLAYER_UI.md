# Weapons 0.6 — Player UI / Kit Builder

## Estado atual

**0.6-A R4 — 362/362. 0.6-B R4 — 397/397. 0.6-C R1 — 445/445. 0.6-D R1 — 471/471 HOMOLOGADA. 0.6-D R2 — 500/500 AUTO, MAS GATE MANUAL DE PERFORMANCE REPROVADO. 0.6-D R3 — FOCUSED REFRESH / HEADER POLISH CANDIDATA ATIVA; STATIC 272/272; RUNTIME PROJETADO 512.**

Baseline anterior:
- 0.4 R5 WeaponRecipe: **251/251**;
- 0.5 WeaponKit: **301/301**;
- 0.6-A R4 runtime: **362/362 PASS / 0 FAIL**;
- refresh reentrante corrigido;
- catálogo completo permanece cacheado/pesquisável;
- projeção visual limitada a 250 linhas;
- gate visual aceito como base para continuar a implementação.

O source integrado do addon continua em 0.1-A. Esta linha permanece mission-first e não representa Packaging/PBO.

## Decisão de processo

A partir da R4, **não vamos continuar polindo o layout durante cada subentrega funcional**.

Sequência decidida:

```text
0.6-A  Shell/layout/listas/filtros                 FROZEN BASELINE 362/362
0.6-B  Seleção de arma + informações              APPROVED R4 397/397
0.6-C  Dropdowns de compatibilidade                APPROVED R1 445/445
0.6-D  Rascunho de WeaponKit                       R1 APPROVED 471/471; R2 AUTO 500/500 / PERF REJECTED; R3 ACTIVE — FOCUSED REFRESH / HEADER POLISH
0.6-E  Novo/Renomear/Duplicar/Excluir/Salvar
0.6-F  Adaptação visual final + foco + regressões
```

Regra revisada após o gate 0.6-D R1:
1. a lógica de draft da R1 está homologada e deve ser preservada;
2. antes de 0.6-E, executar uma **rodada deliberada de convergência estrutural R2** porque o usuário aprovou quatro painéis e alinhamento com Items/APM;
3. 0.6-E continua responsável por authoring/lifecycle persistente;
4. 0.6-F permanece o polish/regressão final após conteúdo funcional.

Isso evita retrabalho visual enquanto os controles ainda estão ganhando comportamento.

## Nomenclatura player-facing

Modelo interno permanece:

```text
PRIMARY
HANDGUN
SECONDARY
```

UI:

```text
Principal  -> PRIMARY
Porte      -> HANDGUN
Secundária -> SECONDARY / lançador
Todos      -> filtro de apresentação, não targetSlot
```

## Layout congelado como baseline

```text
┌──────────────────────┬────────────────────────────────┬───────────────────────────┐
│ MEUS KITS            │ KIT SELECIONADO                │ CATÁLOGO DE ARMAS         │
│                      │                                │                           │
│ Buscar               │ Nome / Tipo                    │ Buscar                    │
│                      │                                │                           │
│ Todos                │ imagem nativa da arma          │ Todos                     │
│ Principal            │                                │ Principal                 │
│ Porte                │ Arma       [ ... ▼ ]           │ Porte                     │
│ Secundária           │ Mira       [ ... ▼ ]           │ Secundária                │
│                      │ Boca       [ ... ▼ ]           │                           │
│ lista de kits        │ Pointer    [ ... ▼ ]           │ lista de armas            │
│                      │ Bipé       [ ... ▼ ]           │                           │
│                      │ Carregador [ ... ▼ ]           │                           │
│                      │                                │                           │
│ Novo/Renomear/       │ Descartar/Salvar/              │                           │
│ Duplicar/Excluir     │ Salvar como novo               │                           │
├──────────────────────┴────────────────────────────────┴───────────────────────────┤
│ Context                                                                            │
│ Message                                                                            │
│ History                                                                            │
└───────────────────────────────────────────────────────────────────────────────────┘
```

## Gramática compartilhada com Items

Manter:
- `RobotoCondensed`;
- dimensões por `safeZoneW/safeZoneH`;
- pixel-aspect para controles quadrados;
- busca com lupa;
- botão limpar;
- tooltips;
- mesma escala de fontes e botões;
- transparência atual;
- ações dentro do painel proprietário;
- rodapé semântico `Context / Message / History`;
- mesma estrutura em 1080p e telas maiores.

### Decisões explícitas de freeze

A antiga regra de não alterar opacidade/três painéis foi **superada pela decisão explícita da 0.6-D R2**. A R2 pode alterar estrutura/opacidade somente para convergir com Items Multiplayer Lab R3 e recuperar o painel de equipamento do APM, sem mudar gates de domínio.

O painel **KIT SELECIONADO** ainda possui bastante espaço vazio. Isso é aceito temporariamente porque as próximas subentregas vão inserir informações e comportamento reais. A composição vertical será reavaliada somente na fase final de adaptação visual.

## MEUS KITS

Filtros privados:

```text
Todos | Principal | Porte | Secundária
```

`Todos` mostra todos os WeaponKits privados/session-local do jogador.

`Públicos` não é tipo de arma. É uma futura origem/biblioteca e permanece separada e desabilitada até existir backend real.

Ações permanecem dentro do painel:
- Novo;
- Renomear;
- Duplicar;
- Excluir.

## KIT SELECIONADO

É o editor do WeaponKit.

Não existe painel separado de acessórios compatíveis.

Campos:
- Arma;
- Mira;
- Boca;
- Pointer;
- Bipé;
- Carregador.

As opções compatíveis serão apresentadas nos próprios seletores/dropdowns.

Ações:
- Descartar;
- Salvar;
- Salvar como novo.

## CATÁLOGO DE ARMAS

Filtros:

```text
Todos | Principal | Porte | Secundária
```

Busca textual e filtro de tipo são combináveis.

O catálogo usa a baseline homologada da 0.3:
- base real: 2770 armas;
- categorias: PRIMARY/HANDGUN/SECONDARY;
- conteúdo vanilla e modded;
- provenance preservada.

A UI renderiza no máximo 250 resultados por refresh, mantendo o catálogo completo cacheado e pesquisável.

## Rodapé — decisão atual e melhoria futura compartilhada

Hoje Items e Weapons usam uma única superfície de fundo com três linhas semânticas:

```text
Context
Message
History
```

**Não alterar durante 0.6-B até 0.6-E.**

Foi registrada uma melhoria visual futura:

> separar visualmente o rodapé em três faixas distintas — Context, Message e History — mantendo exatamente a mesma semântica.

Essa mudança **não deve ser feita somente em Weapons**. Deve ser aplicada de forma coordenada em:
- Items;
- Weapons.

Motivo: preservar a gramática visual compartilhada do SP_ORG.

Referência oficial: `docs/29_SHARED_UI_ITEMS_WEAPONS.md`.

## Fronteiras da 0.6

A 0.6 não deve:
- alterar uniforme/colete/mochila;
- equipar a arma no jogador;
- substituir slot físico;
- criar Preview 3D de bancada;
- implementar condição/manutenção;
- assumir autoridade multiplayer;
- criar biblioteca pública fictícia.

Aplicação real permanece em **0.7 — Slot-Safe Weapon Application**.

## Histórico 0.6-A

### R1 — REPROVADA
- funções UI não carregaram;
- causa: path incorreto no `CfgFunctions`.

### R2 — REPROVADA
- funções UI carregaram;
- dialog abriu;
- refresh entrou em ciclo por seleção programática/evento;
- catálogo integral também criava risco de custo excessivo.

### R3 — FUNCIONAL, 1 FALSO NEGATIVO
- refresh reentrante corrigido;
- projeção limitada a 250;
- runtime: **345/346**;
- única falha: teste verificava `findDisplay` antes do `onUnload`.

### R4 — BASELINE CONGELADA
- fechamento aguardando frame do `onUnload`;
- filtros Todos/Principal/Porte/Secundária em Meus Kits;
- mesmos filtros no Catálogo;
- busca + filtro combináveis;
- runtime: **362/362 PASS / 0 FAIL**;
- shell visual aceito como base de continuidade.

## 0.6-B — Seleção de arma + informações — HOMOLOGADA R4

Final mission-first:

`0.6.1.4-initial-sync-handshake-test-timing-mission-first`

Runtime final: **397/397 PASS / 0 FAIL**.

### Contrato funcional congelado

Seleção é contexto de **leitura**, não edição.

Ao selecionar uma arma no Catálogo:
- resolve `weaponClass`;
- mostra `displayName`;
- mostra tipo player-facing;
- usa `picture` nativo do config;
- apresenta origem/mod/addon;
- apresenta `baseWeapon`;
- apresenta descrição curta quando disponível;
- pode indicar preset/variant;
- não consulta compatibilidade ainda;
- não cria draft;
- não altera WeaponKit;
- não altera loadout.

Ao selecionar um WeaponKit:
- a mesma camada básica de informação é derivada da arma contida em sua Recipe;
- o kit salvo continua sendo a fonte do painel quando o foco retorna a MEUS KITS.

### Abertura de MEUS KITS

Toda nova abertura da interface inicia deterministicamente com:

```text
kitTypeFilter = ALL
kitQuery      = ""
lastFocus     = KITS
```

Regras homologadas:
- **TODOS** é o filtro inicial;
- todos os kits privados/session-local disponíveis aparecem sem exigir clique;
- número de linhas visíveis deve corresponder ao repository na abertura canônica;
- primeiro kit é selecionado quando houver kits;
- um handshake explícito marca a sincronização inicial concluída;
- o recovery refresh só ocorre se a abertura ainda estiver na projeção canônica;
- a sincronização atrasada não deve sobrescrever filtro escolhido pelo jogador após interação.

### Histórico da 0.6-B

#### R1 — funcional verde, higiene rejeitada
- runtime **392/392**;
- `Selection & Information` gerava milhares de `Unknown entity: ' Information'`;
- causa: `&` em texto player-facing interpretado pelo Arma.

#### R2 — higiene corrigida
- runtime **392/392**;
- warning de structured text removido;
- manual revelou que MEUS KITS podia abrir vazio até clicar em um filtro.

#### R3 — comportamento manual corrigido, race de teste
- abertura em TODOS corrigida;
- usuário confirmou MEUS KITS abrindo corretamente;
- AUTO: **391/396**;
- teste lia `rows=0` enquanto a sincronização ainda estava rodando;
- logo depois o runtime registrava `rows=3 success=true`.

#### R4 — final homologada
- handshake `initialSyncComplete`;
- teste aguarda o refresh inicial realmente concluir, em vez de usar sleep fixo;
- gate inicial confirmou `rows=3 expectedRows=3 selected=0`;
- prévia do catálogo voltou a passar;
- zero mutação de WeaponKit/loadout;
- runtime: **397/397 PASS / 0 FAIL**.

### 0.6-C — Compatibility Selectors — HOMOLOGADA R1

Implementar **Compatibility Selectors** dentro de KIT SELECIONADO, sem criar painel separado.

Escopo planejado:
- Mira;
- Boca;
- Pointer;
- Bipé;
- Carregador;
- somente opções compatíveis com a arma em contexto;
- usar a engine de compatibilidade já homologada em 0.3;
- preservar modo read-only/sem draft até 0.6-D onde aplicável;
- nenhuma aplicação física da arma, que permanece em 0.7.

Não abrir nova rodada de polimento visual antes de concluir as funcionalidades planejadas da 0.6.


## 0.6-C — Compatibility Selectors — HOMOLOGADA R1

Build mission-first:

`0.6.2.1-compatibility-selectors-read-only-mission-first`

Estado: **HOMOLOGADA MISSION-FIRST / 445/445 PASS / 0 FAIL**.

Validação estática da candidata original: **335/335 PASS / 0 FAIL**. Runtime homologado no Arma: **445/445 PASS / 0 FAIL**. A sessão manteve refreshes repetidos sem recursão ou mutação de WeaponKit/loadout.

Delta funcional:
- os controles existentes de Mira, Boca, Pointer, Bipé e Carregador passam a ser dropdowns;
- as opções são derivadas exclusivamente de `getWeaponCompatibility`, a engine homologada na 0.3;
- a geometria da 0.6-A R4 permanece congelada;
- o valor atualmente salvo no WeaponRecipe permanece selecionado;
- os seletores são **read-only** nesta etapa;
- escolher outra opção serve somente para consultar compatibilidade e a UI restaura o valor salvo;
- nenhum draft é criado;
- nenhum WeaponKit é alterado;
- nenhum loadout é alterado.

Gates preservados:
- draft: **0.6-D**;
- authoring/lifecycle: **0.6-E**;
- polish final: **0.6-F**;
- aplicação física slot-safe: **0.7**;
- multiplayer/authority: **0.8**.

Gate fechado em 01/10/2026 pelo RPT real. O bloco recorrente de erro `CBA_fnc_addPerFrameHandler` já existia em entregas anteriores e não é chamado pelo source SP_ORG desta linha.


## 0.6-D R1 — candidata original (histórico)

Build mission-first:

`0.6.3.1-weaponkit-draft-local-mission-first`

Estado histórico naquele momento: **CANDIDATA / NÃO HOMOLOGADA EM RUNTIME**. O gate foi posteriormente fechado em 471/471, conforme a seção seguinte.

Validação estática: **260/260 PASS / 0 FAIL**. Runner: **444 pontos de asserção no source**; execução esperada no Arma quando todos os pré-requisitos passam: **471 checks**.

### Contrato funcional da candidata

A 0.6-D introduz um **rascunho local/session-local por WeaponKit**, sem escrever no repository 0.5 e sem alterar o loadout físico.

Campos editáveis no draft:
- Mira / `optic`;
- Boca / `muzzle`;
- Pointer / `pointer`;
- Bipé / `bipod`;
- Carregador / `magazineClass`.

Regras:
- opções continuam vindo exclusivamente da engine de compatibilidade homologada em 0.3;
- a arma-base não é trocada nesta entrega;
- alteração compatível fica persistida no draft durante a sessão;
- status `SALVO` = draft igual ao Recipe salvo;
- status `ALTERADO` = draft diferente;
- `DESCARTAR` restaura o snapshot do WeaponKit salvo;
- refresh, mudança de foco e fechamento/reabertura da UI não devem apagar o draft silenciosamente;
- `SALVAR`, `SALVAR COMO NOVO`, `NOVO`, `RENOMEAR`, `DUPLICAR` e `EXCLUIR` continuam deferred para **0.6-E**;
- nenhuma aplicação física; permanece em **0.7**;
- nenhum multiplayer/authority; permanece em **0.8**;
- geometria da 0.6-A R4 permanece congelada.

Regra histórica satisfeita: R1 foi homologada em 471/471.


## 0.6-D R1 — HOMOLOGADA

Build: `0.6.3.1-weaponkit-draft-local-mission-first`.

Runtime real: **471/471 PASS / 0 FAIL**.

Homologado:
- draft session-local por `kitId`;
- Mira/Boca/Pointer/Bipé/Carregador editam apenas o draft;
- estado SALVO/ALTERADO;
- DESCARTAR restaura o snapshot salvo;
- refresh/foco preservam o draft;
- repository e loadout permanecem imutáveis;
- authoring continua 0.6-E;
- aplicação continua 0.7.

## 0.6-D R2 — UI Convergence / Equipment Content — AUTO VERDE / GATE MANUAL DE PERFORMANCE REPROVADO

Build: `0.6.3.2-ui-convergence-equipment-content-mission-first`.

Static: **232/232 PASS**. Runner: **473 source assertions**. Runtime real: **500/500 PASS / 0 FAIL**.

Esta rodada é uma exceção deliberada ao freeze visual antigo: reorganiza a interface **antes** de 0.6-E para evitar construir authoring sobre uma composição que já sabemos que será substituída.

### Layout

Quatro painéis, usando a transparência e a grade do Items Multiplayer Lab R3:
1. **MEUS KITS DE ARMAS**;
2. **KIT SELECIONADO / RASCUNHO**;
3. **CATÁLOGO DE ARMAS**;
4. **CONTEÚDO DO EQUIPAMENTO**.

### Catálogo

Mantém filtro por Tipo e adiciona filtro player-facing:
`Todos | Arma | Óticas | Apontadores | Bipés | Carregadores | Empunhaduras`.

Catálogo passa a usar janela virtualizada de **32 linhas**, wheel + scrollbar visível no padrão Items. Busca/filtro resetam offset para o topo.

A compatibilidade continua exclusivamente engine-derived pela 0.3. Empunhaduras é somente uma classificação de apresentação de opções compatíveis do UnderBarrelSlot que não são identificadas como bipé; não cria compatibilidade nova.

`muzzle/Boca` continua no draft, mas não ganhou categoria de catálogo nesta rodada porque a lista acordada não inclui Boca.

### Conteúdo do Equipamento

Read-only por slot:
- Principal;
- Porte;
- Secundária.

Mostra arma realmente equipada e Mira/Boca/Apontador/Bipé/Carregador observados. Nenhuma ação física existe neste painel na R2.

### Shared UI

A R2 inaugura o `UI_CONVERGENCE_BACKLOG` em `docs/29_SHARED_UI_ITEMS_WEAPONS.md`.

Padrões aprovados/contemplados:
- transparência do Items;
- quatro painéis;
- scrollbar contínua;
- `KIT SELECIONADO / RASCUNHO`;
- SALVO/ALTERADO como candidato shared;
- rodapé em três faixas Contexto/Resultado/Histórico como candidato shared.

### Resultado do gate R2

O AUTO TEST fechou **500/500**, mas o gate manual detectou stuttering no wheel/slider do catálogo. O RPT mostrou que cada deslocamento ainda executava o refresh completo da UI; passos comuns consumiram aproximadamente **246–254 ms**. Portanto, R2 **não é homologada como baseline de continuidade**, apesar de funcionalmente verde.

A causa arquitetural é conhecida: interação local estava acionando reconstrução ampla, reavaliando kits/draft/equipamento e projeção do catálogo sem necessidade.

**Correção obrigatória antes de 0.6-E: 0.6-D R3.**


## 0.6-D R3 — Focused Refresh / Header Polish — CANDIDATA ATIVA

Build: `0.6.3.3-focused-refresh-header-polish-mission-first`.

Validação local:
- static: **272/272 PASS / 0 FAIL**;
- runner source: **485 assertions**;
- runtime projetado: **512 checks**;
- runtime Arma: **PENDENTE**. O RPT real é a autoridade.

### Objetivo

Preservar integralmente:
- draft homologado da R1;
- quatro painéis/transparência/filtros/equipment read-only da R2;

e remover reconstruções globais de UI durante interações locais.

### Refresh focal

`CATALOG_FOCUSED`:
- wheel;
- slider;
- busca;
- filtro Tipo;
- filtro Acessório;
- seleção de linha.

`DRAFT_FOCUSED`:
- Mira;
- Boca;
- Apontador;
- Bipé;
- Carregador;
- DESCARTAR.

`EQUIPMENT_FOCUSED`:
- Principal;
- Porte;
- Secundária no painel Conteúdo do Equipamento.

`FULL` permanece somente quando o contexto amplo realmente muda, por exemplo troca do WeaponKit.

### Cache da projeção do catálogo

- catálogo-base 0.3 é convertido para rows da UI uma vez por sessão/build;
- projeção arma + acessórios é cacheada por `kitId/weaponClass`;
- índice filtrado é cacheado por `Tipo/Categoria/Busca`;
- wheel/slider comuns apenas recortam a janela de 32 rows;
- com a mesma projeção, scroll não relê repository/draft para descobrir a arma-base;
- nenhum reverse scan global foi reintroduzido.

### Header

Recupera o padrão provado no APM/Items: composição da direita para a esquerda usando o X como âncora.

```text
título <- contexto <- Operador/Unidade <- reserva futura <- X
```

O título ocupa apenas o espaço restante. Weapons não copia métricas de peso/capacidade do Items porque essas métricas pertencem ao domínio Items.

### Feedback de catalogação

Durante uma construção real do catálogo, Weapons mostra:

`Vasculhando inventário e catalogando armas...`

O padrão correspondente para Items foi registrado no backlog compartilhado:

`Vasculhando inventário e catalogando itens...`

### Gate R3

Aprovação exige:
- AUTO runtime verde;
- wheel e slider sem o stuttering perceptível da R2;
- logs `[UI_PERF] mode=CATALOG_FOCUSED ... fullRefresh=false`;
- scroll repetido reutilizando projeção/filtro;
- draft/equipment usando seus refreshes focais;
- header sem sobreposição em resolução real;
- nenhum repository/loadout mutation.

**0.6-E continua bloqueada até RPT + avaliação manual da R3.**
