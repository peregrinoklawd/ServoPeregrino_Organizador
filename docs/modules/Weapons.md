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

## Implementação 0.1-A

Foundation/Nexus, `weapons.runtime`, modelos candidatos WeaponConfiguration/WeaponInstance, registry lógico SERVER/SESSION e observações do laboratório. Não publica contracts v1 nem capabilities catalog/configuration/instance. Funções de compatibilidade são validações internas limitadas; não representam serviço de catálogo completo.

Identidade física **não comprovada**: transferências e armas idênticas retornam UNPROVEN/AMBIGUOUS. Sem integração com outros domínios. [Relatório e gates](../21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md).
