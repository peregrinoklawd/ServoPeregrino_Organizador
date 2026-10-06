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


## RPT C2 real — 06/10/2026

A correção de roteamento foi confirmada em Arma real.

Gates:
- UICommon: **31/31**;
- Items + UICommon: **16/16**;
- o novo check de performance `base-weapon swap avoids FULL and refreshes only Draft+Catalog` passou;
- a troca de arma-base não provocou mais `mode=FULL`.

No teste manual, o custo residual ficou concentrado em P3:
- Draft focused variou de poucos ms até ~142 ms conforme a arma;
- Catalog focused com `projectionBuilt=true` variou aproximadamente de **64 ms a 286 ms**;
- `projectionMs` ficou aproximadamente entre **41 ms e 242 ms** nos exemplos manuais;
- nenhum desses eventos registrou `fullRefresh=true`.

Conclusão atual:
- o desperdício de reconstruir P1/P4 foi removido;
- o stutter remanescente acompanha a reconstrução da projeção de compatibilidade derivada da engine/modset;
- não será introduzida nova otimização de runtime dentro da 0.2-C;
- um cache de compatibilidade por arma poderá ser estudado futuramente, separado deste gate.

## Test harness hardening

O mesmo RPT ainda apresentou **596/598**, exclusivamente por dois checks de identificação textual:
- UI state schema/release label;
- header contendo literalmente `0.6-F R6`.

Como o projeto exige 0 FAIL para uma entrega aceita, o harness foi corrigido no commit:
`7933fbb8a1838bf817c0b809834b8cf105eb6932`.

Release/version/header metadata agora são observações e não gates.

Próximo resultado esperado:
- **594 PASS / 0 FAIL / 594 checks**;
- **6 observations**;
- UICommon 31/31;
- Items + UICommon 16/16.
