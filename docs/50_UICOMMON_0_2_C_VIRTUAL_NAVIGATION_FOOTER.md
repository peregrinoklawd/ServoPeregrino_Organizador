# UICommon 0.2-C — Virtual Navigation + Footer Rendering

Data: 06/10/2026.

## Estado

Candidata mission-first:
- display `0.2`;
- semantic `0.2.0.2`;
- build `0.2.0.2-virtual-navigation-footer-c1`.

Fallback homologado:
- UICommon 0.2-B;
- runtime real 24/24 Foundation;
- runtime real 12/12 Items + UICommon.

## Objetivo

Remover duplicação comprovada de mecanismo em Items e Weapons sem compartilhar estado privado, regra de domínio ou roteamento semântico.

## API compartilhada

### syncVirtualSlider

Entrada:
- control;
- offset;
- totalCount;
- windowSize;
- smallStep;
- minLargeStep;
- show.

Responsabilidade:
- usar `getVirtualScrollState`;
- sincronizar range/speed/position/enabled/show;
- retornar o scroll state calculado.

Não decide:
- qual evento mudou o offset;
- qual painel deve refresh;
- filtros;
- catálogo;
- seleção.

### buildFooterBandStructuredText

Entrada:
- label;
- texto;
- cores;
- separador.

Responsabilidade:
- escapar structured text;
- montar a banda de apresentação.

### renderFooter

Entrada:
- display;
- lista de bandas declarativas `[idc,label,text,labelColor,textColor,separator]`.

Responsabilidade:
- localizar controles;
- renderizar structured text.

Não conhece:
- ItemKit;
- WeaponKit;
- status de draft;
- significado do histórico;
- regras de severidade.

## Migração de consumidores

Items:
- Full refresh: slider + footer;
- Catalog focused: slider + footer;
- Draft focused: footer;
- Equipment focused: footer;
- wheel: hit testing por `pointInRect`.

Weapons R6:
- Full refresh: slider + footer;
- Catalog focused: slider + footer;
- Draft focused: footer;
- wheel: hit testing por `pointInRect`.

O conteúdo do footer continua sendo construído dentro de cada módulo.

## Performance

A extração não altera o grafo de invalidation.

Obrigatório:

```text
wheel
 -> CATALOG_SCROLL local
 -> catalogOffset
 -> refreshCatalogWindowUI
 -> fullRefresh=false
```

Proibido:

```text
wheel -> refreshInterface global
```

## Static gate

- UICommon addon/mission parity: OK;
- Items addon/mission parity nos fontes migrados: OK;
- domínio em novas funções UICommon: 0;
- manual slider setup removido dos refreshers migrados;
- footer direct-write removido dos refreshers migrados;
- foundation: 31 assertion sites;
- Items equivalence: 16 assertion sites;
- Weapons R6 runner preservado.

## Runtime gate

Executar no Arma:
1. TESTAR UICOMMON -> esperado 31/31;
2. TESTAR ITEMS + UICOMMON -> esperado 16/16;
3. TESTAR WEAPONS 0.6-F R6 -> não pode introduzir FAIL novo; baseline conhecida é 595/597 com 2 FAILs harness-only;
4. abrir Items e Weapons;
5. validar wheel e slider no Catálogo;
6. observar RPT de `UI_PERF`: focused catalog deve permanecer `fullRefresh=false`;
7. conferir visualmente CONTEXTO / RESULTADO / HISTÓRICO.

Somente RPT real pode homologar a 0.2-C.


## Atualização 06/10/2026 — C1 funcional verde; performance manual bloqueou homologação; C2 preparada

RPT real da C1:
- UICommon Foundation: **31 PASS / 0 FAIL**;
- Items + UICommon Equivalence: **16 PASS / 0 FAIL**;
- Weapons R6: **595 PASS / 2 FAIL / 597**, exatamente os dois FAILs harness/version-text já conhecidos;
- wheel do Weapons: aproximadamente **6–10 ms**, `projectionBuilt=false`, `fullRefresh=false`;
- wheel do Items: aproximadamente **13–14 ms**, sem projection rebuild e sem equipment recapture.

Manual:
- footer e navegação aprovados;
- foi percebido stutter ao enviar/trocar arma-base do Catálogo para o rascunho.

Diagnóstico do RPT:
- após a seleção/equip da arma, o caminho executava `mode=FULL`;
- exemplos manuais: **298 ms**, **246 ms**, **110 ms**, **97 ms**, **281 ms**, **346 ms**;
- nesses eventos `projectionBuilt=true`;
- o custo não vem de autosave nem de mutação física: em kit existente a arma é alterada somente no draft de sessão;
- a persistência real continua acontecendo apenas em SALVAR;
- o excesso era `_refresh=true` em `CATALOG_TO_DRAFT` / `SET_DRAFT_WEAPON`.

C2:
- build `0.2.0.2-virtual-navigation-footer-c2`;
- commit técnico `0d584e3a4b874418de171a753b68292184737a22`;
- base-weapon swap em kit existente agora atualiza somente **P2 Draft + P3 Catalog**;
- P1 e P4 não são reconstruídos;
- accessory Catalog-to-Draft atualiza somente P2;
- auto-create sem kit selecionado mantém FULL porque cria um novo WeaponKit de sessão e P1 realmente muda;
- nova regressão automática garante zero incremento de full refresh e +1 Draft/+1 Catalog focused no base swap.

C1 não é congelada como 0.2-C final por causa do gate de performance manual.
C2 aguarda RPT real.

Runtime esperado da C2:
- UICommon: **31/31**;
- Items + UICommon: **16/16**;
- Weapons R6+C2: **596 PASS / 2 FAIL / 598 total**, mantendo apenas os dois harness-only conhecidos;
- durante troca de arma-base em kit existente devem aparecer `DRAFT_FOCUSED reason=CATALOG_TO_DRAFT` e `CATALOG_FOCUSED reason=CATALOG_TO_DRAFT`, sem `mode=FULL` provocado por essa operação.
