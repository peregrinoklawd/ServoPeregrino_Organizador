# UICommon 0.2-A — Inventory Decision / 0.2-B Pure Shared Primitives

Data: 05/10/2026.

## Fonte de verdade

Branch:
`feature/uicommon-0.1-foundation`

Baseline lida diretamente do Git:
- HEAD antes da implementação: `bac00928aad2be86afe77108cbe3193c07ed90d8`;
- Weapons R6 materializada por `ddd9a53afcbffe827a5a663c96f1531623db655f`;
- missão canônica: `missions/SP_ORG_Items_Weapons_UI_Lab_SelfContained.VR`.

Nenhuma reconstrução de Weapons foi feita a partir de memória.

## Resultado do inventário

O problema compartilhável real está abaixo do domínio.

UICommon deve possuir mecanismos genéricos:
- tokens/controles;
- structured text;
- virtual navigation;
- geometry/hit testing;
- footer renderer;
- performance instrumentation;
- primitives de invalidation.

Items e Weapons continuam donos de:
- UI state;
- view-model;
- regras de busca/filtro;
- projeção/cache de catálogo;
- seleção semântica;
- refreshers de domínio;
- mutação física.

## Decisões de classificação

### SHARED
- theme/tokens;
- controles-base;
- structured text;
- footer renderer;
- virtual window/scroll state;
- slider mechanics;
- point/rect geometry;
- performance timing/log grammar.

### CANDIDATE-SHARED
- history feedback contract;
- focused invalidation;
- search plumbing;
- focus/selection;
- keep-aspect;
- spacing interno não comprovado como idêntico.

### DOMAIN-SPECIFIC
- ItemKit/WeaponKit/WeaponRecipe;
- capacity/inventory;
- compatibility;
- targetSlot;
- catalog projection/cache;
- filter semantics;
- view-model/UI state;
- application engine.

### DEFERRED
- row pool;
- tooltip overlay;
- drag ghost;
- DnD shared layer;
- Preview 3D.

## Performance contract

Interações locais continuam locais.

Exemplo obrigatório:

```text
wheel
  -> offset
  -> catalog invalidation
  -> catalog refresh only
```

Proibido:

```text
wheel
  -> full interface refresh
```

UICommon não decide qual superfície um evento de domínio invalida.

## 0.2-B — implementação

Commit técnico:
`7fbc103093fedf583ed10c94cc8bb717ea9ba0f4`

Versão:
- display: `0.2`;
- semantic: `0.2.0.1`;
- build: `0.2.0.1-pure-shared-primitives-b1`.

Novas funções:

### getVirtualScrollState

Entrada:
- offset;
- totalCount;
- windowSize.

Saída genérica:
- offset clamped;
- windowSize;
- totalCount;
- maxOffset;
- visibleCount;
- scrollRatio;
- firstIndex;
- lastIndex.

Não conhece catálogo, Items ou Weapons.

### pointInRect

Entrada:
- x;
- y;
- rect `[x,y,w,h]`.

Contrato:
- bordas inclusivas;
- dimensão negativa rejeitada;
- nenhum conhecimento de payload, painel ou domínio.

## Testes

Foundation:
- baseline anterior: 12 checks;
- source da candidata: 24 assertion sites.

Items + UICommon:
- permanece com 12 assertion sites;
- removido gate pelo texto literal do build;
- agora identifica o componente por contrato funcional.

Static concluído:
- addon/mission parity;
- registrations;
- bracket/brace/parenthesis balance;
- zero referências Items/Weapons nas novas primitives.

## Limite de homologação

Static NÃO é runtime.

Não declarar:
- UICommon 24/24;
- Items equivalence 12/12 para 0.2-B;
- Weapons regressão aprovada;

até existir RPT real do Arma.

## Próximo gate

Executar na missão canônica:
1. TESTAR UICOMMON;
2. TESTAR ITEMS + UICOMMON.

Se ambos estiverem verdes:
- congelar 0.2-B;
- iniciar 0.2-C Virtual Navigation + Footer Rendering;
- continuar sem Weapons 0.7 física.
