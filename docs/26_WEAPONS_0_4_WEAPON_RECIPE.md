# Weapons 0.4 — WeaponRecipe

## Estado

**MISSION-FIRST FUNCTIONAL GATE: GREEN IN R3. R4 corrigiu a higiene, mas expôs uma regressão de timing no SECONDARY. FREEZE FINAL PENDENTE DE R5.**

- R3 AUTO TEST: **245/245 PASS / 0 FAIL**;
- R4 freeze candidate preparada: **94/94 static PASS / 0 FAIL**; runtime Arma ainda pendente;
- R4 altera apenas deduplicação case-insensitive de classnames em listas de compatibilidade;
- nenhuma mudança de schema/semântica planejada para R4;
- PBO/Packaging: **DEFERRED**;
- multiplayer/JIP/reconnect: **DEFERRED**;
- addon source integrado na branch: ainda 0.1-A.

## Objetivo

Representar de forma estruturada uma montagem desejada de arma sem mutar o inventário.

WeaponRecipe é uma descrição do estado desejado e consome:

- WeaponConfiguration;
- compatibilidade de attachments;
- compatibilidade de magazines.

## Schema candidato

```text
WeaponRecipe 0.4-recipe-candidate
├─ configuration
│  └─ WeaponConfiguration 0.2-candidate
└─ magazineClass
   └─ opcional
```

## O que Recipe NÃO possui

Pertence a outras camadas:

- `targetSlot` -> WeaponKit;
- nome do kit -> WeaponKit;
- `instanceId` -> WeaponInstance;
- serial -> WeaponInstance;
- ammoCount -> loadedState/runtime;
- persistência -> camada futura;
- aplicação no inventário -> gate posterior.

## Regras

- structural validation fechada;
- semantic validation usa catálogo/compatibilidade;
- fingerprint determinístico;
- comparação case-insensitive;
- grafia observada do engine preservada no payload;
- deep-copy de WeaponConfiguration;
- magazine incompatível falha antes de qualquer operação;
- Recipe nunca altera o inventário.

## Resultado R3

```text
AUTO_TEST_SUMMARY
mode=MISSION_FIRST_0_4_R3
passed=245
failed=0
total=245
```

Casos aprovados:

- PRIMARY / MX;
- HANDGUN / P07;
- SECONDARY / NLAW;
- Recipe sem magazine;
- Recipe com magazine compatível;
- Recipe com configuração completa;
- Recipe inválido;
- attachment incompatível;
- magazine incompatível;
- campos de outros domínios rejeitados;
- fingerprint;
- equality;
- deep-copy;
- nenhuma mutação do loadout.

## SECONDARY e variantes runtime

Durante as rodadas R1/R2, foi observado um comportamento importante em disposable launchers com mods.

Uma arma-base pode ter variantes internas/runtime que compartilham `baseWeapon` e expõem a compatibilidade real de magazine somente nessas variantes.

Estratégia R3:

```text
requested SECONDARY
  -> canonical baseWeapon
  -> find type=4 variants with same baseWeapon
  -> union compatible magazine data
  -> filter internal/hidden magazines
  -> expose player-facing compatibility
```

Essa estratégia:

- é genérica;
- não contém hardcode de ACE;
- não contém hardcode de NLAW;
- não contém hardcode de magazine específico.

No ambiente de validação, foram relacionadas as classes `launch_NLAW_F` e `ACE_launch_NLAW_ready_F`, e a Recipe com `NLAW_F` passou.

## Dívida de higiene encontrada após R3

O resultado de compatibilidade exibiu:

```text
nlaw_f
NLAW_F
```

As duas strings representam a mesma classe para nossas comparações case-insensitive.

Isso não causou falha funcional, mas pode gerar duplicação visual futura.

### R4 — freeze candidate

Candidata preparada em `0.4.0.4-case-insensitive-compatibility-dedupe-mission-first`, com 94/94 checks estáticos.

R4:

- deduplicar classnames case-insensitively;
- preservar uma grafia original do engine;
- manter ordem determinística;
- não alterar WeaponRecipe;
- não alterar a estratégia de compatibilidade;
- manter todas as regressões anteriores verdes.

## Critério de freeze

Após R5:

```text
AUTO TEST = 0 FAIL
case-insensitive duplicate regression = PASS
SECONDARY runtime/base family equivalence = PASS
PRIMARY/HANDGUN strict class guard = PASS
WeaponRecipe schema unchanged = PASS
inventory mutation = NONE
```

Então:

**Weapons 0.4 — WeaponRecipe = HOMOLOGADA / FROZEN mission-first**

Próximo marco: **0.5 — WeaponKit**.
