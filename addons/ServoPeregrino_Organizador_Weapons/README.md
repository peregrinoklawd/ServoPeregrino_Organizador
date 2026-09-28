# ServoPeregrino_Organizador_Weapons

**STATUS: SLOT DE MÓDULO — planejado.**

Dono futuro de:
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
