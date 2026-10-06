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
