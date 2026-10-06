# Weapons 0.6-F R3 — Search Isolation / Name Editing

## Scope

This candidate fixes three runtime UX defects found after 0.6-F R2 manual validation:

1. inline WeaponKit name may be temporarily empty while editing; validation happens only on save;
2. ARMAS DO KIT, CATÁLOGO DE ARMAS and CONTEÚDO DO EQUIPAMENTO own independent search state;
3. a non-empty Catalog text query temporarily ignores stored Type/Accessory filters; clearing the query restores them.

## Search semantics

- P2 / ARMAS DO KIT: local filtering of current weapon/component rows only.
- P3 / CATÁLOGO DE ARMAS: global text query across the current catalog projection; Type and Accessory filter buttons are paused while text is present.
- P4 / CONTEÚDO DO EQUIPAMENTO: local filtering of current equipped weapon/component rows only.

Stored P3 filters are never destroyed by a text query.

## Name editing

Deleting the complete name no longer causes the saved name to be immediately repainted.
The field can remain blank while typing. SALVAR rejects a truly blank final name with an explicit message.

## Preserved

- 0.6-F R2 changed-row amber semantics;
- P2/P4 preview-ready alignment;
- direct Catalog-to-Draft authoring;
- compatibility projection invalidation;
- focused refresh;
- Items / UICommon / Nexus byte-identical to R2;
- physical application deferred to 0.7;
- MP/JIP deferred to 0.8.
