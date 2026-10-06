# UICommon 0.2-C C2 — Weapons Catalog-to-Draft Performance Fix

Data: 06/10/2026.

## Sintoma

No teste manual da C1, equipar/trocar uma arma do Catálogo para o rascunho causava um stutter perceptível.

## Evidência

O RPT mostrou que a navegação virtual estava saudável:
- Catalog wheel de Weapons em ~6–10 ms;
- `projectionBuilt=false`;
- `fullRefresh=false`.

Porém, após Catalog-to-Draft de arma-base, surgiam full refreshes de aproximadamente:
- 298 ms;
- 246 ms;
- 110 ms;
- 97 ms;
- 281 ms;
- 346 ms.

O catálogo também registrava `projectionBuilt=true`, esperado quando a arma-base muda porque a compatibilidade de acessórios muda.

## Causa

`setWeaponKitDraftWeapon` faz corretamente:
- mutation apenas de `draftsByKitId`;
- dirty/revision;
- reset de Catalog offset;
- invalidation da projeção de compatibilidade.

Ele NÃO:
- chama SALVAR;
- altera WeaponKit persistido em kit existente;
- altera loadout físico.

O stutter adicional vinha do handler, que convertia uma mutação local de P2/P3 em `_refresh=true`, reconstruindo os quatro painéis e o view-model inteiro.

## Correção C2

Para kit existente:

```text
CATALOG_TO_DRAFT / SET_DRAFT_WEAPON
  -> mutate local draft
  -> Draft focused refresh (P2)
  -> Catalog focused refresh (P3) somente se base weapon mudou
  -> zero full refresh
  -> zero P4 recapture por esse roteamento
```

Para accessory Catalog-to-Draft:

```text
mutate local draft
  -> Draft focused refresh
  -> Catalog projection permanece válida
```

Para auto-create sem kit selecionado:

```text
create session WeaponKit
  -> FULL refresh permanece permitido
```

Esse último caso muda P1 de verdade.

## Regression test

O runner R6 agora captura:
- `refreshAppliedCount`;
- `draftFocusedRefreshCount`;
- `catalogFocusedRefreshCount`;

antes do base-weapon swap e exige:
- full delta = 0;
- draft focused delta = 1;
- catalog focused delta = 1;
- projection source weapon = nova arma.

## Gate C2

Esperado:
- UICommon 31/31;
- Items+UICommon 16/16;
- Weapons 596/598, com somente os mesmos dois FAILs harness-only;
- RPT da troca de arma-base sem `mode=FULL` causado pelo evento;
- avaliar percepção manual de stutter novamente.

A reconstrução de compatibilidade de P3 continua necessária. Se ainda houver stutter perceptível após remover o full refresh, o próximo estudo deve mirar exclusivamente o custo de projection rebuild, não o restante da interface.
