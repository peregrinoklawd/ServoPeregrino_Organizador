# Weapons 0.7-B — Slot-Safe Apply B1

Data: 2026-10-07.

## Status

**STATIC READY / RUNTIME PENDING**

Branch:

`feature/weapons-0.7-b-slot-safe-apply`

Baseline obrigatória:

- UICommon 0.2 homologada/congelada;
- Weapons 0.6-F R6 UI congelada;
- Weapons 0.7-A Plan/Snapshot/Dry-Run homologada com **673/673 PASS / 0 FAIL**;
- baseline marker: `baseline/weapons-0.7-a-homologated`.

Identidade candidata:

- display: `0.7-B`;
- semantic: `0.7.1.1`;
- build: `0.7.1.1-slot-safe-apply-b1-mission-first`.

## Referências obrigatórias

A B1 foi derivada principalmente de:

- `docs/44_WEAPONS_0_7_APM_APPLICATION_CASE_STUDY.md`;
- `docs/63_WEAPONS_0_7_A_PLAN_SNAPSHOT_DRY_RUN.md`;
- `docs/23_WEAPONS_0_2_WEAPON_CONFIGURATION.md`;
- `docs/26_WEAPONS_0_4_WEAPON_RECIPE.md`;
- `docs/27_WEAPONS_0_5_WEAPON_KIT.md`;
- `docs/18_CATALOGO_FUNCIONAL_E_OWNERSHIP.md`;
- `docs/43_UI_AUTOMATED_TEST_STABILITY_POLICY.md`.

## Objetivo

Habilitar a primeira mutação física controlada de Weapons 0.7.

A B1 deve provar que um WeaponKit pode ser aplicado fisicamente sem transformar
WeaponKit em loadout completo e sem alterar domínios fora do slot alvo.

Fluxo:

```text
WeaponKit
  -> ApplicationPlan 0.7-A congelado
  -> ApplicationSnapshot 0.7-A congelado
  -> build target loadout
  -> setUnitLoadout <clone>, false
  -> post-validation
       target configuration
       magazine/ammo
       preservation fingerprint
  -> SUCCESS
       ou safety rollback imediato se a pós-validação divergir
```

## Contratos 0.7-A permanecem congelados

0.7-B NÃO muda:

- `0.7-A-application-plan-candidate`;
- `0.7-A-application-snapshot-candidate`;
- `dryRunOnly=true` do Plan;
- `mutationAuthorized=false` do Plan.

Interpretação:

O Plan descreve a alteração e **não concede autoridade para mutar**.

A autoridade física pertence ao executor 0.7-B
`applyApplicationPlan`, que é uma camada posterior e explícita.

Isso evita reescrever um contrato que acabou de ser homologado.

## Funções novas

`weapons/functions/application/`

- `fn_buildApplicationTargetLoadout.sqf`;
- `fn_validateAppliedApplicationState.sqf`;
- `fn_applyApplicationPlan.sqf`.

Runner:

- `weapons/functions/tests/fn_runDelivery0_7_BTests.sqf`.

## Estratégia física B1

Estratégia ativa:

`FULL_LOADOUT_CLONE_SETUNITLOADOUT_FALSE`

Passos:

1. validar Plan;
2. validar Snapshot;
3. exigir Plan/Snapshot para o mesmo slot;
4. exigir que `getUnitLoadout` atual ainda seja exatamente o snapshot capturado;
5. deep-copy do loadout capturado;
6. substituir somente a linha do slot alvo;
7. executar:
   `unit setUnitLoadout [targetLoadout,false]`;
8. pós-validar;
9. se divergente, tentar restaurar imediatamente o snapshot completo.

## Preservação

Fingerprint 0.7-A continua sendo a autoridade para domínios não alvo.

Devem permanecer equivalentes:

- duas armas não alvo;
- uniforme + conteúdo;
- colete + conteúdo;
- mochila + conteúdo;
- headgear;
- goggles;
- binocular/rangefinder;
- assignedItems.

O target slot é deliberadamente excluído do fingerprint porque é o domínio autorizado a mudar.

## Política candidata de magazine/ammo

### Mesmo magazine observado + mesma arma/família

`PRESERVE_OBSERVED_AMMO`

A linha de magazine capturada no Snapshot é reutilizada.

Exemplo:

```text
ANTES: 30Rnd_65x39_caseless_mag / 17
DEPOIS: 30Rnd_65x39_caseless_mag / 17
```

Objetivo: não completar silenciosamente magazine parcial.

### Magazine novo/diferente

`NEW_MAGAZINE_FULL_CAPACITY`

A B1 usa a capacidade declarada em `CfgMagazines >> count`.

Essa política é **candidata** e deve ser confirmada pelo runtime/UX antes de freeze definitivo da linha 0.7.

### Recipe sem magazine

`NO_RECIPE_MAGAZINE`

O target row é construído sem primary magazine.

### Secondary muzzle

Loaded state secundário do mesmo weapon row é preservado somente quando a arma
permanece na mesma classe/família. Não é transportado através de REPLACE.

## NO_OP

Se o ApplicationPlan estiver em `NO_OP`:

- não chamar `setUnitLoadout`;
- executar pós-validação observacional;
- retornar `mutationPerformed=false`.

## Stale Snapshot

Se o loadout mudar após a captura:

- abortar antes da mutação;
- retornar `WEAPONS_APPLICATION_APPLY_STALE_SNAPSHOT`;
- `mutationPerformed=false`.

## Pós-validação B1

Após a mutação:

- weapon class deve ser igual ou family-equivalent somente para SECONDARY;
- muzzle/pointer/optic/bipod devem corresponder à configuração desejada;
- primary magazine deve corresponder à política calculada;
- secondary loaded magazine deve corresponder ao target row;
- preservation fingerprint deve ser exatamente o Snapshot.

A função não considera apenas “setUnitLoadout terminou” como sucesso.

## Safety rollback da B1

Se a pós-validação falhar:

- restaurar imediatamente `capturedLoadout` com `fullMagazines=false`;
- restaurar `animSpeedCoef`;
- retornar FAILED;
- registrar se a restauração ficou exatamente igual ao snapshot.

Esse fallback existe por segurança.

**0.7-C continua sendo o gate dedicado de rollback**, com falhas controladas,
fault injection, validação do rollback e garantia de ausência de estado parcial.

## Harness físico isolado

O AUTO TEST da 0.7-B NÃO usa o player como alvo de mutação.

Ele cria uma unidade local `B_Soldier_F`, invisível e isolada, executa a
mutação física real nessa unidade e a remove ao final.

Motivo:

- testar engine mutation real;
- tornar cenários determinísticos;
- não destruir ou rearranjar o equipamento do jogador que está executando o lab.

## Cenários automáticos B1

Cumulativo:

- primeiro roda 0.7-A inteira: **673/673 esperado**.

Depois B1:

### PRIMARY — RECONFIGURE

- MX;
- 17 tiros no magazine;
- adiciona `optic_Hamr`;
- mesmo magazine;
- espera `PRESERVE_OBSERVED_AMMO`;
- 17 tiros devem permanecer 17.

### HANDGUN — REPLACE

- P07 -> ACP-C2;
- magazine muda para `9Rnd_45ACP_Mag`;
- espera `NEW_MAGAZINE_FULL_CAPACITY`.

### SECONDARY — INSERT

- slot vazio -> NLAW;
- espera `NEW_MAGAZINE_FULL_CAPACITY`;
- equivalência de família SECONDARY continua válida quando o engine/modset normalizar runtime variants.

### PRIMARY — NO_OP

- configuração/magazine já correspondem;
- nenhuma mutação física;
- partial ammo preservado.

### Stale Snapshot

- altera domínio protegido depois do Snapshot;
- executor deve recusar;
- nenhum delta adicional pode ocorrer.

## Fora de escopo

Ainda NÃO implementar nesta B1:

- botão de equipar/aplicar na UI;
- Undo player-facing;
- fault injection formal;
- rollback transacional completo homologado;
- animações;
- multiplayer/remote authority;
- JIP/reconnect;
- PBO final;
- Preview 3D.

## Gate manual

Executar:

`SP_ORG LAB - TESTAR WEAPONS 0.7-B`

Confirmar:

1. AUTO TEST com **0 FAIL**;
2. player permanece com o próprio loadout intacto;
3. nenhuma ação física nova aparece ainda na UI 0.6-F R6;
4. enviar RPT completo.

## Próximo gate após aprovação

**Weapons 0.7-C — Post-Validation / Rollback**

Objetivo:

- fault injection controlado;
- falha pós-mutação;
- rollback obrigatório;
- restauração comprovada;
- nenhum estado parcial;
- preparar o core para integração player-facing na 0.7-D.


## Static/package gate B1

Static review:
- 3 novas funções Application registradas em CfgFunctions;
- runner 0.7-B registrado;
- delimitadores estruturais balanceados nos novos SQF, lifecycle, harness e description.ext;
- nenhum escape literal `\\n` nos registros novos do mission config;
- estratégia física aparece somente no executor 0.7-B e no harness;
- runner saudável esperado: **673 legacy + 118 local = 791/791, 0 FAIL**.

Pacote canônico:
- workflow: `Package self-contained UI lab`;
- run: `37680788721`;
- packaged source commit: `172c24010dcdd1d0490806750b8c83c773df9725`;
- artifact id: `11508728504`;
- artifact digest: `sha256:262c623c154b4eaa9224cf33c29661cecbb43f01eca12fd52907eb036f61ae3b`;
- mission ZIP SHA256: `d21fe5f35ce9d1d7794fe1b6c2c4a9889ae1096dff957c48ef2d4dd0f69efc1b`;
- mission: `SP_ORG_Weapons_0_7_B_Slot_Safe_Apply_B1.VR`.

Runtime Arma continua pendente.


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
