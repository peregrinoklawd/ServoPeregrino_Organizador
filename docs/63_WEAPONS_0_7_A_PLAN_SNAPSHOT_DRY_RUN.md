# Weapons 0.7-A — Plan / Snapshot / Dry-Run

Data: 2026-10-07.

## Status

**STATIC READY / RUNTIME PENDING**

Branch:

`feature/weapons-0.7-a-plan-snapshot-dry-run`

Baseline obrigatória:

- UICommon 0.2 final congelada;
- Weapons UI 0.6-F R6 congelada;
- regressão cumulativa Weapons 0.6-F R6: 594/594 no último gate homologado.

Identidade da candidata:

- display: `0.7-A`;
- semantic: `0.7.0.1`;
- build: `0.7.0.1-plan-snapshot-dry-run-mission-first`.

## Objetivo

Abrir a linha Weapons 0.7 com o núcleo de aplicação slot-safe **sem habilitar qualquer mutação física**.

0.7-A deve provar que Weapons consegue:

1. receber um WeaponKit semanticamente válido;
2. derivar internamente o slot alvo;
3. criar um ApplicationPlan;
4. capturar um snapshot read-only do loadout;
5. construir fingerprint explícito de todos os domínios não alvo;
6. simular o resultado esperado;
7. detectar drift/tampering de Plan/Snapshot;
8. permanecer observacional: `getUnitLoadout` antes/depois deve ser exatamente igual.

## Contratos candidatos

### ApplicationPlan

Schema:

`0.7-A-application-plan-candidate`

Campos centrais:

- sourceKind / sourceKitId / sourceKitName;
- targetSlot / targetSlotIndex;
- operation: INSERT / REPLACE / RECONFIGURE / NO_OP;
- desiredRecipe;
- desiredConfiguration;
- desiredMagazineClass;
- currentConfiguration / currentLoadedState;
- changedFields;
- strategy;
- `fullMagazines=false`;
- `dryRunOnly=true`;
- `mutationAuthorized=false`.

Estratégia candidata declarada:

`FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE_CANDIDATE`

Isto é **uma hipótese para 0.7-B**, não uma chamada de engine em 0.7-A.

### ApplicationSnapshot

Schema:

`0.7-A-application-snapshot-candidate`

Captura:

- full `getUnitLoadout`;
- target row;
- target configuration;
- target loadedState;
- fingerprint dos domínios não alvo;
- currentWeapon/currentMuzzle;
- `getAnimSpeedCoef`.

Snapshot é transitório e read-only.

## Fingerprint de preservação

O slot alvo é deliberadamente excluído.

O fingerprint inclui, em ordem estável:

- dois weapon slots não alvo;
- uniform + conteúdo;
- vest + conteúdo;
- backpack + conteúdo;
- headgear;
- goggles;
- binocular/rangefinder;
- assignedItems.

Regra do teste:

- mudar somente o slot alvo NÃO pode alterar o preservation fingerprint;
- mudar qualquer domínio não alvo DEVE alterar o fingerprint.

## Dry-Run

`simulateApplicationPlan`:

- valida Plan;
- valida Snapshot;
- exige que Plan e Snapshot apontem para o mesmo slot;
- rejeita snapshot stale se o loadout atual divergir do capturado;
- resolve resultado lógico esperado;
- define política de magazine/ammo sem executar engine mutation;
- retorna explicitamente:
  - `mutationPerformed=false`;
  - `mutationAuthorized=false`;
  - `loadoutUnchanged=true` quando o estado permanece idêntico.

A política de ammo nesta fase é deliberadamente conservadora:

- mesmo magazine observado: `PRESERVE_OBSERVED_AMMO`;
- Recipe sem magazine: `NO_RECIPE_MAGAZINE`;
- novo magazine/troca de arma: `ENGINE_RESOLUTION_PENDING_0_7_B`.

0.7-A não inventa ainda a política física final para esses casos.

## Funções novas

`weapons/functions/application/`

- `fn_getApplicationPreservationFingerprint.sqf`
- `fn_createApplicationPlan.sqf`
- `fn_validateApplicationPlan.sqf`
- `fn_captureApplicationSnapshot.sqf`
- `fn_validateApplicationSnapshot.sqf`
- `fn_simulateApplicationPlan.sqf`

Teste cumulativo:

- `weapons/functions/tests/fn_runDelivery0_7_ATests.sqf`

## Invariante mais importante

Nesta entrega não pode existir caminho de execução que faça:

- `setUnitLoadout`;
- add/remove weapon;
- add/remove attachment;
- qualquer mutação de inventory/loadout.

A string `SETUNITLOADOUT_FALSE` aparece somente na identidade da estratégia candidata para o próximo gate.

## Gate automático

O teste 0.7-A primeiro executa toda a regressão 0.6-F R6.

Baseline esperada:

**594/594 antes dos checks 0.7-A.**

Depois valida, para PRIMARY / HANDGUN / SECONDARY:

- criação de Configuration/Recipe/WeaponKit;
- ApplicationPlan;
- schema;
- slot derivado;
- dryRunOnly;
- mutationAuthorized=false;
- fullMagazines=false;
- pre-validation;
- Snapshot;
- integridade do fingerprint;
- cobertura dos domínios não alvo;
- Dry-Run;
- mutationPerformed=false;
- loadoutUnchanged=true;
- igualdade exata do `getUnitLoadout` antes/depois.

Também cobre rejeições:

- loadout shape inválido;
- target slot inválido;
- dryRun desabilitado;
- mutationAuthorized=true;
- fullMagazines=true;
- estratégia divergente;
- slot/index mismatch;
- drift de magazine em relação à Recipe;
- snapshot fingerprint adulterado;
- animSpeedCoef inválido.

## Gate manual

Após o AUTO TEST verde:

1. confirmar visualmente que a UI Weapons continua a 0.6-F R6 já homologada;
2. confirmar que nenhum item/arma/equipamento mudou fisicamente;
3. enviar RPT completo.

Não há nova interação física de UI nesta fase.

## Fora de escopo

- equipar arma;
- remover/trocar arma fisicamente;
- mutar attachments;
- resolver ammo para nova arma;
- rollback físico;
- undo;
- animação;
- autoridade multiplayer;
- PBO final.

## Próximo movimento após homologação

### Weapons 0.7-B — Slot-Safe Apply

Somente depois de 0.7-A verde:

- habilitar a primeira mutação física controlada;
- alterar apenas target slot;
- usar `setUnitLoadout ..., false` como primeira hipótese;
- pós-validar target e preservation fingerprint;
- abortar/rollback diante de divergência;
- preservar os contratos Plan/Snapshot homologados em 0.7-A.

