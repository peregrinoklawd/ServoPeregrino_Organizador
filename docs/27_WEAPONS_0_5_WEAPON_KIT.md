# Weapons 0.5 — WeaponKit

## Estado

**MISSION-FIRST FUNCTIONAL GATE: APPROVED / FROZEN.**

Baseline: **Weapons 0.4 R5 — WeaponRecipe**, homologada com **251/251 PASS / 0 FAIL**.

Static validation da candidata 0.5: **131/131 PASS**.

## Objetivo

Transformar o WeaponRecipe congelado em uma unidade reutilizável pelo jogador.

Conceito oficial:

> **WeaponKit = uma arma configurada para um único slot.**

Não é um loadout completo e não altera outros domínios.

## Schema candidato

```text
WeaponKit 0.5-kit-candidate
├─ kitId
├─ name
├─ targetSlot
└─ recipe
   └─ WeaponRecipe 0.4-recipe-candidate
```

## targetSlot

Valores aceitos:

- PRIMARY;
- HANDGUN;
- SECONDARY.

Regra semântica:

```text
weapon type=1 -> PRIMARY
weapon type=2 -> HANDGUN
weapon type=4 -> SECONDARY
```

O slot do kit deve corresponder à categoria real da arma da Recipe.

## kitId

`kitId` identifica o **kit lógico**, não a arma física.

- prefixo: `WKT-`;
- emitido pelo repositório da sessão;
- duplicar um kit gera novo `kitId`;
- renomear/editar preserva o `kitId`;
- não possui relação com WeaponInstance/serial.

## Nome

- trim de whitespace nas pontas;
- obrigatório;
- máximo de 64 caracteres;
- único case-insensitively no repositório da sessão.

## Repositório da 0.5

```text
SESSION_LOCAL_CANDIDATE
```

Objetivo: provar o lifecycle do WeaponKit antes de UI/persistência/MP.

Operações:

- create;
- get;
- list;
- rename;
- duplicate;
- update Recipe;
- delete.

Regras:

- get/list retornam defensive copies;
- conteúdo duplicado é permitido com nomes/IDs diferentes;
- nome duplicado case-insensitive é rejeitado;
- Recipe incompatível com targetSlot é rejeitada;
- nenhuma operação altera o loadout do jogador.

## Fingerprint

WeaponKit content fingerprint considera:

- targetSlot;
- Recipe fingerprint.

Ele **não considera**:

- kitId;
- name.

Assim, dois kits podem possuir identidade e nomes diferentes, mas representar exatamente a mesma montagem.

Esse fingerprint não é identidade física da arma.

## Gates posteriores

### 0.6 — Weapons Player UI / Kit Builder

Consumirá o repositório/modelo 0.5 para apresentar:

- Meus Kits;
- criar;
- editar;
- renomear;
- duplicar;
- excluir;
- catálogo/configuração.

### 0.7 — Slot-Safe Weapon Application

Será responsável por realmente equipar o WeaponKit no slot alvo preservando todo o restante do loadout.

### 0.8 — Multiplayer Authority / Reconciliation

Autoridade, concorrência, sincronização, JIP/reconnect.

Persistência externa continua separada/provider-driven.

## Critério de homologação 0.5

O AUTO TEST deve comprovar:

- regressão 0.1-B -> 0.4 permanece verde;
- PRIMARY/HANDGUN/SECONDARY WeaponKit;
- slot/Recipe matching;
- schema fechado;
- nome;
- IDs distintos;
- duplicate;
- rename;
- update Recipe;
- delete;
- defensive copy;
- content fingerprint;
- nenhuma mutação do loadout;
- UI/application/MP permanecem explicitamente deferred.

## Resultado runtime final

```text
[AUTO_TEST_SUMMARY]
mode=MISSION_FIRST_0_5
passed=301
failed=0
total=301
```

Além da regressão completa anterior, foram executados **50 gates específicos da 0.5**, todos PASS.

Confirmado no runtime:

- store session-local;
- PRIMARY/HANDGUN/SECONDARY;
- create/get/list;
- rename/duplicate/update/delete;
- nomes únicos case-insensitively;
- Recipe/slot mismatch fail-closed;
- defensive copy;
- identidade lógica distinta em duplicate;
- content fingerprint independente de nome/kitId;
- nenhuma operação de WeaponKit alterou o loadout;
- UI explicitamente deferred para 0.6;
- aplicação explicitamente deferred para 0.7;
- multiplayer explicitamente deferred para 0.8.

**Weapons 0.5 — WeaponKit = HOMOLOGADA / FROZEN mission-first.**

Próximo marco: **0.6 — Weapons Player UI / Kit Builder**.
