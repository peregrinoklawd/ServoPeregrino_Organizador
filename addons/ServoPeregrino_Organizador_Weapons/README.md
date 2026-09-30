# ServoPeregrino_Organizador_Weapons

**STATUS DO SOURCE NESTA BRANCH: 0.1-A. VALIDAÇÃO MISSION-FIRST EXTERNA: 0.1-B e 0.2 aprovadas em SP; integração ao addon/PBO ainda pendente.**

Domínio próprio (nem toda a lista está implementada nesta entrega):
- WeaponKit / WeaponConfiguration;
- compatibilidade de slots/acessórios;
- identidade individual `WeaponInstance`;
- serial definitivo;
- WeaponRecipe e montagem/configuração lógica;
- compatibilidade de magazines e troca dinâmica de armas;
- metadata estritamente relacionada à identidade;
- integração opcional com Policy, Persistence, Stock e Economy.

Não copiar o Application Engine de Items. Compartilhar contratos/padrões, não estado interno.

Ver `docs/modules/Weapons.md`.

Weapons define o que a arma **é**. Condição/desgaste/manutenção lógica pertencem exclusivamente a **WeaponCondition**. Bancada, Preview e workflows/UI pertencem a **Armorer**.

Núcleos podem evoluir isoladamente: Weapons exige apenas Nexus, sem aguardar o gate Items 0.13-A ou a migração de Armorer. Integrações futuras terão gates próprios.

## Implementado nesta candidata

Foundation/lifecycle, `weapons.runtime`, modelos internos candidatos, compatibilidade estrutural/config, serial lógico SERVER/SESSION e spike observacional. Identidade física não comprovada; gates A–E abertos. Não há contrato v1 nem integração com outros domínios.

Instalação, limitações e testes: [relatório da entrega](../../docs/21_WEAPONS_0_1_A_FOUNDATION_IDENTITY_SPIKE.md).


## Evidência posterior ao source 0.1-A

Os laboratórios mission-first evoluíram sem ainda substituir este source do addon:

- 0.1-B: AUTO TEST 128/128 + Take/Put manual 3/3; event-delta CORRELATED/AMBIGUOUS/UNPROVEN sem alegar identidade física.
- 0.2 R3: AUTO TEST 175/175; WeaponConfiguration 0.2-candidate, diff, apply/round-trip, preservação de loadedState e PRIMARY/HANDGUN/SECONDARY.

Esses resultados não significam que o addon/PBO desta branch já seja 0.2. Antes de publicar uma versão de addon correspondente, o delta mission-first precisa ser integrado ao source, revisado e passar Packaging/MP próprios.
