# SP_ORG UICommon

Shared UI infrastructure for Servo Peregrino modules.

## Ownership
UICommon owns generic presentation infrastructure only. It must not own ItemKit, WeaponKit, WeaponRecipe, inventory, weapon compatibility, application engines, persistence or condition/wear.

## Dependency direction
- UICommon -> Nexus
- Items -> Nexus + UICommon (future migration)
- Weapons -> Nexus + UICommon (future migration)

UICommon must never depend on Items or Weapons.

## 0.1 foundation
Initial executable skeleton:
- lifecycle/build/runtime;
- Nexus capability registration;
- shared visual tokens;
- pure virtual-list helpers;
- foundation self-test.

Items and Weapons do not depend on this addon yet.


## 0.1.1 — Items Equivalence R1
- adds generic structured-text escaping;
- Items begins consuming UICommon through compatibility wrappers;
- virtual catalog offset clamp is shared;
- no Items/Weapons domain ownership moved into UICommon;
- API remains experimental.


## 0.2-B — Pure Shared Primitives
- `getVirtualScrollState`;
- `pointInRect`;
- runtime real aprovado: Foundation 24/24, Items Equivalence 12/12.

## 0.2-C C1 — Virtual Navigation + Footer Rendering
- `syncVirtualSlider`;
- `buildFooterBandStructuredText`;
- `renderFooter`;
- Items e Weapons começam a consumir os mesmos mecanismos de slider/footer;
- wheel hit testing passa a reutilizar `pointInRect`;
- contexto, histórico, filtros e invalidation continuam pertencendo aos consumidores;
- runtime real ainda pendente.


## UICommon 0.2-D R1 — Shared Visual Foundation / HPP

Candidata:
- semantic `0.2.0.3`;
- build `0.2.0.3-shared-visual-hpp-d1`;
- commit técnico `7f2d86e406826087a0421282f89b130cf62891d4`;
- missão distribuída: `SP_ORG_UI_Lab_UICommon_0_2_D_R1.VR`.

Extração:
- novo `UICommon/ui/shared_controls.hpp`;
- métricas genéricas de clear/search/header anchor;
- Text / Title;
- Picture e PictureKeepAspect como variantes explícitas;
- SearchIcon e SearchIconKeepAspect;
- Button / ButtonDanger / IconButton;
- Edit;
- List base;
- Structured + três bases de Footer;
- VSlider.

Preservado:
- Items mantém CT_CONTROLS_TABLE e geometrias próprias;
- Weapons mantém Combo, keep-aspect e rowHeight 0.033;
- nenhum IDC mudou;
- nenhuma action/event handler mudou;
- nenhuma geometria de painel mudou;
- domínio e refresh routing não mudaram.

Static gate:
- UICommon addon/mission shared HPP byte-idênticos;
- Items addon/mission byte-idênticos;
- corpo de `SP_ORG_Items_Dialog` byte-idêntico à 0.2-C;
- corpo de `SP_ORG_Weapons_Dialog` byte-idêntico à 0.2-C;
- shared HPP com zero referências Items/Weapons/ItemKit/WeaponKit;
- keep-aspect Weapons preservado;
- Weapons list rowHeight 0.033 preservado;
- delimitadores estruturais balanceados;
- workflow de pacote: sucesso.

Runtime:
**PENDENTE DE RPT REAL.**

Gate:
- UICommon 31/31;
- Items + UICommon 16/16;
- Weapons 594/594, 0 FAIL;
- abrir Items e Weapons e comparar visualmente com a entrega anterior;
- nenhum erro de config/HPP;
- wheel/slider/focused refresh sem regressão.
