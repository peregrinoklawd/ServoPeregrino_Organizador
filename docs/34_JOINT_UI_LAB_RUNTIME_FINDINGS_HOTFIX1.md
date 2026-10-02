# Joint UI Lab — First Runtime Findings / Integration Hotfix 1

Data: 2026-10-02.

## Evidência do primeiro teste conjunto

Missão:
`SP_ORG_Items_Weapons_UI_Lab_Full_SelfContained.VR`

Sem PBOs SP_ORG externos.

Resultados confirmados no RPT:
- Nexus, UICommon, Items 0.13-A e Weapons 0.6-E R1 inicializaram juntos;
- UICommon foundation: **8/8 PASS**;
- Items abriu e operou no laboratório conjunto;
- Weapons abriu no mesmo runtime;
- Weapons E R1 suíte histórica: **536/536 PASS**.

## Finding 1 — Items: falha física sem causa player-facing

Reprodução observada:
- source: `ACE_NVG_Gen2_Brown`;
- operação: ADD;
- target resolvido: `UNIFORM`;
- container: `U_B_CombatUniform_mcam`;
- resultado externo: `ITEMS_PLAN_FAILED`;
- actions=0 / appliedQty=0.

### Causa

O planner pode rejeitar a entrada antes de existir `applyResult`.
Em ADD, depois de validar a classe, a principal causa para plannedQty=0 é
`ITEMS_TARGET_CAPACITY_INSUFFICIENT`.

A informação já existia em:
- `data.rejectedEntries`;
- `data.capacity`.

O problema era de apresentação/telemetria:
`fn_classifyUIOutcome.sqf` consultava somente `applyResult.rejectedEntries`.
Assim, uma falha de planejamento perdia a causa interna e mostrava apenas:
`Nenhuma ação física executável foi produzida.`

### Hotfix

Mission-first candidate:
- usar `data.rejectedEntries` quando ainda não existe applyResult;
- mensagem para capacity:
  `Não há espaço suficiente em <destino> para adicionar o item solicitado.`
- tratar também classe indisponível e conteúdo insuficiente para REMOVE;
- PHYSICAL_FLOW POST passa a registrar:
  - rejectCode;
  - availableLoad;
  - currentLoad;
  - maxLoad.

Não alterar o Result code histórico `ITEMS_PLAN_FAILED` nesta rodada.

## Finding 2 — Items: confirmação redundante ao fechar

O Draft é session-local e já permanece em memória após fechar a UI.

A implementação antiga perguntava:
`Fechar a interface mantendo o rascunho em memória?`

Essa confirmação não protege contra perda de dados porque CLOSE_UI não descarta o Draft.

### Hotfix

- CLOSE_UI fecha imediatamente;
- Draft dirty continua em memória;
- confirmação permanece somente em ações que realmente descartam/substituem estado:
  - LOAD_KIT;
  - NEW_DRAFT;
  - DISCARD_DRAFT.

## Finding 3 — Weapons: primeiro open com painéis vazios

Sintoma:
- primeiro open após iniciar a missão mostra Catálogo/Conteúdo vazios;
- primeiro clique em filtro/slot materializa os dados.

### Causa

`fn_onInterfaceLoad.sqf` recebia um display válido pelo evento onLoad e chamava
`fn_refreshInterface.sqf` imediatamente.

`fn_refreshInterface.sqf`, porém, procura o display novamente via `findDisplay`.
No primeiro frame, o dialog ainda pode não estar registrado para `findDisplay`;
o refresh sai como `WEAPONS_UI_NOT_OPEN`.

O handshake R1 validava somente a lista de WeaponKits. Com repository vazio:
- rows=0;
- expectedRows=0;
- handshake aceitava a abertura como válida.

Catálogo e Conteúdo do Equipamento não participavam do gate.

O RPT confirmou a sequência:
- UI_INITIAL_SYNC 0/0;
- nenhum CATALOG_BUILD no open;
- CATALOG_BUILD somente após interação posterior.

### Hotfix

- onLoad mostra placeholders de carregamento;
- aguarda `findDisplay` apontar para o mesmo display;
- executa o primeiro full refresh só então;
- gate de sincronização passa a validar:
  - kit rows;
  - catalog rows / catalogTotalFiltered;
  - equipment materialized;
- permite um recovery refresh;
- novo log:
  `UI_INITIAL_SYNC_HOTFIX1 ok=... kitRows=... catalogRows=... equipmentReady=...`

## Preservação de baseline

- Weapons E R1 original continua preservada;
- `fn_runDelivery0_6_ETests.sqf` não foi alterado;
- expectativa histórica continua **536/536**;
- requisitos de Weapons 0.6-E R2 continuam congelados e separados deste hotfix.

## Gate Hotfix 1

Teste manual esperado:

1. UICommon -> 8/8.
2. Items:
   - reproduzir target sem espaço;
   - rodapé deve informar a causa;
   - RPT deve trazer rejectCode/capacidade.
3. Items:
   - alterar Draft;
   - fechar no X sem modal;
   - reabrir;
   - Draft deve continuar alterado.
4. Weapons:
   - reiniciar missão;
   - abrir Weapons pela primeira vez;
   - não clicar em nada;
   - Catálogo e Conteúdo devem preencher sozinhos;
   - RPT: `UI_INITIAL_SYNC_HOTFIX1 ok=true`.
5. Weapons AUTO TEST -> 536/536.

Depois da homologação do Hotfix 1:
- continuar Gate 2 de Items + UICommon equivalence;
- depois implementar a Weapons 0.6-E R2 sobre UICommon.


## Resultado do rerun — Hotfix 1 aceito

RPT de 02/10/2026 confirmou:
- UICommon foundation: **8/8 PASS**;
- Items passou a registrar a causa real de falha física:
  - `ITEMS_TARGET_CAPACITY_INSUFFICIENT`;
  - availableLoad/currentLoad/maxLoad disponíveis no PHYSICAL_FLOW;
- Weapons cold-open:
  - `UI_INITIAL_SYNC_HOTFIX1 ok=true`;
  - Catálogo materializado;
  - Equipment materializado;
- Weapons E R1 manteve a suíte histórica **536/536 PASS / 0 FAIL**.

Decisão:
- Hotfix 1: **ACEITO PARA CONTINUIDADE**;
- a baseline conjunta fica liberada para Gate 2 — Items + UICommon Equivalence R1;
- nenhuma mudança visual R2 foi antecipada pelo hotfix.
