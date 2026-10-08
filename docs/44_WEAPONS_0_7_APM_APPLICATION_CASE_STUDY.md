# Weapons 0.7 — Caso de Estudo APM para Aplicação Física Slot-Safe

Data: 2026-10-05.

## Objetivo

Estudar o módulo WEAPON do projeto histórico APM como referência de arquitetura e comportamento para a implementação de **Weapons 0.7 — Slot-Safe Weapon Application**.

Este documento NÃO autoriza copiar código APM para Weapons.
A regra é:

- entender contratos já provados;
- separar o que deve ser mantido, adaptado, descartado ou criado;
- reimplementar dentro da arquitetura Nexus / UICommon / Weapons atual;
- preservar ownership e fronteiras do Servo Peregrino.

## Fontes consultadas

Fonte principal:
- `APM-DATA-001 — Especificação Única de Dados e Catálogo — v2.11.4`;
- seções 354–381.

Fontes de continuidade:
- `CONTINUIDADE_NOVO_CHAT_APM_11_9_13`;
- `CONTINUIDADE_NOVO_CHAT_APM_11_9_26`.

Observação:
- o estudo é predominantemente de contrato/arquitetura;
- não foi feita nesta rodada uma auditoria função-a-função de todo o source APM;
- qualquer detalhe não sustentado pelos documentos deve ser validado antes de virar runtime Weapons.

## O que o APM já provou

### Aplicação transacional

O APM formaliza a aplicação de uma configuração WEAPON como:

```text
planejamento
   ↓
confirmação quando aplicável
   ↓
captura de snapshot
   ↓
mutação física
   ↓
pós-validação
   ↓
resultado estruturado
   ├─ SUCCESS → estado de DESFAZER
   └─ FAILED  → rollback
```

O término da função não é autoridade suficiente para SUCCESS.
O resultado físico pós-mutação é a autoridade.

### Contratos especializados

O APM separa explicitamente:

- `APM_WEAPON_APPLICATION_PLAN v1`;
- `APM_WEAPON_APPLICATION_SNAPSHOT v1`;
- `APM_WEAPON_APPLY_RESULT v1`;
- `APM_WEAPON_UNDO_STATE v1`.

A lição importante não são os nomes.
É a separação de responsabilidades.

### Preservação de magazines

O APM exige:

`setUnitLoadout ... fullMagazines=false`

Objetivo:
- não completar magazines parciais silenciosamente;
- preservar o estado físico observado.

### Troca no mesmo slot

A animação/aplicação permanece no próprio slot:
- PRIMARY → PRIMARY;
- HANDGUN → HANDGUN;
- LAUNCHER → LAUNCHER.

O APM não usa uma arma de outro slot como ponte.

### Estado de animação

A velocidade existente é capturada via `getAnimSpeedCoef` e reaplicada.
O fluxo não impõe arbitrariamente uma velocidade nova.

### DESFAZER

Após SUCCESS, o APM mantém snapshot transitório para DESFAZER.

Regra importante:
- alteração externa posterior no loadout invalida snapshot de undo obsoleto;
- undo não substitui rollback;
- undo não é persistência entre sessões.

### Drop rápido

O APM também prova um princípio útil:
- componente pode ser aplicado ao equipamento;
- a aplicação física não salva automaticamente o kit;
- não modifica o Draft;
- não migra storage;
- continua protegida por plan/snapshot/validation/rollback.

Isso é altamente compatível com a separação atual:
- Draft = configuração lógica;
- Equipment = estado físico;
- SALVAR = repository;
- aplicar = mutação física.

---

# Leitura para Servo Peregrino

## Regra central da Weapons 0.7

Aplicar um WeaponKit deve alterar **somente o slot derivado internamente da arma**.

Exemplo:

```text
ANTES
PRIMARY   = MX
HANDGUN   = P07
SECONDARY = NLAW
uniform   = U
vest      = V
backpack  = B

APLICAR kit de HANDGUN = ACP-C2

DEPOIS
PRIMARY   = MX       ← idêntico
HANDGUN   = ACP-C2   ← alterado
SECONDARY = NLAW     ← idêntico
uniform   = U        ← idêntico
vest      = V        ← idêntico
backpack  = B        ← idêntico
```

O jogador não administra `targetSlot`.
Weapons deriva internamente o slot da arma, como já faz desde 0.6-F.

## Invariantes de preservação

Os testes 0.7 devem provar preservação de:

- arma não alvo PRIMARY/HANDGUN/SECONDARY;
- uniforme;
- colete;
- mochila;
- conteúdo do uniforme;
- conteúdo do colete;
- conteúdo da mochila;
- headgear;
- goggles;
- binocular/rangefinder;
- assignedItems;
- itens médicos;
- rádios;
- magazines não relacionados;
- demais estado físico não pertencente ao slot alvo.

## Modelo proposto de contratos Weapons

Nomes propostos — NÃO implementados ainda:

- `WEAPONS_APPLICATION_PLAN v1`;
- `WEAPONS_APPLICATION_SNAPSHOT v1`;
- `WEAPONS_APPLY_RESULT v1`;
- `WEAPONS_UNDO_STATE v1`.

Fluxo:

```text
WeaponKit / Draft
       ↓
buildApplicationPlan
       ↓
preValidatePlan
       ↓
captureApplicationSnapshot
       ↓
applyApplicationPlan
       ↓
validateAppliedState
       ├─ OK    → ApplyResult SUCCESS + optional UndoState
       └─ FAIL  → rollback snapshot → ApplyResult FAILED
```

## Estratégias de mutação candidatas

### Estratégia A — full loadout clone + replace target slot

Hipótese principal para o primeiro spike:

1. `getUnitLoadout`;
2. deep-copy;
3. substituir somente a tupla do slot alvo;
4. `setUnitLoadout <clone>, false`;
5. pós-validar alvo;
6. comparar fingerprints de tudo que deveria permanecer igual;
7. rollback completo se houver divergência.

Vantagens:
- aproxima-se do modelo APM já provado;
- snapshot/rollback são diretos;
- alteração planejada pode ser descrita antes da mutação.

Riscos:
- engine/mods podem normalizar partes do loadout;
- seleção de arma corrente/animação pode exigir tratamento separado;
- qualquer diferença externa precisa ser detectada pela pós-validação.

### Estratégia B — comandos locais por slot

Exemplo conceitual:
- remover arma alvo;
- adicionar arma;
- adicionar attachments;
- restaurar magazine/ammo.

Vantagem:
- mutação aparentemente mais estreita.

Riscos:
- mais estados intermediários;
- mais pontos de falha;
- preservação de magazine/ammo é mais complexa;
- rollback é menos naturalmente atômico.

### Recomendação do estudo

Começar 0.7 com a **Estratégia A como hipótese**, porque o APM já fornece evidência de viabilidade de `setUnitLoadout` com `fullMagazines=false`.

Não congelar a decisão sem runtime.
Se a pós-validação mostrar divergências induzidas pela engine/modset, comparar com Estratégia B.

---

# KEEP / ADAPT / DROP / NEW

## KEEP

- plan → snapshot → mutation → post-validation → rollback;
- resultado físico como autoridade;
- `fullMagazines=false`;
- same-slot application;
- Draft separado de equipamento físico;
- undo separado de rollback;
- snapshot transitório;
- invalidar undo após alteração externa;
- preservar velocidade de animação existente se animação for usada.

## ADAPT

- PRIMARY/HANDGUN/LAUNCHER do APM → metadata interno atual de Weapons;
- contratos APM → contratos próprios Weapons;
- storage APM → WeaponKit repository atual;
- compatibilidade APM → compatibility engine já homologado na Weapons 0.3/0.6;
- mensagens APM → feedback player-facing atual;
- confirmação modal → política UX atual da interface Weapons.

## DROP

- namespaces APM;
- storage APM;
- payloads persistentes APM;
- qualquer dependência da missão histórica APM;
- qualquer lógica duplicada já pertencente a Nexus/UICommon/Weapons;
- testes que dependam de texto/versionamento cosmético.

## NEW

- fingerprint explícito de preservação do loadout não alvo;
- comparação before/after por domínio;
- códigos de resultado Weapons próprios;
- telemetria de slot alvo/resultado;
- testes com modsets e armas de bounding/attachment incomuns;
- integração futura com autoridade 0.8 sem reescrever o core transacional.

---

# Sequência recomendada da 0.7

## 0.7-A — Plan / Snapshot / Dry-Run

Sem mutação física.

Entregar:
- ApplicationPlan;
- Snapshot;
- fingerprints;
- pre-validation;
- simulação de resultado esperado;
- testes de preservação.

Gate:
- nenhuma mudança no jogador.

## 0.7-B — Slot-Safe Apply

Habilitar mutação física de um slot.

Gate:
- target correto;
- demais slots e equipamentos byte/semanticamente equivalentes;
- attachments corretos;
- magazines/ammo preservados.

## 0.7-C — Post-Validation / Rollback

Forçar falhas controladas.

Gate:
- divergência física → FAILED;
- rollback restaura snapshot;
- não deixar estado parcial.

## 0.7-D — UI Integration / Undo Candidate

Habilitar ação física reservada desde 0.6.

Opcional:
- Undo transitório somente após o core estar estável.

A animação pode ser adicionada depois que aplicação/rollback estiverem corretos; não deve ser requisito para o primeiro apply seguro.

---

# Testes obrigatórios

Mínimo:
- PRIMARY → PRIMARY;
- HANDGUN → HANDGUN;
- SECONDARY → SECONDARY;
- slot vazio → arma;
- arma → outra arma;
- arma com óptica/muzzle/pointer/bipod;
- magazine parcialmente usado;
- launcher/secondary especial;
- falha de attachment;
- falha pós-mutação forçada;
- rollback;
- alteração externa invalida undo;
- loadout geral preservado.

Testar com:
- vanilla;
- modset real do usuário;
- armas com compatibilidade ACE/CBA/Tier One/RHS quando presentes.

## Decisão

**APM é referência de contrato para 0.7, não fonte para cópia.**

O core transacional deve ser recriado em Weapons com contratos próprios e testes de preservação explícitos.

## Execução iniciada — 0.7-A

A primeira etapa recomendada neste estudo foi implementada como candidata mission-first:

- Plan;
- Snapshot;
- preservation fingerprint;
- Dry-Run;
- mutation forbidden.

A estratégia A permanece apenas hipótese declarada para 0.7-B. 0.7-A não chama `setUnitLoadout`.

Detalhes e gate:
`docs/63_WEAPONS_0_7_A_PLAN_SNAPSHOT_DRY_RUN.md`.

## 07/10/2026 — Weapons 0.7-B B1 aberta

Baseline:
- UICommon 0.2 congelada;
- Weapons 0.7-A homologada: 673/673, 0 FAIL;
- marker: `baseline/weapons-0.7-a-homologated`.

Candidata:
- branch: `feature/weapons-0.7-b-slot-safe-apply`;
- display: `0.7-B`;
- semantic: `0.7.1.1`;
- build: `0.7.1.1-slot-safe-apply-b1-mission-first`.

Escopo B1:
- consumir Plan/Snapshot congelados da 0.7-A;
- build do target loadout;
- primeira mutação física via `setUnitLoadout [loadout,false]`;
- somente target slot pode mudar;
- pós-validar configuração, magazine/ammo e preservation fingerprint;
- stale Snapshot aborta antes da mutação;
- NO_OP não toca no engine;
- safety rollback imediato se pós-validação divergir;
- runner usa unidade isolada e não altera o player.

Política candidata:
- mesmo magazine observado -> preservar ammo observado;
- magazine novo/diferente -> capacidade cheia de CfgMagazines;
- sem magazine na Recipe -> target sem primary magazine.

UI física continua deferred para 0.7-D.
Rollback/fault-injection formal continua 0.7-C.
Multiplayer continua 0.8.

Documento:
`docs/65_WEAPONS_0_7_B_SLOT_SAFE_APPLY.md`.


## 08/10/2026 — B2 candidata (STATIC READY / RUNTIME PENDING)

B1 real: 779 PASS / 3 FAIL / 782 executados; 9 checks dependentes não executados.
Causa confirmada no source dos dois FAILs PRIMARY: diff expõe `changes` (objetos com `field`), consumidor buscava `changedFields`; RECONFIGURE virava NO_OP e pós-validação recusava óptica ausente.
B2 adapta somente o consumidor, preservando schema/diff e a força da pós-validação.
Magazine removido também conta como delta. Added same-class optic/muzzle/pointer/bipod/magazine regressions; partial ammo continua 17 -> 17.
Cleanup: scheduler obrigatório, espera bounded de 5s e gate de objeto ausente em allUnits/allMissionObjects. B1 só provou falha da observação imediata, não vazamento; a confirmação do cleanup corrigido depende do RPT B2.
Dependentes são BLOCKED; total esperado estável 890 = 673 legacy + 217 local, aprovação exige zero FAIL/BLOCKED.
Branch `feature/weapons-0.7-b-slot-safe-apply`; semantic `0.7.1.2`.
Executar `SP_ORG LAB - TESTAR WEAPONS 0.7-B`; entregar RPT completo. UI física segue deferred.
B2 não homologada. C/D podem ser preparadas encadeadas, mas gates reais são sequenciais B2 -> C -> D. Não merge main.


## 08/10/2026 — Weapons 0.7-C candidata

**STATIC READY / RUNTIME PENDING**. Branch `feature/weapons-0.7-c-post-validation-rollback`; semantic `0.7.2.1`; build `0.7.2.1-post-validation-rollback-c1-mission-first`.
B2 -> C -> D são candidatas encadeadas. Gate real obrigatório sequencial; nenhum merge main, nenhum freeze/homologação sem RPT.
UICommon 0.2 e Items funcionalmente intocados. Plan/Snapshot 0.7-A congelados; fullMagazines=false. Multiplayer 0.8 deferred.


## 08/10/2026 — Weapons 0.7-D candidata

**STATIC READY / RUNTIME PENDING**. Branch `feature/weapons-0.7-d-ui-integration`; semantic `0.7.3.1`; build `0.7.3.1-ui-integration-d1-mission-first`.
B2 -> C -> D são candidatas encadeadas. Gate real obrigatório sequencial; nenhum merge main, nenhum freeze/homologação sem RPT.
UICommon 0.2 e Items funcionalmente intocados. Plan/Snapshot 0.7-A congelados; fullMagazines=false. Multiplayer 0.8 deferred.
