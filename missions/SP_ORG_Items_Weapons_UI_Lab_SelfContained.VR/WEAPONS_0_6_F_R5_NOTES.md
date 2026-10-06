# Weapons 0.6-F R5 — Dynamic Draft Authoring Candidate

## Scope
- Sending a weapon from the Catalog creates a new draft kit automatically when no kit is selected.
- Base weapon replacement is no longer locked to the saved kit slot/category.
- Slot/category remains internal metadata and is not shown in ARMAS DO KIT or its footer context.
- Saving a cross-category replacement atomically updates internal targetSlot + Recipe while preserving kit id/name.
- Player-facing direct-authoring errors use explanatory Portuguese messages instead of internal result codes.
- R4 keep-aspect previews and uniform Catalog filters are preserved.
- R4 CatalogSearch tooltip syntax regression is fixed.
- Mission-level CfgRemoteExec no longer sets global mode/jip policy; endpoint declarations remain.
- R4 runner failures caused by stale full-label expectations are corrected in the R5 runner.

## Still deferred
- Physical weapon application: 0.7.
- Multiplayer authority/JIP: 0.8.
- Icon-based filter buttons: future UI evolution.
- Real 3D preview: future evolution.
