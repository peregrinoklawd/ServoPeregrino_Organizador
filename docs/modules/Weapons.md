# Weapons — ownership

## Papel

Dono da semântica de armas e do estado persistente de cada arma quando necessário.

## Planejado

- WeaponKit;
- WeaponConfiguration;
- slots/acessórios/compatibilidade;
- WeaponInstance;
- serial/instanceId definitivo;
- condition/wear state;
- pending usage counters;
- parts/component state;
- contratos públicos para Armorer.

## Regra

Armorer manipula uma arma por contratos públicos; não armazena a verdade de condição/desgaste.

## Integrações opcionais

Policy, Persistence, Stock e Economy.

Ver `../17_ARMORER_WEAPONS_WEAR_ARCHITECTURE.md`.
