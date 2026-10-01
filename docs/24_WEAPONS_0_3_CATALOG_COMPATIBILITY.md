# Weapons 0.3 — Catalog & Compatibility

## Estado

**MISSION-FIRST FUNCTIONAL GATE: APPROVED (single-player).**

- candidata final: **0.3 R2**;
- AUTO TEST final: **213/213 PASS / 0 FAIL**;
- ambiente validado: Arma 3 Stable 2.22.154045;
- PBO/Packaging: **DEFERRED**;
- multiplayer/JIP/reconnect: **DEFERRED**;
- addon source integrado na branch: ainda 0.1-A.

## Objetivo

Provar que Weapons consegue descobrir armas e compatibilidades a partir do próprio engine, inclusive conteúdo de mods, sem manter listas hardcoded por classe.

## Catálogo-base validado

No modset real usado no gate:

| Categoria | Quantidade |
|---|---:|
| PRIMARY | 2406 |
| HANDGUN | 279 |
| SECONDARY | 85 |
| **TOTAL BASE** | **2770** |

- presets ignorados no catálogo-base: **610**;
- entradas com displayName vazio descartadas: **0**;
- catálogo com presets: **3380**;
- build observado do catálogo-base: aproximadamente **2,1–2,3 s**;
- cache de sessão: aprovado.

## Compatibilidade

Consulta sob demanda:

```text
weaponClass
  -> compatibleItems por slot
  -> compatibleMagazines
```

Slots validados:

- MuzzleSlot;
- PointerSlot;
- CowsSlot;
- UnderBarrelSlot.

Casos de referência aprovados:

- MX: optic, suppressor, pointer, bipod e magazine;
- P07: suppressor e magazine;
- NLAW: catalogação como SECONDARY;
- arma inexistente: rejeição fail-closed.

## Conteúdo modded / provenance

O catálogo confirmou classes não-A3 e registrou addon/mod de origem.

Exemplo observado no gate: uma Seekins SP10M proveniente de conteúdo carregado por mod.

O objetivo não é hardcodear mods conhecidos; provenance serve para diagnóstico, UI, filtros futuros e Policy.

## Presets

O catálogo-base exclui variantes/presets pré-montados para reduzir duplicação e manter uma visão de classes-base.

Uma consulta separada pode incluir presets quando necessário.

## Reverse compatibility

A R1 tentou usar um reverse lookup global com `compatibleWeapons`.

Em modset grande isso fez o engine percorrer amplo conteúdo de `CfgWeapons` e expor milhares de warnings/erros de configurações de terceiros, impedindo o AUTO TEST de chegar ao resumo.

Decisão R2:

- **não usar reverse scan global no gate/runtime normal**;
- manter forward compatibility como fonte principal;
- se reverse lookup for necessário, construir índice a partir do **catálogo filtrado/cacheado do SP_ORG**.

Marcador de decisão:

```text
CATALOG_REVERSE_LOOKUP
strategy=DEFERRED_FILTERED_INDEX
reason=AVOID_GLOBAL_CFGWEAPONS_SCAN
```

## Higiene de log R2

A R2 também removeu dois floods introduzidos pelo laboratório:

- `Unknown entity: ' Compatibility'` causado por `&` em texto renderizado;
- `Cannot load texture ... dot_ca.paa` causado por path incorreto do ícone Draw3D.

Ambos desapareceram no RPT final.

## Resultado

```text
Weapons 0.3 R2
MISSION-FIRST FUNCTIONAL GATE: APPROVED

AUTO TEST: 213 / 213
FAIL: 0

Catalog discovery: APPROVED
Modded provenance: APPROVED
Forward compatibility: APPROVED
Magazine compatibility: APPROVED
Preset filtering: APPROVED
Session cache: APPROVED
Reverse global scan: DEFERRED BY DESIGN

PBO Packaging: DEFERRED
MP/JIP/reconnect: DEFERRED
Intrinsic physical identity: NOT CLAIMED
```

## Próximo marco

**0.4 — WeaponRecipe**.

Ver também: [25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md](25_WEAPONS_PLAYER_UI_E_FRONTEIRA_ARMORER.md).
