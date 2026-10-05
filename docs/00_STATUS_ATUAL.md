# Estado atual do projeto

Data do snapshot: **01/10/2026**.

## Source of Truth

Repositório oficial: `peregrinoklawd/ServoPeregrino_Organizador`.

O projeto agora é tratado como **monorepo multi-PBO**, com ownership funcional único por módulo.

## Runtime atual implementado

| Componente | Estado |
|---|---|
| Nexus | display 1.1 / semantic 0.1.1 / build `0.1.1-dev-nexus-contract-event-foundation` |
| Items | display 0.13-A / semantic 0.13.0.1 / build `0.13.0.1-a-server-authority-foundation` |
| Baseline funcional congelada | **0.12 FINAL — Integration Freeze**, homologada manualmente |
| Lógica atual Items | **0.13-A — Server Authority Foundation** |
| Addon atual | **Packaging R2**, candidato pendente de validação runtime |
| Missão MP | **8 Slots R3**; lobby/slots já funcionaram |

## Arquitetura global decidida

Módulos atuais/planejados:
- Nexus;
- Hub;
- Items;
- Weapons;
- WeaponCondition;
- Armorer;
- Equipment;
- Sets;
- Policy;
- ServerIntegration;
- Settings;
- Adapters.

Regra oficial: **uma funcionalidade de domínio possui um único módulo proprietário**.

Divisão de armas:
- **Weapons** = identidade, serial, configuração, compatibilidade, receitas, WeaponKit, UI própria de organização/configuração e aplicação slot-safe;
- **WeaponCondition** = uso, desgaste, água/submersão, condição de peças, confiabilidade e manutenção lógica;
- **Armorer** = bancada especializada, Preview 3D, montagem física/visual, inspeção de peças e workflow/UI de manutenção.

## O que aconteceu na migração para addon Items

A missão multiplayer R2 corrigiu os slots e foi carregada corretamente. A R3 acrescentou entrada direta pela ação `addAction` e fallback HOME. No teste R3, a missão rodou, mas `openInterface` permaneceu `nil` porque o Arma registrou `Unable to open` para os PBOs antigos do Nexus e Items. O problema foi isolado como **empacotamento do addon**, não como lógica da missão, slots ou UI.

O **Packaging R2** reempacota os mesmos fontes sem alterar SQF funcional. Ele ainda precisa ser executado no Arma para fechar o gate.

## Próximo teste obrigatório

1. carregar somente `@SP_ORG_Items_0_13_A_R2`;
2. hospedar a missão `SP_ORG_Items_0_13_A_Multiplayer_Lab_8Slots_R3.VR`;
3. confirmar no RPT que NÃO existe `Unable to open ...servoperegrino_organizador_*.pbo`;
4. confirmar que `ServoPeregrino_Organizador_Items_fnc_openInterface` existe;
5. abrir pelo HOME ou ação de scroll;
6. realizar smoke multiplayer: cliente publica, servidor comita, demais clientes enxergam a mesma revisão.

## O que ainda NÃO pode ser afirmado

- Packaging R2 ainda não foi homologado dentro do Arma.
- 0.13-A ainda não foi homologada em multiplayer real com dois ou mais clientes.
- JIP/persistência pública/ACL/rate limit/recovery ainda pertencem ao roadmap 0.13-B+.
- Hub, WeaponCondition, Equipment, Sets, Policy e ServerIntegration ainda são módulos planejados.
- Weapons: source integrado permanece 0.1-A; mission-first 0.1-B (128/128 + 3/3), 0.2 (175/175) e 0.3 R2 Catalog/Compatibility (213/213) estão homologadas em SP; 0.4 R5 WeaponRecipe está homologada em SP com 251/251; 0.5 WeaponKit está homologada com **301/301** e 50/50 gates específicos da camada de kit. Weapons terá UI própria player-facing; identidade física intrínseca, MP/JIP e PBO/addon integrado continuam não validados.
- Armorer possui base histórica madura, mas o runtime autoritativo ainda não foi importado ao monorepo.

## Dívida automática aceita

Os gates históricos **516 e 523** podem falhar no runner de 0.12-C.6 apesar do DnD real ter sido aprovado manualmente. Essa dívida foi aceita no freeze 0.12 FINAL. Não alterar runtime funcional apenas para “deixar verde” esses gates sem regressão humana reproduzível.

## Continuidade

Ler obrigatoriamente:
- `machine/PROJECT_STATE.json`;
- `machine/MODULE_MATRIX.json`;
- `machine/FEATURE_OWNERSHIP.json`;
- `docs/16_BANCO_DE_IDEIAS_E_CONCEITOS.md`;
- `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`;
- `docs/19_VISAO_FUNCIONAL_COMPARTILHAVEL.md`;
- `docs/20_HUB_ARQUITETURA_E_INTEGRACAO.md`.

## Frente independente — Weapons

**Source integrado na branch:** 0.1-A. **0.6-D R3:** 512/512 HOMOLOGADA. **0.6-E R1:** 536/536 AUTO, funcionalmente verde, mas superada pelo gate manual de UX. **Candidata ativa:** 0.6-E R2 — UX Convergence / Direct Draft Equip, static **296/296**, runner source **518**, runtime projetado ~**545**.

### 0.1-B — lifecycle/identity evidence

- AUTO TEST final: **128/128 PASS**.
- Gate manual real Take/Put: **3/3 PASS**.
- `TAKE 1→0` e `PUT 0→1`: `CORRELATED/1`.
- `TAKE 2→1` com duas MX idênticas: `AMBIGUOUS/2`, `instanceId=""`.
- `physicalIdentityProven=false`: preservado como invariante.
- Decisão: event-delta é evidência de continuidade lógica quando única; não é serial físico nativo.

### 0.2 — WeaponConfiguration

- AUTO TEST final R3: **175/175 PASS**.
- Schema candidato: `weaponClass`, `muzzle`, `pointer`, `optic`, `bipod`.
- Magazine/ammo continuam em `loadedState` separado e fora do fingerprint.
- Diff e apply com verificação de round-trip no engine.
- PRIMARY preservou 17 tiros durante aplicação/remoção de attachments.
- HANDGUN preservou 11 tiros.
- SECONDARY/NLAW validado via classe realmente observada pelo engine.
- No-op retorna sem mutar o inventário.
- Attachment inválido e weaponClass incompatível falham antes de mutação.

### 0.3 — Catalog & Compatibility

- Candidata final R2: **213/213 PASS**.
- Catálogo-base validado no modset real: **2770** armas (2406 PRIMARY, 279 HANDGUN, 85 SECONDARY).
- Catálogo com presets: **3380**.
- 610 presets excluídos do catálogo-base.
- Compatibilidade de optic/muzzle/pointer/bipod/magazines derivada do engine.
- Conteúdo modded/provenance confirmado.
- Cache de sessão confirmado.
- Reverse lookup global por `compatibleWeapons` foi deliberadamente retirado do gate por produzir varredura ampla e warnings de configs de terceiros; qualquer índice reverso futuro será derivado do catálogo filtrado SP_ORG.

### 0.4 — WeaponRecipe

- R3 runtime: **245/245 PASS / 0 FAIL**.
- Recipe permanece descritivo: nenhuma mutação de inventário.
- Schema candidato: `configuration` + `magazineClass` opcional.
- `targetSlot`, nome de kit, identidade/serial e ammoCount continuam fora de Recipe.
- PRIMARY, HANDGUN e SECONDARY validados.
- Compatibilidade SECONDARY passou a resolver genericamente variantes runtime ligadas por `baseWeapon`.
- No ambiente ACE/NLAW, foram observadas `launch_NLAW_F` e `ACE_launch_NLAW_ready_F` como variantes relacionadas, sem hardcode no resolver.
- R3 revelou apenas dívida de higiene: lista de magazines continha `nlaw_f` e `NLAW_F`, semanticamente a mesma classe.
- R4 higiene: PASS; runtime geral **245/246** por uma única regressão antiga no SECONDARY no-op apply.
- R5 final: **251/251 PASS / 0 FAIL**.
- PRIMARY/HANDGUN permanecem estritos.
- SECONDARY permite equivalência apenas entre classes `type=4` da mesma família `baseWeapon`.
- O RPT provou a transição real `launch_NLAW_F -> ACE_launch_NLAW_ready_F` entre capture/apply sem mutação indevida.
- Higiene R4 preservada: `NLAW_F` aparece uma única vez.
- WeaponRecipe/schema permanecem inalterados.
- **MISSION-FIRST FUNCTIONAL GATE: HOMOLOGADO.**

### 0.5 — WeaponKit

- static validation: **131/131 PASS**;
- runtime final: **301/301 PASS / 0 FAIL**;
- **50/50 gates específicos de WeaponKit aprovados**;
- schema: `kitId`, `name`, `targetSlot`, `recipe`;
- repository mode: `SESSION_LOCAL_CANDIDATE`;
- PRIMARY/HANDGUN/SECONDARY aprovados;
- create/get/list/rename/duplicate/update Recipe/delete aprovados;
- nomes únicos case-insensitively;
- defensive copies aprovadas;
- content fingerprint exclui kitId/nome;
- Recipe/targetSlot incompatível é rejeitado;
- nenhuma operação 0.5 altera o loadout;
- UI permanece em 0.6;
- aplicação/equipar permanece em 0.7;
- autoridade multiplayer permanece em 0.8;
- **MISSION-FIRST FUNCTIONAL GATE: HOMOLOGADO.**

### 0.6-A — Player UI Shell

**R4 — BASELINE VISUAL/ESTRUTURAL CONGELADA.**

- runtime final: **362/362 PASS / 0 FAIL**;
- R1 reprovada por path incorreto em CfgFunctions;
- R2 reprovada por refresh reentrante;
- R3 corrigiu travamento e ficou 345/346 por falso negativo de timing no fechamento;
- R4 corrigiu o teste de onUnload e adicionou filtros completos;
- painéis: **MEUS KITS | KIT SELECIONADO | CATÁLOGO DE ARMAS**;
- nomenclatura UI: **Principal -> PRIMARY**, **Porte -> HANDGUN**, **Secundária -> SECONDARY/lançador**;
- filtros Meus Kits: **Todos / Principal / Porte / Secundária**;
- filtros Catálogo: **Todos / Principal / Porte / Secundária**;
- busca textual e filtro de tipo podem ser combinados;
- Públicos permanece separado e desabilitado até existir provider real;
- catálogo completo permanece cacheado/pesquisável; projeção visual limitada a 250 linhas;
- escala de botões/textos, opacidade, safeZone e largura atual ficam congelados durante B–E;
- rodapé permanece semanticamente **Context / Message / History**;
- melhoria futura aprovada: separar visualmente o rodapé em três faixas, **aplicando a mesma alteração em Items e Weapons**;
- essa melhoria é deferred para a rodada final de UI, depois das funcionalidades;
- o espaço vertical de KIT SELECIONADO será reavaliado somente quando os controles reais estiverem implementados;
- 0.6-A não edita Recipe/WeaponKit e não altera loadout;
- aplicação/equipar continua exclusivamente no gate 0.7.

### 0.6-B — Selection + Information

**R4 — MISSION-FIRST HOMOLOGADA / FROZEN.**

- R1: **392/392 PASS**, mas rejeitada por higiene de texto; o rótulo `Selection & Information` gerava milhares de warnings `Unknown entity: ' Information'`;
- R2: **392/392 PASS**, higiene corrigida; teste manual revelou que MEUS KITS podia abrir visualmente vazio até o primeiro clique em filtro;
- R3: comportamento de abertura corrigido manualmente; AUTO ficou **391/396** por race de timing entre teste e sincronização inicial;
- R4: handshake explícito de sincronização inicial; **397/397 PASS / 0 FAIL**;
- `MEUS KITS` abre deterministicamente em **TODOS/ALL**, com busca vazia;
- linhas visíveis são sincronizadas com o repository e o primeiro kit é selecionado quando existe;
- seleção de arma no Catálogo é contexto read-only;
- seleção de WeaponKit é contexto read-only;
- apresentação básica inclui nome, tipo, classe, imagem nativa, origem/mod/addon, `baseWeapon` e descrição;
- prévia do catálogo não inventa acessórios/compatibilidade;
- nenhuma consulta de compatibilidade na UI ainda;
- nenhum draft;
- nenhum authoring;
- nenhuma mutação de WeaponKit;
- nenhuma mutação de loadout;
- geometria da 0.6-A R4 preservada;
- **MISSION-FIRST FUNCTIONAL GATE: HOMOLOGADO.**

### Decisão conceitual — Weapons é player-facing

Weapons possui UI própria, semelhante em conceito à parte de armas do APM histórico:

- escolher arma;
- consultar informações;
- escolher somente acessórios compatíveis;
- montar/salvar/editar WeaponKit;
- equipar apenas o slot alvo;
- preservar todo o restante do loadout.

**WeaponKit = uma arma configurada para um único slot**, não um loadout completo.

Armorer continua separado: bancada, Preview 3D avançado, peças, inspeção e manutenção.

**Gate mission-first ativo:** **0.6-F R1 — Final Visual Adaptation / Regression**. A R2 HF1 fechou 557/558; o único FAIL de cancelamento de NOVO foi incorporado à 0.6-F, que congela a UI final da linha 0.6 antes da aplicação física 0.7.

**Gates ainda abertos:** homologação runtime/manual/performance da 0.6-F R1, aplicação slot-safe 0.7, multiplayer/JIP/reconnect 0.8, identidade física intrínseca, integração real ao addon/PBO e Packaging Gate. O backlog compartilhado Items+Weapons está em `29_SHARED_UI_ITEMS_WEAPONS.md`.

Ver [0.1-A](21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md), [0.1-B](22_WEAPONS_0_1_B_IDENTITY_LIFECYCLE.md), [0.2](23_WEAPONS_0_2_WEAPON_CONFIGURATION.md), [0.3](24_WEAPONS_0_3_CATALOG_COMPATIBILITY.md) e [conceito UI](25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md) e [0.4](26_WEAPONS_0_4_WEAPON_RECIPE.md) e [0.5](27_WEAPONS_0_5_WEAPON_KIT.md).


### 0.6-C — Compatibility Selectors — HOMOLOGADA R1

- build: `0.6.2.1-compatibility-selectors-read-only-mission-first`;
- static validation: **335/335 PASS / 0 FAIL**;
- runtime Arma: **445/445 PASS / 0 FAIL**;
- AUTO TEST real: **445 checks**;
- Mira/Boca/Pointer/Bipé/Carregador usam a compatibilidade engine-derived homologada na 0.3;
- seletores permanecem read-only; escolha alternativa é apenas consulta;
- nenhum draft, nenhuma mutação de WeaponKit e nenhuma mutação de loadout;
- geometria da 0.6-A R4 preservada;
- 0.6-D/0.6-E/0.7/0.8 continuam separados.

**Gate 0.6-C fechado.** O RPT real confirmou os seletores, ausência de mutação de WeaponKit/loadout e estabilidade do refresh. Erros recorrentes de CBA PFH já existiam antes desta entrega e não são chamados pelo source SP_ORG.


### 0.6-D R1 — candidata original (histórico)

- build: `0.6.3.1-weaponkit-draft-local-mission-first`;
- static validation: **260/260 PASS / 0 FAIL**;
- runner source: **444 assertions**;
- runtime esperado: **471 checks**;
- runtime Arma: **PENDENTE**;
- draft local por `kitId`, derivado do WeaponKit salvo;
- campos: optic/muzzle/pointer/bipod/magazineClass;
- somente opções compatíveis da engine 0.3 podem entrar no draft;
- status `SALVO` / `ALTERADO`;
- `DESCARTAR` restaura o snapshot salvo;
- draft deve sobreviver a refresh/foco/fechar-reabrir durante a sessão;
- repository 0.5 continua imutável;
- loadout físico continua imutável;
- troca da arma-base e authoring completo: **0.6-E**;
- aplicação física: **0.7**;
- MP/authority: **0.8**;
- geometria 0.6-A R4 preservada.

Regra histórica satisfeita: R1 foi homologada em 471/471.


### 0.6-D R1 — WeaponKit Draft — HOMOLOGADA

- runtime: **471/471 PASS / 0 FAIL**;
- draft local, SALVO/ALTERADO e DESCARTAR aprovados;
- nenhum repository/loadout mutation.

### 0.6-D R2 — UI Convergence / Equipment Content — AUTO 500/500 / MANUAL PERF REPROVADO

- build: `0.6.3.2-ui-convergence-equipment-content-mission-first`;
- static: **232/232**;
- runner source: **473 assertions**;
- runtime real: **500/500 PASS / 0 FAIL**;
- runtime Arma: **PENDENTE**;
- grid/transparência alinhados ao Items Multiplayer Lab R3;
- MEUS KITS DE ARMAS;
- KIT SELECIONADO / RASCUNHO;
- Catálogo com Tipo + Acessório e janela 32 + scrollbar/wheel;
- Conteúdo do Equipamento read-only por Principal/Porte/Secundária;
- authoring continua 0.6-E; aplicação 0.7; MP 0.8;
- convergência Items↔Weapons formalizada em `docs/29_SHARED_UI_ITEMS_WEAPONS.md`.

- gate manual: **REPROVADO por stuttering**; wheel/slider ainda disparavam full refresh com ~246–254 ms por passo no RPT real.

### 0.6-D R3 — Focused Refresh / Header Polish — histórico da candidata

- build: `0.6.3.3-focused-refresh-header-polish-mission-first`;
- static: **272/272**;
- runner source: **485 assertions**;
- runtime final: **512/512 PASS / 0 FAIL** após hotfix somente de teste;
- catálogo: refresh focal + projeção/filtros cacheados + janela 32;
- draft: refresh focal em seletores/Descartar;
- equipamento: refresh focal em Principal/Porte/Secundária;
- header: ancorado da direita a partir do X, seguindo a lição APM/Items;
- build do catálogo: mensagem `Vasculhando inventário e catalogando armas...`;
- equivalente Items `...catalogando itens...` registrado no backlog, ainda não implementado em Items;
- nenhuma mutação de repository/loadout;
- authoring continua 0.6-E; aplicação 0.7; MP 0.8.

Gate satisfeito posteriormente: R3 homologada 512/512 e performance manual aprovada.


### Resultado real R3 — performance corrigida / falso negativo de teste

RPT real:
- AUTO: **511/512**;
- único FAIL: `0.6-D UI state schema marker`;
- causa confirmada: `fn_createUIState` publica `0.6-D-r3-ui-state-candidate`, enquanto o runner R3 ainda esperava marcador R2/legado;
- nenhum defeito funcional associado ao FAIL;
- wheel manual: aproximadamente **5–7 ms** na maior parte da sequência;
- slider absoluto manual: aproximadamente **5–9 ms**;
- `projectionBuilt=false`, `filterBuilt=false` e `fullRefresh=false` durante scroll repetido;
- draft manual: **21 ms** nas seleções observadas;
- equipamento manual: **0–1 ms** nas trocas observadas;
- usuário reportou ausência perceptível do stuttering.

Decisão:
- performance da R3: **ACEITA**;
- R3 ainda não homologada formalmente enquanto o rerun do hotfix test-only não fechar **512/512**;
- nenhuma mudança funcional/UI no hotfix;
- bloqueio satisfeito posteriormente: hotfix test-only fechou 512/512.


### 0.6-D R3 — HOMOLOGADA

- build funcional: `0.6.3.3-focused-refresh-header-polish-mission-first`;
- hotfix final: somente expectativa do marcador de schema no runner;
- AUTO final: **512/512 PASS / 0 FAIL**;
- performance manual: aprovada;
- wheel/slider: ~**5–9 ms** sem full refresh;
- stuttering: não perceptível no gate manual;
- quatro painéis, filtros, draft e equipamento read-only preservados;
- header right-to-left ancorado no X aprovado;
- nenhuma mutação de repository/loadout fora das fronteiras planejadas.

**Próximo gate: 0.6-E — Authoring/Lifecycle.**


### 0.6-E R1 — Authoring/Lifecycle — AUTO VERDE / UX SUPERADA

Build: `0.6.4.1-authoring-lifecycle-session-local-mission-first`.

Validação local:
- static: **257/257 PASS / 0 FAIL**;
- runner source: **509 assertions explícitos**;
- runtime projetado: aproximadamente **536 checks** pela dinâmica observada na R3;
- runtime Arma: **PENDENTE**; o RPT é a autoridade.

Escopo:
- NOVO a partir de uma arma selecionada no Catálogo;
- RENOMEAR pelo campo inline do painel KIT SELECIONADO / RASCUNHO;
- DUPLICAR a partir do conteúdo **salvo**, sem copiar rascunho sujo;
- EXCLUIR imediatamente do repository da sessão;
- SALVAR persiste o Recipe do rascunho no WeaponKit atual;
- SALVAR COMO NOVO cria novo kit com nova identidade e o Recipe atual do draft;
- troca da arma-base no draft somente dentro do mesmo `targetSlot`;
- troca da arma-base reseta acessórios/carregador do draft para evitar configuração incompatível;
- nome digitado é preservado durante refresh focal do draft;
- nenhuma ação da 0.6-E equipa fisicamente a arma.

Fronteiras preservadas:
- repository: **SESSION_LOCAL_CANDIDATE**;
- aplicação física: **DEFERRED_0_7**;
- multiplayer authority/JIP/reconnect: **DEFERRED_0_8**;
- biblioteca pública real: futuro;
- addon/PBO: ainda não integrado.

**Resultado:** AUTO **536/536 PASS / 0 FAIL**. Gate manual de UX pediu reorganização do fluxo e da gramática visual; a continuidade foi movida para R2 sem descartar o authoring funcional.


### 0.6-E R2 — UX Convergence / Direct Draft Equip — CANDIDATA ATIVA

Build: `0.6.4.2-ux-convergence-direct-draft-equip-mission-first`.

Validação local:
- static: **296/296 PASS / 0 FAIL**;
- runner source: **518 assertions explícitos**;
- runtime projetado: ~**545**, pendente no Arma;
- verdade final: RPT.

Delta UX:
- P1: `NOVO | DUPLICAR | EXCLUIR | PUBLICAR`; RENOMEAR sai do P1;
- NOVO entra em estado pendente e **não cria kit inválido**;
- arma é escolhida depois no Catálogo e enviada ao rascunho por seta esquerda ou `EQUIPAR NO RASCUNHO`;
- nome inline no P2; SALVAR confirma nome + Recipe;
- busca em P2/P4 funciona como atalho sincronizado da busca do Catálogo nesta candidata;
- ações P2 no topo: SALVAR, SALVAR COMO NOVO, DESCARTAR, LIMPAR;
- DESCARTAR/LIMPAR usam affordance destrutiva;
- LIMPAR remove acessórios/carregador do draft e preserva a arma-base;
- Catálogo ganha ações por linha `← draft | conteúdo | → físico`;
- `BIPOD` + `GRIP` são apresentados em um único filtro `UNDERBARREL / BIPÉ-EMP.`;
- P4 usa `Visualizar:` e tabs na mesma linha;
- painéis P2/P3/P4 alinham os retângulos de informação;
- footer remove o grande background externo, preserva apenas três faixas e aumenta o contraste do Histórico.

Fronteira obrigatória:
- seta esquerda / `EQUIPAR NO RASCUNHO`: **funcional em 0.6-E R2**;
- seta direita para equipamento físico: **visível, mas não mutante; reservada para 0.7**;
- nenhuma ação 0.6-E pode alterar `getUnitLoadout player`.

**Não iniciar 0.6-F antes do RPT + gate manual da 0.6-E R2.**


## UICommon — foundation 0.1

Decisão registrada em 01/10/2026:
- nova frente: `feature/uicommon-0.1-foundation`;
- `UICommon.pbo` será addon técnico separado, distribuído junto do Nexus no pacote Core;
- dependência: UICommon -> Nexus; Items/Weapons -> Nexus + UICommon somente após seus gates de migração;
- Items e Weapons continuam independentes entre si;
- Items baseline PBO multiplayer é considerada HOMOLOGADA para o conjunto testado pelo usuário; Public Loadouts ficam PENDENTES de validação manual específica;
- Weapons 0.6-E R2 fica funcionalmente congelada enquanto a fundação UICommon é criada; seus requisitos de UX continuam obrigatórios;
- documentos autoritativos novos: `30_ITEMS_UI_REGRESSION_CONTRACT.md`, `31_UICOMMON_ARCHITECTURE_AND_MIGRATION.md`, `32_WEAPONS_0_6_E_R2_UI_FREEZE.md`.

Fundação criada sem alterar Items/Weapons:
- addon `ServoPeregrino_Organizador_UICommon`;
- lifecycle/build/runtime;
- capability `uicommon.runtime`;
- tokens visuais compartilhados;
- helpers puros iniciais de virtualização;
- suíte foundation inicial.

Próximo gate: validar UICommon isoladamente e então iniciar **Items + UICommon equivalence**, sem mudança deliberada de UX.


## Gate 2 — Items + UICommon Equivalence R1 — CANDIDATA

Data: 02/10/2026.

Hotfix 1 anterior:
- aceito para continuidade;
- UICommon 8/8;
- Items confirmou `ITEMS_TARGET_CAPACITY_INSUFFICIENT` com telemetria de capacidade;
- Weapons cold-open corrigido com `UI_INITIAL_SYNC_HOTFIX1 ok=true`;
- Weapons E R1 manteve 536/536.

Candidata atual:
- UICommon: `0.1.1-items-equivalence-r1`;
- Items: `0.13.0.1-a-server-authority-foundation-uicommon-equivalence-r1`;
- Weapons: E R1 congelada como baseline de comparação.

Primeiras primitivas compartilhadas:
- structured-text escaping;
- virtual offset clamp;
- virtual window helper já existente.

Items agora declara/valida UICommon e mantém wrappers de compatibilidade.

Esperado no runtime:
- UICommon: 12/12;
- Items + UICommon equivalence: 12/12;
- Weapons: 536/536;
- regressão manual conforme `30_ITEMS_UI_REGRESSION_CONTRACT.md`.

Mudanças visuais de Items, inclusive `Vasculhando inventário e catalogando itens...`, permanecem DEFERIDAS para a rodada explícita de convergência visual após equivalência.


## Atualização 03/10/2026 — Weapons 0.6-E R2 preparada

Gate Items + UICommon Equivalence R1:
- aprovado para Items;
- UICommon 12/12;
- Items+UICommon 12/12.

Candidata ativa:
**Weapons 0.6-E R2 + UICommon**

Build:
`0.6.4.2-ux-convergence-direct-draft-equip-uicommon-mission-first`

Validação estática:
- **75/75 PASS**;
- Nexus/UICommon/Items preservados byte a byte em relação à Equivalence R1;
- runner histórico E R1 preservado;
- runner R2 separado com 528 assertion sites.

Estado R2:
- mission-first pronta para teste;
- runtime/manual/performance ainda pendentes;
- nenhuma aplicação física de Weapons;
- nenhuma mudança visual nova de Items.

Próximo gate real:
- executar R2 no Arma;
- avaliar fluxo NOVO -> Catálogo -> EQUIPAR NO RASCUNHO;
- avaliar ARMAS DO KIT;
- validar nome inline/SALVAR;
- validar performance;
- enviar RPT + prints.


## Atualização 03/10/2026 — Weapons R2 runtime e Hotfix 1

A candidata **Weapons 0.6-E R2** foi executada no Arma e terminou em **534/554 PASS, 20 FAIL**. Ela não está homologada.

O **R2 Hotfix 1** corrige:
- isolamento do estado NOVO contra auto-seleção do primeiro kit;
- P2 SEM KIT quando a projeção de Meus Kits não contém seleção;
- invalidação da projeção cacheada de acessórios quando a arma-base do Draft muda ou é restaurada por DESCARTAR;
- regressão automática dropdown Mira x Catálogo ÓTICAS;
- expectativa textual dos seletores compactos R2;
- paths do runner Items 0.13-A em modo self-contained.

Static HF1: **69/69**. Runner R2 HF1: **531 assertion sites**. Runtime/manual/performance: **PENDENTES**.

**0.6-F permanece bloqueada.**

A auditoria BGD Development permanece importante na issue #9, mas o timing está em avaliação; não bloqueia o Hotfix 1 e pode ser executada no fechamento do projeto.


## Atualização 04/10/2026 — Weapons 0.6-F R1 preparada

Decisão do gate:
- a 0.6-E R2 HF1 executou no Arma com **557/558 PASS, 1 FAIL**;
- o único FAIL foi `DESCARTAR cancels pending-new without creating kit`;
- repository e loadout permaneceram corretos;
- por ser uma correção pequena de seleção/contexto visual, ela foi incorporada diretamente à **0.6-F R1**, sem criar Hotfix 2 separado.

Candidata:
- display: `0.6-F R1`;
- semantic: `0.6.5.1`;
- build: `0.6.5.1-final-visual-regression-uicommon-mission-first`;
- static Weapons: **86/86 PASS**;
- full-lab static: **24/24 PASS**;
- runner 0.6-F: **537 assertion sites**;
- runtime/manual/performance: **PENDENTES**.

Hotfix incorporado:
- `NOVO` memoriza o WeaponKit selecionado antes da criação;
- `DESCARTAR` antes da primeira arma cancela o pending-new sem criar WeaponKit;
- quando o kit anterior ainda existe, ele é restaurado;
- a primeira arma aceita pelo novo draft limpa o contexto temporário;
- seleção manual de outro kit também limpa o contexto temporário.

Freeze 0.6-F:
- quatro painéis;
- `ARMAS DO KIT`;
- nome inline + `SALVO / ALTERADO / NOVO`;
- catálogo contínuo + focused refresh;
- compatibilidade engine-derived;
- Conteúdo do Equipamento read-only;
- footer em três faixas;
- aplicação física continua **DEFERRED_0_7**;
- MP/JIP/reconciliação continua **DEFERRED_0_8**.

Preservação:
- Items: byte-idêntico à R2 HF1;
- Nexus: byte-idêntico;
- UICommon: byte-idêntico;
- runner histórico R2 HF1: byte-idêntico.

A convergência visual de Items continua separada.
A auditoria BGD Development permanece importante na issue #9, mas o timing continua em avaliação e não é gate desta candidata.


## Atualização 04/10/2026 — Weapons 0.6-F R2 preparada

Candidata ativa:
- display `0.6-F R2`;
- semantic `0.6.5.2`;
- build `0.6.5.2-final-visual-regression-changed-rows-preview-ready-uicommon-mission-first`.

Escopo:
- ARMAS DO KIT destaca, em âmbar translúcido, somente campos que divergem do `baseRecipe`;
- desfazer a diferença remove o destaque;
- P2 espelha verticalmente preview/nome/classe de P4;
- área de preview foi ampliada e preparada para evolução 3D futura;
- nenhum preview 3D real ou aplicação física entra agora.

Static:
- Weapons 69/69;
- full-lab 30/30;
- runner 545 assertion sites.

Preservação:
- Items/Nexus/UICommon byte-idênticos à 0.6-F R1;
- runner histórico R1 preservado.

Runtime/manual/performance: PENDENTES.
0.7 continua bloqueada até homologação da 0.6-F.


## Atualização 04/10/2026 — Weapons 0.6-F R3 preparada

Candidata ativa:
- 0.6-F R3;
- build `0.6.5.3-search-isolation-global-catalog-query-name-edit-hotfix-uicommon-mission-first`;
- static **36/36**;
- runner **555 assertion sites**.

Correções:
- nome inline pode ficar vazio durante edição, com validação somente ao salvar;
- P2/P3/P4 têm buscas independentes;
- busca textual do Catálogo ignora temporariamente Tipo/Acessório;
- limpar a busca restaura os filtros armazenados.

Items/Nexus/UICommon permanecem congelados.
0.7 continua bloqueada até homologação da 0.6-F R3.


## Atualização 05/10/2026 — Weapons 0.6-F R4 preparada

Resultado R3:
- 579/582;
- 3 FAILs;
- 1 era header visual ainda em R2;
- 2 eram expectativas legadas de busca sincronizada, incompatíveis com o contrato R3 de buscas independentes.

Candidata ativa:
- display 0.6-F R4;
- semantic 0.6.5.4;
- keep-aspect centralizado para previews 2D;
- filtros Tipo/Acessório do Catálogo com largura e gramática padronizadas;
- lista do Catálogo ampliada verticalmente;
- static 86/86;
- runner 560 assertion sites.

Items/Nexus/UICommon congelados.
0.7 continua bloqueada até homologação runtime/manual/performance da R4.


## Atualização 05/10/2026 — Weapons 0.6-F R5

- candidata mission-first R5 preparada após teste real da R4;
- authoring passa a criar kit automaticamente ao enviar arma sem kit selecionado;
- troca da arma-base passa a aceitar mudança entre categorias internas, atualizando `targetSlot + Recipe` de forma atômica;
- tipo interno deixa de ser informação de jogador em ARMAS DO KIT/footer;
- feedback direto deixa de expor códigos `WEAPONS_UI_*`;
- corrigidos tooltip `CatalogSearch`, expectativas antigas do runner e política global de `CfgRemoteExec` da missão;
- aplicação física segue bloqueada para 0.7 e MP/JIP para 0.8;
- documentação detalhada: `docs/42_WEAPONS_0_6_F_R5_DYNAMIC_DRAFT_AUTHORING_CANDIDATE.md`;
- **atenção:** o source avançado R5 ainda não foi espelhado integralmente na missão canônica do repositório, que continua contendo Weapons E R1; não declarar equivalência de source até a sincronização.


## Atualização 05/10/2026 — Weapons 0.6 encerrada para continuidade

Último runtime real:
- candidata: **Weapons 0.6-F R6**;
- AUTO: **595 PASS / 2 FAIL / 597 total**;
- testes manuais: **APROVADOS**;
- UICommon: **12/12**;
- Items + UICommon: **12/12**;
- authoring dinâmico, troca entre categorias internas, busca, filtros, preview proporcional, highlight de diferenças e focused refresh funcionaram conforme esperado.

Os 2 FAILs restantes NÃO representam regressões funcionais:
1. expectation do `uiState.schemaVersion` ainda acoplada à revisão textual;
2. expectation do texto literal do header ainda acoplada à revisão textual.

Decisão:
- **não criar 0.6-F R7 somente para corrigir testes frágeis**;
- **linha Weapons 0.6 liberada para continuidade funcional**;
- próximo checkpoint: **0.7 — Slot-Safe Weapon Application**;
- a limpeza dos asserts frágeis do harness será absorvida no início da 0.7.

### Regra nova de testes automáticos

Testes automáticos de UI NÃO devem falhar apenas porque mudou:
- número de revisão exibido no header;
- texto literal de versão/candidato;
- marcador textual usado somente para identificar a entrega;
- string cosmética sem semântica funcional.

Quando necessário, validar:
- presença do controle;
- capability/feature flag estável;
- comportamento;
- estado funcional;
- contrato de dados.

Versão/build/revisão continuam registrados em logs e buildInfo, mas não devem ser usados como gate frágil de UI.

Estado:
**Weapons 0.6 — FUNCIONAL/MANUAL APROVADA PARA CONTINUIDADE; 2 FAILs de harness conhecidos e não-bloqueantes.**
