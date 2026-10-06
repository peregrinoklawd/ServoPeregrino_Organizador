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
