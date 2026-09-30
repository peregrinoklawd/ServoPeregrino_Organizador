# Weapons 0.2 — WeaponConfiguration

## Estado

**MISSION-FIRST FUNCTIONAL GATE: APPROVED (single-player).**

- Candidata final: **0.2 R3**.
- AUTO TEST final: **175/175 PASS / 0 FAIL**.
- PBO Packaging: **DEFERRED**.
- Multiplayer/JIP: **DEFERRED**.
- Source do addon nesta branch: ainda **0.1-A**, integração do delta 0.2 pendente.

## Modelo candidato

`WeaponConfiguration 0.2-candidate` contém somente estado de montagem:

- `weaponClass`;
- `muzzle`;
- `pointer`;
- `optic`;
- `bipod`.

Magazine carregado e contagem de munição pertencem a `loadedState` transitório e permanecem fora do fingerprint de configuração.

## Slots

Mapeamento candidato:

| Campo | Slot engine |
|---|---|
| muzzle | MuzzleSlot |
| pointer | PointerSlot |
| optic | CowsSlot |
| bipod | UnderBarrelSlot |

## Capacidades validadas

### Capture

Captura da configuração equipada separada do loadedState.

### Diff

`diffWeaponConfigurations` informa `sameWeaponClass`, igualdade, `changedCount` e lista de alterações por slot. Comparação é case-insensitive sem mutar a representação armazenada.

### Apply / round-trip

`applyWeaponConfiguration`:

- exige alvo local;
- valida slot e compatibilidade;
- exige mesma `weaponClass`;
- aplica apenas attachments;
- recaptura o estado real do engine;
- verifica configuração alvo == configuração observada;
- verifica loadedState antes/depois;
- faz rollback de attachments se a verificação falhar;
- se `changedCount=0`, retorna imediatamente sem mutar inventário.

## Evidência final

PRIMARY/MX:

- magazine montado com 17 tiros;
- aplicação de suppressor + pointer + optic + bipod;
- round-trip igual ao alvo;
- 17 tiros preservados;
- remoção de todos os attachments também preservou 17 tiros.

HANDGUN/P07:

- suppressor aplicado;
- 11 tiros preservados.

SECONDARY/NLAW:

- launcher e magazine carregado capturados;
- classe alvo derivada do estado realmente observado pelo engine;
- no-op retornou `WEAPONS_CONFIGURATION_ALREADY_APPLIED` sem mutação;
- magazine NLAW permaneceu carregado.

## Falhas que viraram decisões

### Harness de ammo

A primeira candidata tentou montar ammo customizado com uma rota que não produziu loadedState confiável. O harness passou a construir diretamente a linha de arma em `getUnitLoadout/setUnitLoadout`, e os asserts de ammo passaram a falhar de forma defensiva em vez de gerar erro de script.

### No-op

A candidata inicial desmontava/reaplicava attachments mesmo quando a configuração já era igual. A regra atual é: **no-op não toca no engine**.

### SECONDARY

A R2 assumia antecipadamente uma classe para o launcher. A R3 mantém a trava rígida de `weaponClass` e deriva o alvo da classe/configuração observada pelo engine. A proteção `WEAPONS_APPLY_CLASS_MISMATCH` não foi relaxada.

## Fronteiras preservadas

- identidade continua em WeaponInstance/Weapons;
- desgaste/condição não entra em WeaponConfiguration;
- ammo/magazine carregado não entra em fingerprint;
- economia, estoque e persistência permanecem providers futuros;
- UI final pertence a consumidores como Armorer/Hub, não a este modelo.

## Próximo marco

**0.3 — Catalog & Compatibility**: descobrir a partir do engine quais attachments e magazines são compatíveis por arma/slot, inclusive conteúdo de mods, evitando hardcode por classname.
