# Weapons — ownership

## Papel

Dono do que a arma **é**: identidade, configuração, compatibilidade e receitas.

## Planejado

- WeaponKit;
- WeaponConfiguration;
- WeaponRecipe como modelo/contrato;
- slots/acessórios/compatibilidade;
- compatibilidade de magazines;
- montagem/configuração lógica;
- troca dinâmica de arma sem alterar o restante do loadout;
- WeaponInstance;
- serial/instanceId definitivo;
- metadata/histórico de identidade;
- contratos públicos para Armorer, WeaponCondition e Sets.

## Não é dono

- desgaste;
- condição;
- sujeira;
- lubrificação;
- corrosão;
- confiabilidade;
- manutenção lógica;
- bancada/UI.

Esses estados pertencem a **WeaponCondition**; a interação física/visual pertence ao **Armorer**.

## Regra

A identidade individual da arma permanece em Weapons mesmo quando WeaponCondition estiver desabilitado.

## Integrações opcionais

Policy, Persistence, Stock e Economy.

Ver:
- `WeaponCondition.md`
- `Armorer.md`
- `../17_ARMORER_WEAPONS_WEAR_ARCHITECTURE.md`

## Estado de implementação e validação

### Source integrado

A branch atual ainda contém o **addon source 0.1-A**: Foundation/Nexus, `weapons.runtime`, modelos candidatos WeaponConfiguration/WeaponInstance, registry lógico SERVER/SESSION e observação conservadora. Não publica contracts v1 nem capabilities catalog/configuration/instance.

### 0.1-B — validada em missão

O laboratório mission-first aprovou event-delta evidence com AUTO TEST 128/128 e Take/Put real 3/3. Correlação única não é promovida a identidade física. Duplicatas idênticas permanecem AMBIGUOUS e não recebem binding inventado.

### 0.2 — validada em missão

WeaponConfiguration avançou para schema candidato 0.2 com quatro slots físicos, diff e apply verificado pelo estado real do engine. Magazine/ammo continuam em loadedState transitório. PRIMARY, HANDGUN e SECONDARY passaram; no-op não muta o inventário; incompatibilidades falham antes de mutação.

### Próximo passo

0.3 — Catalog & Compatibility: catálogo derivado do engine para attachments/magazines, inclusive modded, sem hardcode por arma.

Identidade física intrínseca continua **não comprovada** e MP/JIP/PBO permanecem gates próprios. Ver [0.1-A](../21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md), [0.1-B](../22_WEAPONS_0_1_B_IDENTITY_LIFECYCLE.md) e [0.2](../23_WEAPONS_0_2_WEAPON_CONFIGURATION.md).
